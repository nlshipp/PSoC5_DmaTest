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

/* BitReverse_B

   The implementation of a DMA based byte lookup component where fifo0 of a datapath is used as the input and fifo1 is 
   used as the output, this is common to all variants. The table lookup is done using two DMA channels ctrl/data
   which alternate using a toggle flip flop triggered from the nrq dma outputs. This should use one fewer P-term 
   than BitReverse_A.
*/

#include <cytypes.h>
#include <assert.h>
#include "`$INSTANCE_NAME`.h"
#include "`$INSTANCE_NAME`_DMA_Ctrl_dma.h"
#include "`$INSTANCE_NAME`_DMA_Data_dma.h"
#include "`$INSTANCE_NAME`_fifo_in_out_defs.h"

uint8 `$INSTANCE_NAME`_dma_ctrl;
uint8 `$INSTANCE_NAME`_dma_data;

uint8 `$INSTANCE_NAME`_dma_ctrl_TD;
uint8 `$INSTANCE_NAME`_dma_data_TD;

void `$INSTANCE_NAME`_Init(const uint8 byteTable[256])
{
    // byteTable must be 256 byte page aligned.
    CYASSERT(((uint32)(byteTable) & 0xFF) == 0)
    
    `$INSTANCE_NAME`_fifo_in_out_fifo_F0_CLEAR;
    `$INSTANCE_NAME`_fifo_in_out_fifo_F1_CLEAR;
    
    `$INSTANCE_NAME`_dma_ctrl = `$INSTANCE_NAME`_DMA_Ctrl_DmaInitialize(
                1 /* bytes/burst */, 
                1 /* rqst/burst */, 
                HI16(CYDEV_PERIPH_BASE), HI16(CYDEV_PERIPH_BASE));
                                                                        
    `$INSTANCE_NAME`_dma_data = `$INSTANCE_NAME`_DMA_Data_DmaInitialize(
                1 /* bytes/burst */, 
                1 /* rqst/burst */, 
                HI16(CYDEV_SRAM_BASE), HI16(CYDEV_PERIPH_BASE));
    
    `$INSTANCE_NAME`_dma_data_TD = CyDmaTdAllocate();
    `$INSTANCE_NAME`_dma_ctrl_TD = CyDmaTdAllocate();
    
    // The ctrl TD loads the source byte from fifo0 into the lower order byte of the source address offset of data TD
    CyDmaTdSetConfiguration(
                `$INSTANCE_NAME`_dma_ctrl_TD,
                1 /* transfer count */,
                `$INSTANCE_NAME`_dma_ctrl_TD, /* next TD - loop back*/
                `$INSTANCE_NAME`_DMA_Ctrl__TD_TERMOUT_EN);  // enable NRQ output to run data TD
    CyDmaTdSetAddress(
                `$INSTANCE_NAME`_dma_ctrl_TD,
                LO16((uint32)`$INSTANCE_NAME`_fifo_in_out_fifo_F0_PTR),
                LO16((uint32)&DMAC_TDMEM[`$INSTANCE_NAME`_dma_data_TD].TD1[0]));
    
    // The data TD loads a byte from the passed byteTable indexed by the inpute byte above, and 
    // copies it to fifo1.
    CyDmaTdSetConfiguration(
                `$INSTANCE_NAME`_dma_data_TD,
                1 /* transfer count */,
                `$INSTANCE_NAME`_dma_data_TD, /* next TD - loop back*/
                `$INSTANCE_NAME`_DMA_Data__TD_TERMOUT_EN);  // enable NRQ output to enable ctrl TD for next byte
    CyDmaTdSetAddress(
                `$INSTANCE_NAME`_dma_data_TD,
                LO16((uint32)byteTable),
                LO16((uint32)`$INSTANCE_NAME`_fifo_in_out_fifo_F1_PTR));
    
    CyDmaChSetInitialTd(`$INSTANCE_NAME`_dma_ctrl, `$INSTANCE_NAME`_dma_ctrl_TD);
    CyDmaChSetInitialTd(`$INSTANCE_NAME`_dma_data, `$INSTANCE_NAME`_dma_data_TD);
}
    
void `$INSTANCE_NAME`_Enable()
{
    CyDmaChEnable(`$INSTANCE_NAME`_dma_data, 1);    // preserve TD values
    CyDmaChEnable(`$INSTANCE_NAME`_dma_ctrl, 1);    // preserve TD values
}

void `$INSTANCE_NAME`_Disable()
{
    CyDmaChDisable(`$INSTANCE_NAME`_dma_data);
    CyDmaChDisable(`$INSTANCE_NAME`_dma_ctrl);
}
