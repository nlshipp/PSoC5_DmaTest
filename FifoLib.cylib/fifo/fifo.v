/*******************************************************************************
* Description:
*  Verilog implementation autogenerated from fifo.cyudb at 07/17/2023 19:40:27.
*
* Note:
*  This module definition will automatically be incorporated during the "HDL Generation"
*  phase of a design which uses this UDB document. 
*  Alternatively, the contents of this pane may be copied and used as a starting point
*  for a verilog component implementation. The Datapath Configuration Tool may be used
*  to adjust advanced datapath parameters (accessible from the Tools menu).
*  For more details, see the Component Author Guide and Technical Reference Manuals.
*  Both can be accessed by selecting Help -> Documentation.
*******************************************************************************/

`include "cypress.v"
/* ==================== Include Component Definitions ==================== */

module fifo (
    input wire clock, 
    output wire f0In,   // f0_not_full
    output wire f0Out,  // f0_empty
    output wire f1In,   // f1_not_full
    output wire f1Out   // f1_empty
);

/* ==================== Wire and Register Declarations ==================== */
wire f0NotFull;
wire f0Empty;
wire f1NotFull;
wire f1Empty;
wire fifo_d0_load;
wire fifo_d1_load;
wire fifo_f0_load;
wire fifo_f1_load;
wire fifo_route_si;
wire fifo_route_ci;
wire  [2:0] fifo_select;

/* ==================== Assignment of Combinatorial Variables ==================== */
assign f0In = (f0NotFull);
assign f0Out = (f0Empty);
assign f1In = (f1NotFull);
assign f1Out = (f1Empty);
assign fifo_d0_load = (1'b1);
assign fifo_d1_load = (1'b1);
assign fifo_f0_load = (1'b0);
assign fifo_f1_load = (1'b0);
assign fifo_route_si = (1'b0);
assign fifo_route_ci = (1'b0);
assign fifo_select[0] = (1'b0);
assign fifo_select[1] = (1'b0);
assign fifo_select[2] = (1'b0);

/* ==================== fifo (Width: 8) Instantiation ==================== */
parameter fifo_dpconfig0 = 
{
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC_NONE, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM0:  */
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC_NONE, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM1:  */
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC_NONE, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM2:  */
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC_NONE, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM3:  */
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC_NONE, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM4:  */
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC_NONE, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM5:  */
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC_NONE, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM6:  */
    `CS_ALU_OP_PASS, `CS_SRCA_A0, `CS_SRCB_D0, `CS_SHFT_OP_PASS, `CS_A0_SRC_NONE, `CS_A1_SRC_NONE, `CS_FEEDBACK_DSBL, `CS_CI_SEL_CFGA, `CS_SI_SEL_CFGA, `CS_CMP_SEL_CFGA,  /*CFGRAM7:  */
    8'hFF, 8'h00, /* CFG9 */
    8'hFF, 8'hFF, /* CFG11-10 */
    `SC_CMPB_A1_D1, `SC_CMPA_A0_D1, `SC_CI_B_ARITH, `SC_CI_A_ARITH, `SC_C1_MASK_DSBL, `SC_C0_MASK_DSBL, `SC_A_MASK_DSBL, `SC_DEF_SI_0, `SC_SI_B_DEFSI, `SC_SI_A_DEFSI, /* CFG13-12 */
    `SC_A0_SRC_ACC, `SC_SHIFT_SL, 1'b0, `SC_SR_SRC_REG, `SC_FIFO1_BUS, `SC_FIFO0_BUS, `SC_MSB_ENBL, `SC_MSB_BIT7, `SC_MSB_NOCHN, `SC_FB_NOCHN, `SC_CMP1_NOCHN, `SC_CMP0_NOCHN, /* CFG15-14 */
    3'b000, `SC_FIFO_SYNC_NONE, 2'b000, `SC_FIFO1_DYN_ON, `SC_FIFO0_DYN_ON, `SC_FIFO_CLK1_POS, `SC_FIFO_CLK0_POS, `SC_FIFO_CLK__DP, `SC_FIFO_CAP_AX, `SC_FIFO_LEVEL, `SC_FIFO__SYNC, `SC_EXTCRC_DSBL, `SC_WRK16CAT_DSBL /* CFG17-16 */
};
cy_psoc3_dp8 #(
    .cy_dpconfig_a( fifo_dpconfig0 ),
    .d0_init_a( 8'b00000000 ),
    .d1_init_a( 8'b00000000 ),
    .a0_init_a( 8'b00000000 ),
    .a1_init_a( 8'b00000000 ))
    fifo(
        .clk( clock ),
        .cs_addr( fifo_select ),
        .route_si( fifo_route_si ),
        .route_ci( fifo_route_ci ),
        .f0_load( fifo_f0_load ),
        .f1_load( fifo_f1_load ),
        .d0_load( fifo_d0_load ),
        .d1_load( fifo_d1_load ),
        .ce0(  ), 
        .cl0(  ), 
        .z0(  ), 
        .ff0(  ), 
        .ce1(  ), 
        .cl1(  ), 
        .z1(  ), 
        .ff1(  ), 
        .ov_msb(  ), 
        .co_msb(  ), 
        .cmsb(  ), 
        .so(  ), 
        .f0_bus_stat( f0NotFull ), 
        .f0_blk_stat( f0Empty ), 
        .f1_bus_stat( f1NotFull ), 
        .f1_blk_stat( f1Empty )
    );

endmodule
