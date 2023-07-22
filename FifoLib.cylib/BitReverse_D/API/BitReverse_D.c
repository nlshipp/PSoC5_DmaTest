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

/* BitReverse_D

   The implementation of a DMA based hardware bit reversal component where fifo0 of a datapath is used as the input
   and fifo1 is used as the output, this is common to all variants. No table lookup is used, but instead an output control 
   register is cross-wired with an input status register. The DMA simply reads the input FIFO and writes the value to the
   bit reversal control register, then the second TD is auto executed and reads the bit reversal status register and writes
   the value to the output fifo. This has minimal macrocell and P-term complexity, similar to variant C, and only has two
   DMA TDs both on the same channel. It may have more routing signal mesh requirements as there are 8 signal lines between
   the control and status registers.
*/

#include <cytypes.h>
#include <assert.h>
#include "`$INSTANCE_NAME`.h"
#include "`$INSTANCE_NAME`_DMA_Data_dma.h"
#include "`$INSTANCE_NAME`_Control_Reg_1.h"
#include "`$INSTANCE_NAME`_Status_Reg_1.h"
#include "`$INSTANCE_NAME`_fifo_in_out_defs.h"

uint8 `$INSTANCE_NAME`_dma_data;
uint8 `$INSTANCE_NAME`_dma_data_TD[2];

void `$INSTANCE_NAME`_Init()
{
    `$INSTANCE_NAME`_fifo_in_out_fifo_F0_CLEAR;
    `$INSTANCE_NAME`_fifo_in_out_fifo_F1_CLEAR;
    
    `$INSTANCE_NAME`_dma_data = `$INSTANCE_NAME`_DMA_Data_DmaInitialize(
                1 /* bytes/burst */, 
                1 /* rqst/burst */, 
                HI16(CYDEV_PERIPH_BASE), HI16(CYDEV_PERIPH_BASE));
                                                                        
    `$INSTANCE_NAME`_dma_data_TD[1] = CyDmaTdAllocate();
    `$INSTANCE_NAME`_dma_data_TD[0] = CyDmaTdAllocate();
    
    // The first data TD loads the source byte from fifo0 and writes it to the bit reversal control register
    CyDmaTdSetConfiguration(
                `$INSTANCE_NAME`_dma_data_TD[0],
                1 /* transfer count */,
                `$INSTANCE_NAME`_dma_data_TD[1], /* next TD */
                CY_DMA_TD_AUTO_EXEC_NEXT);
    CyDmaTdSetAddress(
                `$INSTANCE_NAME`_dma_data_TD[0],
                LO16((uint32)`$INSTANCE_NAME`_fifo_in_out_fifo_F0_PTR),
                LO16((uint32)`$INSTANCE_NAME`_Control_Reg_1_Control_PTR));
    
    // The second data TD loads the reversed bits from the status register and copies it to fifo1.
    CyDmaTdSetConfiguration(
                `$INSTANCE_NAME`_dma_data_TD[1],
                1 /* transfer count */,
                `$INSTANCE_NAME`_dma_data_TD[0], /* next TD - loop back */
                0);  // no special flags set
    CyDmaTdSetAddress(
                `$INSTANCE_NAME`_dma_data_TD[1],
                LO16((uint32)`$INSTANCE_NAME`_Status_Reg_1_Status_PTR),
                LO16((uint32)`$INSTANCE_NAME`_fifo_in_out_fifo_F1_PTR));
    
    CyDmaChSetInitialTd(`$INSTANCE_NAME`_dma_data, `$INSTANCE_NAME`_dma_data_TD[0]);
}
    
void `$INSTANCE_NAME`_Enable()
{
    CyDmaChEnable(`$INSTANCE_NAME`_dma_data, 1);    // preserve TD values
}

void `$INSTANCE_NAME`_Disable()
{
    CyDmaChDisable(`$INSTANCE_NAME`_dma_data);
}
