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

/* BitReverse_C

   The implementation of a DMA based byte lookup component where fifo0 of a datapath is used as the input and fifo1 is 
   used as the output, this is common to all variants. The table lookup is done using two DMA channels ctrl/data where
   alternation is done by use of a control register which the DMA channels set and reset as needed. Differing from variant
   A and B, each DMA channel has two TDs, one to perform a data copy, and the other to update the control register.

   This should use the least number of macrocells and P-terms and also have the least complex signal routing.
   This should have the worst performance since each byte requires four TDs to be executed instead of two.
*/

#include <cytypes.h>
#include <assert.h>
#include "`$INSTANCE_NAME`.h"
#include "`$INSTANCE_NAME`_Control_Reg.h"
#include "`$INSTANCE_NAME`_DMA_Ctrl_dma.h"
#include "`$INSTANCE_NAME`_DMA_Data_dma.h"
#include "`$INSTANCE_NAME`_fifo_in_out_defs.h"

uint8 `$INSTANCE_NAME`_dma_ctrl;
uint8 `$INSTANCE_NAME`_dma_data;

uint8 `$INSTANCE_NAME`_dma_ctrl_TD[2];
uint8 `$INSTANCE_NAME`_dma_data_TD[2];

// SRAM based constant for DMA to use to set control_reg
const uint8 `$INSTANCE_NAME`_control_reg_en_value = 1;

void `$INSTANCE_NAME`_Init(const uint8 byteTable[256])
{
    // byteTable must be 256 byte page aligned.
    CYASSERT(((uint32)(byteTable) & 0xFF) == 0)
    
    `$INSTANCE_NAME`_fifo_in_out_fifo_F0_CLEAR;
    `$INSTANCE_NAME`_fifo_in_out_fifo_F1_CLEAR;
    
    // set D0 to zero for use by DMA to clear control_reg
    `$INSTANCE_NAME`_fifo_in_out_fifo_D0_REG = 0;
   
    `$INSTANCE_NAME`_dma_ctrl = `$INSTANCE_NAME`_DMA_Ctrl_DmaInitialize(
                1 /* bytes/burst */, 
                1 /* rqst/burst */, 
                HI16(CYDEV_PERIPH_BASE), HI16(CYDEV_PERIPH_BASE));
                                                                        
    `$INSTANCE_NAME`_dma_data = `$INSTANCE_NAME`_DMA_Data_DmaInitialize(
                1 /* bytes/burst */, 
                1 /* rqst/burst */, 
                HI16(CYDEV_SRAM_BASE), HI16(CYDEV_PERIPH_BASE));
    
    `$INSTANCE_NAME`_dma_data_TD[1] = CyDmaTdAllocate();
    `$INSTANCE_NAME`_dma_data_TD[0] = CyDmaTdAllocate();
    `$INSTANCE_NAME`_dma_ctrl_TD[1] = CyDmaTdAllocate();
    `$INSTANCE_NAME`_dma_ctrl_TD[0] = CyDmaTdAllocate();
    
    // First ctrl TD loads the source byte from fifo0 into the lower order byte of the source address offset of data TD,
    // then autoexecutes next TD.
    CyDmaTdSetConfiguration(
                `$INSTANCE_NAME`_dma_ctrl_TD[0],
                1 /* transfer count */,
                `$INSTANCE_NAME`_dma_ctrl_TD[1], /* next TD */
                CY_DMA_TD_AUTO_EXEC_NEXT);
    CyDmaTdSetAddress(
                `$INSTANCE_NAME`_dma_ctrl_TD[0],
                LO16((uint32)`$INSTANCE_NAME`_fifo_in_out_fifo_F0_PTR),
                LO16((uint32)&DMAC_TDMEM[`$INSTANCE_NAME`_dma_data_TD[0]].TD1[0]));
    // Second TD clears the control register to disable ctrl_drq using the value of datapath register D0(0).
    CyDmaTdSetConfiguration(
                `$INSTANCE_NAME`_dma_ctrl_TD[1],
                1 /* transfer count */,
                `$INSTANCE_NAME`_dma_ctrl_TD[0], /* next TD - loop back*/
                `$INSTANCE_NAME`_DMA_Ctrl__TD_TERMOUT_EN);  // enable NRQ output to run data TDs
    CyDmaTdSetAddress(
                `$INSTANCE_NAME`_dma_ctrl_TD[1],
                LO16((uint32)`$INSTANCE_NAME`_fifo_in_out_fifo_D0_PTR),
                LO16((uint32)`$INSTANCE_NAME`_Control_Reg_Control_PTR));
                
    // The data TD loads a byte from the passed byteTable indexed by the inpute byte above,
    // copies it to fifo1, then autoexecutes next TD
    CyDmaTdSetConfiguration(
                `$INSTANCE_NAME`_dma_data_TD[0],
                1 /* transfer count */,
                `$INSTANCE_NAME`_dma_data_TD[1], /* next TD */
                CY_DMA_TD_AUTO_EXEC_NEXT);
    CyDmaTdSetAddress(
                `$INSTANCE_NAME`_dma_data_TD[0],
                LO16((uint32)byteTable),
                LO16((uint32)`$INSTANCE_NAME`_fifo_in_out_fifo_F1_PTR));
    // Second TD sets the control register to re-enable ctrl_drq
    CyDmaTdSetConfiguration(
                `$INSTANCE_NAME`_dma_data_TD[1],
                1 /* transfer count */,
                `$INSTANCE_NAME`_dma_data_TD[0], /* next TD - loop back*/
                0);  // no need to set NRQ.
    CyDmaTdSetAddress(
                `$INSTANCE_NAME`_dma_data_TD[1],
                LO16((uint32)`$INSTANCE_NAME`_control_reg_en_value),
                LO16((uint32)`$INSTANCE_NAME`_Control_Reg_Control_PTR));
    
    CyDmaChSetInitialTd(`$INSTANCE_NAME`_dma_ctrl, `$INSTANCE_NAME`_dma_ctrl_TD[0]);
    CyDmaChSetInitialTd(`$INSTANCE_NAME`_dma_data, `$INSTANCE_NAME`_dma_data_TD[0]);
}
    
void `$INSTANCE_NAME`_Enable()
{
    // Ensure that ctrl_drq_en is disabled.
   `$INSTANCE_NAME`_Control_Reg_Control = 0;

    CyDmaChEnable(`$INSTANCE_NAME`_dma_data, 1);    // preserve TD values
    CyDmaChEnable(`$INSTANCE_NAME`_dma_ctrl, 1);    // preserve TD values

    `$INSTANCE_NAME`_Control_Reg_Control = 1;       // enable ctrl_drq_en
}