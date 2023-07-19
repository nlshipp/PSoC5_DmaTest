/* ========================================
 *
 * Copyright YOUR COMPANY, THE YEAR
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/
#include "project.h"
#include <stdio.h>

char print_buf[256];
#define DP(...) {sprintf(print_buf, __VA_ARGS__);UART_1_PutString(print_buf);}

int main(void)
{
    uint8 status;
    
    CyGlobalIntEnable; /* Enable global interrupts. */

    UART_1_Start();
    
    DP("PSOC FifoTest\n");
    
    DP("Clearing FIFOs\n");
    fifo_1_fifo_F0_CLEAR;
    fifo_1_fifo_F1_CLEAR;
    
    for(;;)
    {
        uint8 val;
        uint8 values[4] = {0x12, 0x34, 0x56, 0x78};
        
        DP("Reading FIFO status - empty\n");
        status = Status_Reg_1_Read();
        DP("Status = %02x\n", status);
        
        val = 0x88;
        DP("Writing single value %02x to FIFO0\n", val);
        fifo_1_fifo_F0_REG = val;
        
        status = Status_Reg_1_Read();
        DP("Status = %02x\n", status);
        
        val = 0;

        DP("Reading single value from FIFO0\n");
        val = fifo_1_fifo_F0_REG;

        status = Status_Reg_1_Read();
        DP("Status = %02x, value = %02x\n", status, val);
        
        DP("Filling fifo with %02x %02x %02x %02x\n", values[0], values[1], values[2], values[3]);
        for (int i = 0; i < 4; ++i) 
        {
            DP("Writing %02x\n", values[i]);
            fifo_1_fifo_F0_REG = values[i];
            
            status = Status_Reg_1_Read();
            DP("Status = %02x\n", status);
        }

        DP("Reading values back out\n");
        for (int i = 0; i < 4; ++i) 
        {
            DP("Reading value\n");
            val = fifo_1_fifo_F0_REG;
            
            status = Status_Reg_1_Read();
            DP("Status = %02x, value = %02x\n", status, val);
        }
        
        DP("Sleeping 10 seconds\n");
        CyDelay(10000);
    }
}

/* [] END OF FILE */
