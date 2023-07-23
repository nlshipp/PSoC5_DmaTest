/* ========================================
 *
 * Copyright Neil Shipp,  2023
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/

#include "project.h"

uint8 dataIn[1024];
uint8 dataOut[1024];

uint8 dmaInCh;
uint8 dmaOutCh;
uint8 dmaInTD;
uint8 dmaOutTD;

reg8 * dmaFifoInPtr;
reg8 * dmaFifoOutPtr;
reg8 * dmaFifoStatus;
uint8 * fifoStatusOutPtr;

uint8 fifoStatusOut;
const static uint8 * bit_reversal;

void dmaTestLibInit(reg8 * fifoInPtr, reg8 * fifoOutPtr, reg8 * fifoStatusPtr, const uint8 * bit_reversalPtr)
{
    dmaFifoInPtr = fifoInPtr;
    dmaFifoOutPtr = fifoOutPtr;
    dmaFifoStatus = fifoStatusPtr;
    bit_reversal = bit_reversalPtr;
}

void dmaResetTD(uint16 count)
{
    // Must use DISABLE_TD to disable the DMA channel and not just END_CHAIN_TD, as if we use END_CHAIN, it appears the 
    // chain can be reactivated with a transfer count set to zero which causes it to run forever.
    CyDmaTdSetConfiguration(
                dmaInTD,
                count /* transfer count */,
                CY_DMA_DISABLE_TD, // next TD
                CY_DMA_TD_INC_SRC_ADR);
    CyDmaTdSetAddress(
                dmaInTD,
                LO16((uint32)dataIn),
                LO16((uint32)dmaFifoInPtr));
    
    CyDmaTdSetConfiguration(
                dmaOutTD,
                count /* transfer count */,
                CY_DMA_DISABLE_TD, // next TD
                CY_DMA_TD_INC_DST_ADR);
    CyDmaTdSetAddress(
                dmaOutTD,
                LO16((uint32)dmaFifoOutPtr),
                LO16((uint32)dataOut));
}

void dmaSetup(uint16 count)
{
    dmaInCh = DMA_1_DmaInitialize(
                1 /* bytes/burst */, 
                1 /* rqst/burst */, 
                HI16((uint32)dataIn), HI16(CYDEV_PERIPH_BASE));
                                                                        
    dmaOutCh = DMA_2_DmaInitialize(
                1 /* bytes/burst */, 
                1 /* rqst/burst */, 
                HI16(CYDEV_PERIPH_BASE), HI16((uint32)dataOut));
    
    dmaOutTD = CyDmaTdAllocate();
    dmaInTD = CyDmaTdAllocate();

    dmaResetTD(count);
}

uint8 dmaStatus(uint16 *inLeft, uint16 *outLeft)
{
    uint8 inState, outState;
    uint8 inTd, outTd;
    uint8 status = 0;
    
    CyDmaChStatus(dmaInCh, &inTd, &inState);
    CyDmaChStatus(dmaOutCh, &outTd, &outState);
    
    if (!(inState & STATUS_CHAIN_ACTIVE) && !(outState & STATUS_CHAIN_ACTIVE))
        status = 1;
    
    CyDmaTdGetConfiguration(dmaInTD, inLeft, NULL, NULL);
    CyDmaTdGetConfiguration(dmaOutTD, outLeft, NULL, NULL);
    
    fifoStatusOut = *dmaFifoStatus;
    return status;
}
    
void dmaTest(uint16 max)
{
    uint16 i = 0;
    uint16 in, out;
    uint8 done = 0;     // DMA transfer finished
    
    for (i = 0; i < max; i++) {
        dataIn[i] = (i % 256);
    }
    
    // test 1 - DMA on output channel only
    
    memset(dataOut, 0xFF, 1024);

    CyDmaChSetInitialTd(dmaInCh, dmaInTD);
    CyDmaChSetInitialTd(dmaOutCh, dmaOutTD);
    
    done = dmaStatus(&in, &out);

    i = 0;
    // preserve TD = 0
    CyDmaChEnable(dmaOutCh, 0);

    do {
        if (fifoStatusOut & 0x01) {
            *dmaFifoInPtr = (i & 0xFF);
            i++;
        }
    } while (!dmaStatus(&in, &out) && (i < 1024));
    
    CyDmaChDisable(dmaOutCh);
    CyDmaChDisable(dmaInCh);
    
    for (i = 0; i < max; i++) {
        if (bit_reversal[dataIn[i]] != dataOut[i]) {
            CYASSERT(0);
        }
    }
    
    // test 2 - DMA on input channel only

    memset(dataOut, 0xFF, 1024);
    

    CyDmaChSetInitialTd(dmaInCh, dmaInTD);
    CyDmaChSetInitialTd(dmaOutCh, dmaOutTD);
    
    done = dmaStatus(&in, &out);

    i = 0;
    // preserve TD = 0
    CyDmaChEnable(dmaInCh, 0);

    // preload status after enabling DMA channel
    // NOTE: since there are two fifos (in and out) it can mean there are 8 bytes in flight, so the in count can drop from 0x10 to 0x08.
    // Also, don't believe the done status just yet, the dmaStatus just returns done if both channels aren't active, DMA may not have started yet
    // so the done flag could be incorrectly asserted.
    done = dmaStatus(&in, &out);

    do {
        if (!(fifoStatusOut & 0x08)) {
            dataOut[i] = *dmaFifoOutPtr;
            i++;
        } 
        done = dmaStatus(&in, &out);
    } while ((!done || ((fifoStatusOut & 0x0A) != 0x0A)) && (i < 1024));  // while dma isn't finished or f0 and f1 aren't empty
    
    CyDmaChDisable(dmaOutCh);
    CyDmaChDisable(dmaInCh);
    
    for (i = 0; i < max; i++) {
        if (bit_reversal[dataIn[i]] != dataOut[i]) {
            CYASSERT(0);
        }
    }
    
    CYASSERT(fifoStatusOut == 0x1F);
    
    // test 3 - DMA on input and output 

    memset(dataOut, 0xFF, 1024);
    
    CyDmaChSetInitialTd(dmaInCh, dmaInTD);
    CyDmaChSetInitialTd(dmaOutCh, dmaOutTD);
    
    dmaResetTD(max);
    
    done = dmaStatus(&in, &out);
    
    // if fifo1 is empty, but output channel drq is set, reset the sticky drq from the previous
    // manual queue operations.
    if (CY_DMA_CH_STRUCT_PTR[dmaOutCh].basic_status[0] & 0x04)
        CY_DMA_CH_STRUCT_PTR[dmaOutCh].basic_status[0] = 0x04;

    i = 0;
    // preserve TD = 0
    CyDmaChEnable(dmaOutCh, 0);
    CyDmaChEnable(dmaInCh, 0);

    do {
        i++;
        done = dmaStatus(&in, &out);
    } while (!done && (i < 1024));  
    
    CyDmaChDisable(dmaOutCh);
    CyDmaChDisable(dmaInCh);
    
    CYASSERT(done);     // did we time-out?
    
    CYASSERT((fifoStatusOut & 0x0A) == 0x0A); // both FIFO's should be asserting empty.

    for (i = 0; i < max; i++) {
        if (bit_reversal[dataIn[i]] != dataOut[i]) {
            CYASSERT(0);
        }
    }
}    

/* [] END OF FILE */
