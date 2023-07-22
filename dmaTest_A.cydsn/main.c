/* ========================================
 *
 * Copyright Neil Shipp, 2023
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/
#include "project.h"

const uint8 bit_reversal[256] __attribute__ ((section(".data"))) __attribute__ ((aligned (256))) = {
 0x00, 0x80, 0x40, 0xc0, 0x20, 0xa0, 0x60, 0xe0,  0x10, 0x90, 0x50, 0xd0, 0x30, 0xb0, 0x70, 0xf0,
 0x08, 0x88, 0x48, 0xc8, 0x28, 0xa8, 0x68, 0xe8,  0x18, 0x98, 0x58, 0xd8, 0x38, 0xb8, 0x78, 0xf8,
 0x04, 0x84, 0x44, 0xc4, 0x24, 0xa4, 0x64, 0xe4,  0x14, 0x94, 0x54, 0xd4, 0x34, 0xb4, 0x74, 0xf4,
 0x0c, 0x8c, 0x4c, 0xcc, 0x2c, 0xac, 0x6c, 0xec,  0x1c, 0x9c, 0x5c, 0xdc, 0x3c, 0xbc, 0x7c, 0xfc,
 0x02, 0x82, 0x42, 0xc2, 0x22, 0xa2, 0x62, 0xe2,  0x12, 0x92, 0x52, 0xd2, 0x32, 0xb2, 0x72, 0xf2,
 0x0a, 0x8a, 0x4a, 0xca, 0x2a, 0xaa, 0x6a, 0xea,  0x1a, 0x9a, 0x5a, 0xda, 0x3a, 0xba, 0x7a, 0xfa,
 0x06, 0x86, 0x46, 0xc6, 0x26, 0xa6, 0x66, 0xe6,  0x16, 0x96, 0x56, 0xd6, 0x36, 0xb6, 0x76, 0xf6,
 0x0e, 0x8e, 0x4e, 0xce, 0x2e, 0xae, 0x6e, 0xee,  0x1e, 0x9e, 0x5e, 0xde, 0x3e, 0xbe, 0x7e, 0xfe,
 
 0x01, 0x81, 0x41, 0xc1, 0x21, 0xa1, 0x61, 0xe1,  0x11, 0x91, 0x51, 0xd1, 0x31, 0xb1, 0x71, 0xf1,
 0x09, 0x89, 0x49, 0xc9, 0x29, 0xa9, 0x69, 0xe9,  0x19, 0x99, 0x59, 0xd9, 0x39, 0xb9, 0x79, 0xf9,
 0x05, 0x85, 0x45, 0xc5, 0x25, 0xa5, 0x65, 0xe5,  0x15, 0x95, 0x55, 0xd5, 0x35, 0xb5, 0x75, 0xf5,
 0x0d, 0x8d, 0x4d, 0xcd, 0x2d, 0xad, 0x6d, 0xed,  0x1d, 0x9d, 0x5d, 0xdd, 0x3d, 0xbd, 0x7d, 0xfd,
 0x03, 0x83, 0x43, 0xc3, 0x23, 0xa3, 0x63, 0xe3,  0x13, 0x93, 0x53, 0xd3, 0x33, 0xb3, 0x73, 0xf3,
 0x0b, 0x8b, 0x4b, 0xcb, 0x2b, 0xab, 0x6b, 0xeb,  0x1b, 0x9b, 0x5b, 0xdb, 0x3b, 0xbb, 0x7b, 0xfb,
 0x07, 0x87, 0x47, 0xc7, 0x27, 0xa7, 0x67, 0xe7,  0x17, 0x97, 0x57, 0xd7, 0x37, 0xb7, 0x77, 0xf7,
 0x0f, 0x8f, 0x4f, 0xcf, 0x2f, 0xaf, 0x6f, 0xef,  0x1f, 0x9f, 0x5f, 0xdf, 0x3f, 0xbf, 0x7f, 0xff
};

uint8 valIn = 0;
uint8 valOut;
uint8 statusOut;

uint8 dataIn[1024];
uint8 dataOut[1024];

uint8 dmaInCh;
uint8 dmaOutCh;
uint8 dmaInTD;
uint8 dmaOutTD;

void kiloSetup(uint16 count)
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
                LO16((uint32)&BitReverse_A_1_fifo_in));
    
    CyDmaTdSetConfiguration(
                dmaOutTD,
                count /* transfer count */,
                CY_DMA_DISABLE_TD, // next TD
                CY_DMA_TD_INC_DST_ADR);
    CyDmaTdSetAddress(
                dmaOutTD,
                LO16((uint32)&BitReverse_A_1_fifo_out),
                LO16((uint32)dataOut));
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
    
    statusOut = BitReverse_A_1_fifo_status_Status;
    return status;
}
    
void kiloTest(uint16 max)
{
    uint16 i = 0;
    uint16 in, out;
    uint8 done = 0;     // DMA transfer finished
    
    for (i = 0; i < max; i++) {
        dataIn[i] = (i % 256);
    }
    
    memset(dataOut, 0xFF, 1024);

    CyDmaChSetInitialTd(dmaInCh, dmaInTD);
    CyDmaChSetInitialTd(dmaOutCh, dmaOutTD);
    
    done = dmaStatus(&in, &out);

    i = 0;
    // preserve TD = 0
    CyDmaChEnable(dmaOutCh, 0);

    do {
        if (statusOut & 0x01) {
            BitReverse_A_1_fifo_in = (i & 0xFF);
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
    
    // test 2

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
        if (!(statusOut & 0x08)) {
            dataOut[i] = BitReverse_A_1_fifo_out;
            i++;
        } 
        done = dmaStatus(&in, &out);
    } while ((!done || ((statusOut & 0x0A) != 0x0A)) && (i < 1024));  // while dma isn't finished or f0 and f1 aren't empty
    
    CyDmaChDisable(dmaOutCh);
    CyDmaChDisable(dmaInCh);
    
    for (i = 0; i < max; i++) {
        if (bit_reversal[dataIn[i]] != dataOut[i]) {
            CYASSERT(0);
        }
    }
}    
    

int main(void)
{
    CyGlobalIntEnable; /* Enable global interrupts. */

    /* Enable byte lookup table component using bit reversal table */
    BitReverse_A_1_Init(bit_reversal);
    BitReverse_A_1_Enable();
    uint8 valIn = 0;
    uint8 valOut;
    
    statusOut = BitReverse_A_1_fifo_status_Status;
    CYASSERT(statusOut == 0x1f);
    
    {
        kiloSetup(0x10);
        kiloTest(0x10);
    }
    
    for(;;)
    {
        // wait for FIFO input to become empty, then add value to process
        statusOut = BitReverse_A_1_fifo_status_Status;
        while ((statusOut & 0x01) == 0) // f0NotFull
            statusOut = BitReverse_A_1_fifo_status_Status;
        
        BitReverse_A_1_fifo_in = valIn;
        
        // wait for result to become ready
        statusOut = BitReverse_A_1_fifo_status_Status;
        while ((statusOut & 0x08) == 0x08)  // f1Empty
            statusOut = BitReverse_A_1_fifo_status_Status;
        
        valOut = BitReverse_A_1_fifo_out;
        
        CYASSERT(bit_reversal[valIn] == valOut);
        valIn ++;
    }
}

/* [] END OF FILE */
