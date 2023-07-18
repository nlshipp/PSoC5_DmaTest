/*******************************************************************************
* File Name:  CyStatusReg_v1_90.v
*
* Description:
*  Sets the value of a Status Register to match that of nets.
*
* Note:
*
********************************************************************************
* Copyright 2008-2012, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/

`include "cypress.v"

module CyStatusReg_v1_90 (
        input wire status_0,
        input wire status_1,
        input wire status_2,
        input wire status_3,
        input wire status_4,
        input wire status_5,
        input wire status_6,
        input wire status_7,
        input wire clock,
        input wire [7:0] status_bus,
        output wire intr
);

    parameter NumInputs = 8;
    wire [7:0] status;

    localparam DEFAULT_BUSVAL = 1'b0;
    parameter BusDisplay = DEFAULT_BUSVAL;

    localparam DEFAULT_INTR = 1'b0;
    parameter Interrupt = DEFAULT_INTR;

    generate
    if(BusDisplay && NumInputs > 1)
    begin
        assign status = status_bus;
    end
    else
    begin
        assign status[0] = status_0;
        assign status[1] = status_1;
        assign status[2] = status_2;
        assign status[3] = status_3;
        assign status[4] = status_4;
        assign status[5] = status_5;
        assign status[6] = status_6;
        assign status[7] = status_7;
    end
    endgenerate

    parameter [0:0] Bit0Mode = 0;
    parameter [0:0] Bit1Mode = 0;
    parameter [0:0] Bit2Mode = 0;
    parameter [0:0] Bit3Mode = 0;
    parameter [0:0] Bit4Mode = 0;
    parameter [0:0] Bit5Mode = 0;
    parameter [0:0] Bit6Mode = 0;
    parameter [0:0] Bit7Mode = 0;

    localparam DEFAULT_MASKVALUE = 127;
    parameter [7:0] MaskValue = DEFAULT_MASKVALUE;

    localparam intMask = MaskValue & ((1 << NumInputs) - 1);

    localparam ModeMask = (NumInputs == 8) ? ({Bit7Mode, Bit6Mode, Bit5Mode, Bit4Mode, Bit3Mode, Bit2Mode,
                                                        Bit1Mode, Bit0Mode}) :
                                (NumInputs == 7) ? ({1'b0, Bit6Mode, Bit5Mode, Bit4Mode, Bit3Mode, Bit2Mode, Bit1Mode,
                                                        Bit0Mode}) :
                                (NumInputs == 6) ? ({1'b0, 1'b0, Bit5Mode, Bit4Mode, Bit3Mode, Bit2Mode, Bit1Mode,
                                                        Bit0Mode}) :
                                (NumInputs == 5) ? ({1'b0, 1'b0, 1'b0, Bit4Mode, Bit3Mode, Bit2Mode, Bit1Mode, Bit0Mode}) :
                                (NumInputs == 4) ? ({1'b0, 1'b0, 1'b0, 1'b0, Bit3Mode, Bit2Mode, Bit1Mode, Bit0Mode}) :
                                (NumInputs == 3) ? ({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, Bit2Mode, Bit1Mode, Bit0Mode}) :
                                (NumInputs == 2) ? ({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, Bit1Mode, Bit0Mode}) :
                                ({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, Bit0Mode});

    generate
    if(Interrupt)
    begin : sts_intr
    cy_psoc3_statusi #(.cy_force_order(1), .cy_md_select(ModeMask), .cy_int_mask(intMask))
    sts_reg(
        /* input            */  .clock(clock),
        /* input    [06:00] */  .status({status[6], status[5], status[4], status[3], status[2], status[1], status[0]}),
        /* output           */  .interrupt(intr)
    );
    end
    else
    begin : sts
    cy_psoc3_status #(.cy_force_order(1), .cy_md_select(ModeMask))
    sts_reg(
        /* input            */  .clock(clock),
        /* input    [07:00] */  .status(status)
    );
    end
    endgenerate

endmodule

