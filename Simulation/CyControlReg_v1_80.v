/*******************************************************************************
* File Name:  CyControlReg_v1_80.v
*
* Description:
*  Verilog file for the Control Register. Assigns value to nets.
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

module CyControlReg_v1_80 (
        input wire clock,
        input wire reset,
        output wire control_0,
        output wire control_1,
        output wire control_2,
        output wire control_3,
        output wire control_4,
        output wire control_5,
        output wire control_6,
        output wire control_7,
        output wire [7:0] control_bus
);

    parameter NumOutputs = 8;
    localparam DEFAULT_BUSVAL = 1'b0;
    parameter BusDisplay = DEFAULT_BUSVAL;

    wire [7:0] control;

    localparam SEL_MODE_DIRECT  = 2'd0;
    localparam SEL_MODE_SYNC    = 2'd1;
    localparam SEL_MODE_PULSE   = 2'd3;
    parameter [1:0] Bit0Mode    = SEL_MODE_DIRECT;
    parameter [1:0] Bit1Mode    = SEL_MODE_DIRECT;
    parameter [1:0] Bit2Mode    = SEL_MODE_DIRECT;
    parameter [1:0] Bit3Mode    = SEL_MODE_DIRECT;
    parameter [1:0] Bit4Mode    = SEL_MODE_DIRECT;
    parameter [1:0] Bit5Mode    = SEL_MODE_DIRECT;
    parameter [1:0] Bit6Mode    = SEL_MODE_DIRECT;
    parameter [1:0] Bit7Mode    = SEL_MODE_DIRECT;

    localparam DEFAULT_BITVALUE = 8'b0;
    parameter [7:0] BitValue = DEFAULT_BITVALUE;

    localparam DEFAULT_RESET = 1'b0;
    parameter  ExtrReset = DEFAULT_RESET;

    localparam ExtReset = ExtrReset;

    localparam [7:0] ModeMask0 = (NumOutputs == 8) ? ({Bit7Mode[0], Bit6Mode[0], Bit5Mode[0], Bit4Mode[0], Bit3Mode[0],
                                                        Bit2Mode[0], Bit1Mode[0], Bit0Mode[0]}) :
                                 (NumOutputs == 7) ? ({1'b0, Bit6Mode[0], Bit5Mode[0], Bit4Mode[0], Bit3Mode[0],
                                                        Bit2Mode[0], Bit1Mode[0], Bit0Mode[0]}) :
                                 (NumOutputs == 6) ? ({1'b0, 1'b0, Bit5Mode[0], Bit4Mode[0], Bit3Mode[0], Bit2Mode[0],
                                                        Bit1Mode[0], Bit0Mode[0]}) :
                                 (NumOutputs == 5) ? ({1'b0, 1'b0, 1'b0, Bit4Mode[0], Bit3Mode[0], Bit2Mode[0], Bit1Mode[0],
                                                        Bit0Mode[0]}) :
                                 (NumOutputs == 4) ? ({1'b0, 1'b0, 1'b0, 1'b0, Bit3Mode[0], Bit2Mode[0], Bit1Mode[0],
                                                        Bit0Mode[0]}) :
                                 (NumOutputs == 3) ? ({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, Bit2Mode[0], Bit1Mode[0], Bit0Mode[0]}) :
                                 (NumOutputs == 2) ? ({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, Bit1Mode[0], Bit0Mode[0]}) :
                                 ({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, Bit0Mode[0]});

    localparam [7:0] ModeMask1 = (NumOutputs == 8) ? ({Bit7Mode[1], Bit6Mode[1], Bit5Mode[1], Bit4Mode[1], Bit3Mode[1],
                                                        Bit2Mode[1], Bit1Mode[1], Bit0Mode[1]}) :
                                 (NumOutputs == 7) ? ({1'b0, Bit6Mode[1], Bit5Mode[1], Bit4Mode[1], Bit3Mode[1],
                                                        Bit2Mode[1], Bit1Mode[1], Bit0Mode[1]}) :
                                 (NumOutputs == 6) ? ({1'b0, 1'b0, Bit5Mode[1], Bit4Mode[1], Bit3Mode[1], Bit2Mode[1],
                                                        Bit1Mode[1], Bit0Mode[1]}) :
                                 (NumOutputs == 5) ? ({1'b0, 1'b0, 1'b0, Bit4Mode[1], Bit3Mode[1], Bit2Mode[1], Bit1Mode[1],
                                                        Bit0Mode[1]}) :
                                 (NumOutputs == 4) ? ({1'b0, 1'b0, 1'b0, 1'b0, Bit3Mode[1], Bit2Mode[1], Bit1Mode[1],
                                                        Bit0Mode[1]}) :
                                 (NumOutputs == 3) ? ({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, Bit2Mode[1], Bit1Mode[1], Bit0Mode[1]}) :
                                 (NumOutputs == 2) ? ({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, Bit1Mode[1], Bit0Mode[1]}) :
                                 ({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, Bit0Mode[1]});

    wire clk = clock;
    wire rst = reset;

    localparam [7:0] bitval = (NumOutputs == 8) ? (BitValue & 8'b11111111) :
                              (NumOutputs == 7) ? (BitValue & 8'b01111111) : 
                              (NumOutputs == 6) ? (BitValue & 8'b00111111) : 
                              (NumOutputs == 5) ? (BitValue & 8'b00011111) : 
                              (NumOutputs == 4) ? (BitValue & 8'b00001111) :
                              (NumOutputs == 3) ? (BitValue & 8'b00000111) : 
                              (NumOutputs == 2) ? (BitValue & 8'b00000011) : 
                              (BitValue & 8'b00000001);

    wire [7:0] control_out;

    /***************************************************************************
    *                          Chip Member definition                          *
    ***************************************************************************/

    /* PSoC5A */
    localparam CY_UDB_V0 = (`CYDEV_CHIP_MEMBER_USED == `CYDEV_CHIP_MEMBER_5A);

    // output assignment
    generate 
        if(BusDisplay && NumOutputs > 1)
            begin: busOut
            assign control_bus = control_out;
        end
        else
            begin: bitwise
                assign control_0 = control_out[0];
                assign control_1 = control_out[1];
                assign control_2 = control_out[2];
                assign control_3 = control_out[3];
                assign control_4 = control_out[4];
                assign control_5 = control_out[5];
                assign control_6 = control_out[6];
                assign control_7 = control_out[7];
            end
        endgenerate

    // based on silicon, select the control register instantiation
    generate
        if (CY_UDB_V0) begin : Async
            cy_psoc3_control
            #(.cy_init_value(bitval), .cy_force_order(1))
            ctrl_reg(
                    /* output      */ .control(control)
                    );
        end
        else begin : Sync
            cy_psoc3_control
            #(.cy_init_value(bitval), .cy_force_order(1), .cy_ctrl_mode_0(ModeMask0), .cy_ctrl_mode_1(ModeMask1), 
              .cy_ext_reset(ExtReset))
            ctrl_reg(
                     /* input            */  .clock(clk),
                     /* input            */  .reset(rst),
                     /*  output  [07:00] */ .control(control)
                     );
        end
    endgenerate

    reg [7:0] sync_out;
    // to sync the output if mode bit is set as 'sync' and silicon selected is PSoC5A
    genvar i;
    generate 
        for (i = 0; i < 8 && i < NumOutputs; i = i + 1) begin 
            if (CY_UDB_V0 && (ModeMask0[i] == 2'd1 && ModeMask1[i] == 2'd0)) begin : SyncOutput
                always @(posedge clock)
                begin
                    sync_out[i] <= control[i];
                end
                assign control_out[i] = sync_out[i];
            end
            else begin : DirectOutput
                assign control_out[i] = control[i];  //direct output
            end
        end
    endgenerate

endmodule

