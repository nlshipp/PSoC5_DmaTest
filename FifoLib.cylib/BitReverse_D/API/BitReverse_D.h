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
#if !defined(BitReverse_D_`$INSTANCE_NAME`_H)
#define BitReverse_D_`$INSTANCE_NAME`_H

#define `$INSTANCE_NAME`_fifo_in `$INSTANCE_NAME`_fifo_in_out_fifo_F0_REG
#define `$INSTANCE_NAME`_fifo_out `$INSTANCE_NAME`_fifo_in_out_fifo_F1_REG

// Basic interface
void `$INSTANCE_NAME`_Init();
void `$INSTANCE_NAME`_Enable();

#endif

/* [] END OF FILE */
