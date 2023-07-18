/*******************************************************************************
* Copyright 2009, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/

//
//	PSoC 3 Data Path Element
//

`ifdef  CY_PSOC3_DP
    // Only include this module once
`else

`define CY_PSOC3_DP
`include "cy_psoc3_inc.v"
`ifdef WARP
`else

module cy_psoc3_dp (
		    // Input Signals
		    reset, clk, cs_addr, route_si, route_ci,
		    f0_load, f1_load, d0_load, d1_load,
		    // Output Signals
		    ce0, cl0, z0, ff0, ce1, cl1, z1, ff1,
		    ov_msb, co_msb, cmsb, so,
		    f0_bus_stat, f0_blk_stat, f1_bus_stat, f1_blk_stat,
		    // Registered Output Signals
		    ce0_reg, cl0_reg, z0_reg, ff0_reg, ce1_reg, cl1_reg,
		    z1_reg, ff1_reg, ov_msb_reg, co_msb_reg, cmsb_reg,
		    so_reg, f0_bus_stat_reg, f0_blk_stat_reg,
		    f1_bus_stat_reg, f1_blk_stat_reg,
		    // Chain Signals
		    ci, co, sir, sor, sil, sol, msbi, msbo,
		    cei, ceo, cli, clo, zi, zo, fi, fo,
		    capi, capo, cfbi, cfbo, pi, po);

    // Input Signals
    input		reset;		// Routed Reset
    input		clk;		// Clock
    input	[02:00]	cs_addr;	// Control Store RAM address
    input		route_si;	// Shift in from routing
    input		route_ci;	// Carry in from routing
    input		f0_load;	// Load FIFO 0
    input		f1_load;	// Load FIFO 1
    input		d0_load;	// Load Data Register 0
    input		d1_load;	// Load Data Register 1

    // Output Signals
    output		ce0;		// Accumulator 0 = Data register 0
    output		cl0;		// Accumulator 0 < Data register 0
    output		z0;		// Accumulator 0 = 0
    output		ff0;		// Accumulator 0 = FF
    output		ce1;		// Accumulator [0|1] = Data register 1
    output		cl1;		// Accumulator [0|1] < Data register 1
    output		z1;		// Accumulator 1 = 0
    output		ff1;		// Accumulator 1 = FF
    output		ov_msb;		// Operation over flow
    output		co_msb;		// Carry out
    output		cmsb;		// Carry out
    output		so;		// Shift out
    output		f0_bus_stat;	// FIFO 0 status to uP
    output		f0_blk_stat;	// FIFO 0 status to DP
    output		f1_bus_stat;	// FIFO 1 status to uP
    output		f1_blk_stat;	// FIFO 1 status to DP
    // Registered Output Signals
    output		ce0_reg;	// Accumulator 0 = Data register 0
    output		cl0_reg;	// Accumulator 0 < Data register 0
    output		z0_reg;		// Accumulator 0 = 0
    output		ff0_reg;	// Accumulator 0 = FF
    output		ce1_reg;	// Accumulator [0|1] = Data register 1
    output		cl1_reg;	// Accumulator [0|1] < Data register 1
    output		z1_reg;		// Accumulator 1 = 0
    output		ff1_reg;	// Accumulator 1 = FF
    output		ov_msb_reg;	// Operation over flow
    output		co_msb_reg;	// Carry out
    output		cmsb_reg;	// Carry out
    output		so_reg;		// Shift out
    output		f0_bus_stat_reg;// FIFO 0 status to uP
    output		f0_blk_stat_reg;// FIFO 0 status to DP
    output		f1_bus_stat_reg;// FIFO 1 status to uP
    output		f1_blk_stat_reg;// FIFO 1 status to DP

    // Chain Signals
    input		ci;		// Carry in from previous stage
    output		co;		// Carry out to next stage
    input		sir;		// Shift in from right side
    output		sor;		// Shift out to right side
    input		sil;		// Shift in from left side
    output		sol;		// Shift out to left side
    input		msbi;		// MSB chain in
    output		msbo;		// MSB chain out
    input	[01:00]	cei;		// Compare equal in from previous stage
    output	[01:00]	ceo;		// Compare equal out to next stage
    input	[01:00]	cli;		// Compare less than in from prev stage
    output	[01:00]	clo;		// Compare less than out to next stage
    input	[01:00]	zi;		// Zero detect in from previous stage
    output	[01:00]	zo;		// Zero detect out to next stage
    input	[01:00]	fi;		// 0xFF detect in from previous stage
    output	[01:00]	fo;		// 0xFF detect out to next stage
    input	[01:00]	capi;		// Software capture from previous stage
    output	[01:00]	capo;		// Software capture to next stage
    input		cfbi;		// CRC/PRS feedback chain in
    output		cfbo;		// CRC/PRS feedback chain out
    input	[07:00] pi;		// Parallel data port
    output	[07:00] po;		// Parallel data port

    // Get the parameters and load them into the model
    parameter	[207:0] cy_dpconfig		= {128'h0,32'hFF00_FFFF,48'h0};
    parameter	[07:00]	d0_init			= 8'b0;
    parameter	[07:00]	d1_init			= 8'b0;
    parameter	[07:00]	a0_init			= 8'b0;
    parameter	[07:00]	a1_init			= 8'b0;

    // These parameters determine the mode (sync or async) of the outputs
    parameter		ce0_sync		= 1'b1;
    parameter		cl0_sync		= 1'b1;
    parameter		z0_sync			= 1'b1;
    parameter		ff0_sync		= 1'b1;
    parameter		ce1_sync		= 1'b1;
    parameter		cl1_sync		= 1'b1;
    parameter		z1_sync			= 1'b1;
    parameter		ff1_sync		= 1'b1;
    parameter		ov_msb_sync		= 1'b1;
    parameter		co_msb_sync		= 1'b1;
    parameter		cmsb_sync		= 1'b1;
    parameter		so_sync			= 1'b1;
    parameter		f0_bus_sync		= 1'b1;
    parameter		f0_blk_sync		= 1'b1;
    parameter		f1_bus_sync		= 1'b1;
    parameter		f1_blk_sync		= 1'b1;

    // Internal Registers
    reg		[07:00]	scr4;			// CFG9
    reg		[15:00]	scr5;			// CFG10 & CFG11
    reg		[15:00]	scr6;			// CFG12 & CFG13
    reg		[15:00]	scr7;			// CFG14 & CFG15
    reg		[15:00]	scr8;			// CFG16 & CFG17
    reg		[07:00] reg_a0;			// Accumulator 0
    reg		[07:00] reg_a1;			// Accumulator 1
    reg		[07:00] reg_d0;			// Data Register 0
    reg		[07:00] reg_d1;			// Data Register 1

    // Internal signals
    wire		fifo0_bus_stat;		// FIFO 0 status to CPU
    wire		fifo0_blk_stat;		// FIFO 0 status to UDB
    wire		fifo1_bus_stat;		// FIFO 1 status to CPU
    wire		fifo1_blk_stat;		// FIFO 1 status to UDB
    wire	[07:00] mask_out;		// Final ALU output
    wire	[07:00] fifo0_data_out;		// FIFO 0 data output
    wire	[07:00] fifo1_data_out;		// FIFO 1 data output

    // Dynamic Configuration Registers (Control Store)			// Done
    integer addr_i;
    reg [15:00] cs_mem [07:00];
    initial
    begin
    	for (addr_i = 7 ; addr_i >= 0 ; addr_i = addr_i - 1)
	begin
	    cs_mem[7-addr_i] = cy_dpconfig >> addr_i * 16 + 80;
	    # 10;
	end
    end

    // Break out the dynamic control signals
    wire	[15:00]	ctrl_word = cs_mem[cs_addr];
    wire	[02:00]	alu_op    = ctrl_word[`CS_ALU_OP];
    wire		alu_srcA  = ctrl_word[`CS_SRCA];
    wire	[01:00]	alu_srcB  = ctrl_word[`CS_SRCB];
    wire	[01:00]	shift_op  = ctrl_word[`CS_SHFT_OP];
    wire	[01:00]	wr_src_a0 = ctrl_word[`CS_A0_SRC];
    wire	[01:00]	wr_src_a1 = ctrl_word[`CS_A1_SRC];
    wire		fb_enable = ctrl_word[`CS_FEEDBACK];
    wire		ci_chain  = ctrl_word[`CS_CI_SEL];
    wire		si_chain  = ctrl_word[`CS_SI_SEL];
    wire		cmp_sel   = ctrl_word[`CS_CMP_SEL];

    // Static Configuration Registers					// Done
    initial
    begin
    	scr4 = cy_dpconfig [79:72];
	    // cy_dpconfig [71:64] is the unused lower portion of reg4.
    	scr5 = cy_dpconfig [63:48];
    	scr6 = cy_dpconfig [47:32];
    	scr7 = cy_dpconfig [31:16];
    	scr8 = cy_dpconfig [15:00];
    end

    // Use these signals for the "simulated" CPU accesses
    reg	[07:00]	aux_ctrl     = 0;	// Auxilliary control register
    reg		cpu_clock    = 0;	// CPU clock
    reg	[07:00]	cpu_data;		// CPU data to the FIFOs
    wire[07:00] cpu_data_out0 = fifo0_data_out;	// FIFO0 data back to CPU
    wire[07:00] cpu_data_out1 = fifo1_data_out;	// FIFO1 data back to CPU

    // These are internal signals that are manipulated by the task calls
    reg		cpu_fifo_rd0 = 0;	// CPU FIFO0 read access enable
    reg		cpu_fifo_wr0 = 0;	// CPU FIFO0 write access enable
    reg		cpu_fifo_rd1 = 0;	// CPU FIFO1 read access enable
    reg		cpu_fifo_wr1 = 0;	// CPU FIFO1 read access enable
    reg		cpu_read_a0  = 0;	// Special signal used while reading A0
    reg		cpu_read_a1  = 0;	// Special signal used while reading A1

    // Break out the signals from the "simulated" auxilliary control register
    wire fifo0_clr = aux_ctrl[00];
    wire fifo1_clr = aux_ctrl[01];
    wire fifo0_lvl = aux_ctrl[02];
    wire fifo1_lvl = aux_ctrl[03];
    wire int_en    = aux_ctrl[04];
    wire cnt_start = aux_ctrl[05];

    // Use these tasks to read and write the data path registers
    // Write to FIFO 0
    task fifo0_write;
    	input	[07:00]	data;
    begin
	// Wait for the FIFO to be ready to be written to ....
	wait (f0_bus_stat == 1)
	// .... assert the strobe for a full cycle ....
    	@(posedge cpu_clock);
	cpu_fifo_wr0 = 1'b1;
	cpu_data = data;
    	@(posedge cpu_clock);
	cpu_fifo_wr0 = 1'b0;
    end
    endtask

    // Read from FIFO 0
    task fifo0_read;
    	output	[07:00] data;
    begin
	// Wait for the FIFO to be ready to be read from ....
	wait (f0_bus_stat == 1)
	// .... assert the strobe for a full cycle ....
    	@(posedge cpu_clock);
	#0 cpu_fifo_rd0 = 1'b1;
    	@(posedge cpu_clock);
	#0 cpu_fifo_rd0 = 1'b0;
	data = cpu_data_out0;
    end
    endtask

    // Write to FIFO 1
    task fifo1_write;
    	input	[07:00]	data;
    begin
	// Wait for the FIFO to be ready to be written to ....
	wait (f1_bus_stat == 1)
	// .... assert the strobe for a full cycle ....
    	@(posedge cpu_clock);
	cpu_fifo_wr1 = 1'b1;
	cpu_data = data;
    	@(posedge cpu_clock);
	cpu_fifo_wr1 = 1'b0;
    end
    endtask

    // Read from FIFO 1
    task fifo1_read;
    	output	[07:00] data;
    begin
	// Wait for the FIFO to be ready to be read from ....
	wait (f1_bus_stat == 1)
	// .... assert the strobe for a full cycle ....
    	@(posedge cpu_clock);
	#0 cpu_fifo_rd1 = 1'b1;
    	@(posedge cpu_clock);
	#0 cpu_fifo_rd1 = 1'b0;
	data = cpu_data_out1;
    end
    endtask

    // Write to Register A0
    task a0_write;
    	input	[07:00]	data;
    begin
	// .... assert the signals for a full cycle ....
    	@(posedge cpu_clock);
	force reg_a0 = data;
    	@(posedge cpu_clock);
	release reg_a0;
    end
    endtask

    // Read from Register A0
    task a0_read;
    	output	[07:00] data;
    begin
	// .... read for a full cycle ....
    	@(posedge cpu_clock);
	cpu_read_a0 = 1;
    	@(posedge cpu_clock);
	cpu_read_a0 = 0;
	data = reg_a0;
    end
    endtask

    // Write to Register A1
    task a1_write;
    	input	[07:00]	data;
    begin
	// .... assert the signals for a full cycle ....
    	@(posedge cpu_clock);
	force reg_a1 = data;
    	@(posedge cpu_clock);
	release reg_a1;
    end
    endtask

    // Read from Register A1
    task a1_read;
    	output	[07:00] data;
    begin
	// .... read for a full cycle ....
    	@(posedge cpu_clock);
	cpu_read_a1 = 1;
    	@(posedge cpu_clock);
	cpu_read_a1 = 0;
	data = reg_a1;
    end
    endtask

    // Write to Register D0
    task d0_write;
    	input	[07:00]	data;
    begin
	// .... assert the signals for a full cycle ....
    	@(posedge cpu_clock);
	force reg_d0 = data;
    	@(posedge cpu_clock);
	release reg_d0;
    end
    endtask

    // Read from Register D0
    task d0_read;
    	output	[07:00] data;
    begin
	// .... read for a full cycle ....
    	@(posedge cpu_clock);
    	@(posedge cpu_clock);
	data = reg_d0;
    end
    endtask

    // Write to Register D1
    task d1_write;
    	input	[07:00]	data;
    begin
	// .... assert the signals for a full cycle ....
    	@(posedge cpu_clock);
	force reg_d1 = data;
    	@(posedge cpu_clock);
	release reg_d1;
    end
    endtask

    // Read from Register D1
    task d1_read;
    	output	[07:00] data;
    begin
	// .... read for a full cycle ....
    	@(posedge cpu_clock);
    	@(posedge cpu_clock);
	data = reg_d1;
    end
    endtask

    // Initialize the DP registers
    initial
    begin
	reg_d0 = d0_init;
	reg_d1 = d1_init;
	reg_a0 = a0_init;
	reg_a1 = a1_init;
    end

    // Do we use the DP clock or the CPU clock on the FIFOs and which polarity?
    wire fifo_clk = (scr8[`SC_FIFO_CLK] == `SC_FIFO_CLK_BUS) ? cpu_clock : clk;
    wire writ_clk_0 = (scr8[`SC_FIFO_CLK0] == `SC_FIFO_CLK0_POS) ?
							fifo_clk : ~fifo_clk;
    wire writ_clk_1 = (scr8[`SC_FIFO_CLK1] == `SC_FIFO_CLK1_POS) ?
							fifo_clk : ~fifo_clk;
    wire read_clk_0  = (scr8[`SC_FIFO_CLK0] == `SC_FIFO_CLK0_POS) ? clk : ~clk;
    wire read_clk_1  = (scr8[`SC_FIFO_CLK1] == `SC_FIFO_CLK1_POS) ? clk : ~clk;

    // Generate the input signals to the basic FIFO for FIFO 0.
    reg f0_load_dly;
    always @(posedge writ_clk_0) f0_load_dly <= f0_load;
    wire bus_wr_en0 = cpu_fifo_wr0 | capo[00];
    wire blk_wr_en0 = f0_load & ~f0_load_dly;

    assign capo[00] =	(scr8[`SC_FIFO_CAP]   & cpu_read_a0) |
			(scr7[`SC_CMP0_CHAIN] & capi[00]);
    wire fifo0_rd_clk = (scr8[`SC_FIFO0_DYN] == `SC_FIFO0_DYN_ON) &
							 d0_load? cpu_clock :
			(scr8[`SC_FIFO0_DYN] == `SC_FIFO0_DYN_ON) &
							~d0_load? read_clk_0 :
			(scr7[`SC_FIFO0_SRC] != `SC_FIFO0_BUS)  ? cpu_clock :
								  read_clk_0;
    wire fifo0_wr_clk = (scr8[`SC_FIFO0_DYN] == `SC_FIFO0_DYN_ON) &
							 d0_load? cpu_clock :
			(scr8[`SC_FIFO0_DYN] == `SC_FIFO0_DYN_ON) &
							~d0_load? writ_clk_0 :
			(scr7[`SC_FIFO0_SRC] == `SC_FIFO0_BUS)  ? cpu_clock :
								  writ_clk_0;
    wire fifo0_rd_en  = (scr8[`SC_FIFO0_DYN] == `SC_FIFO0_DYN_ON) &
							 d0_load? cpu_fifo_rd0 :
			(scr8[`SC_FIFO0_DYN] == `SC_FIFO0_DYN_ON) &
							~d0_load?
				     (wr_src_a0 == `CS_A0_SRC___F0) :
			(scr7[`SC_FIFO0_SRC] != `SC_FIFO0_BUS)  ? cpu_fifo_rd0 :
				    ((wr_src_a0 == `CS_A0_SRC___F0) | d0_load);
    wire fifo0_wr_en  = (scr8[`SC_FIFO0_DYN] == `SC_FIFO0_DYN_ON) &
							 d0_load? bus_wr_en0 :
			(scr8[`SC_FIFO0_DYN] == `SC_FIFO0_DYN_ON) &
							~d0_load? blk_wr_en0 :
			(scr7[`SC_FIFO0_SRC] == `SC_FIFO0_BUS)  ? bus_wr_en0 :
			(scr8[`SC_FIFO_TRIG] == `SC_FIFO_LEVEL) ? f0_load :
								  blk_wr_en0;

    wire [07:00] fifo0_data_in =
			(scr8[`SC_FIFO0_DYN] == `SC_FIFO0_DYN_ON) &
			(d0_load)                              ? cpu_data :
			(capo[00])                             ? reg_a0 :
			(scr7[`SC_FIFO0_SRC] == `SC_FIFO0_BUS) ? cpu_data :
			(scr7[`SC_FIFO0_SRC] == `SC_FIFO0__A0) ? reg_a0 :
			(scr7[`SC_FIFO0_SRC] == `SC_FIFO0__A1) ? reg_a1 :
			(scr7[`SC_FIFO0_SRC] == `SC_FIFO0_ALU) ? mask_out :8'bX;

    wire [01:00] fifo0_mode = (scr8[`SC_FIFO0_DYN] == `SC_FIFO0_DYN_ON) ?
			    (d0_load) ? 2'b00 : 2'b11 : (scr7[`SC_FIFO0_SRC]);

    DP_FIFO FIFO0 ( .fifo_mode		(fifo0_mode),
		    .fifo_clr		(fifo0_clr),
		    .fifo_lvl		(fifo0_lvl),
		    .fifo_rd_clock	(fifo0_rd_clk),
		    .fifo_wr_clock	(fifo0_wr_clk),
		    .fifo_rd_enable	(fifo0_rd_en),
		    .fifo_wr_enable	(fifo0_wr_en),
		    .fifo_rd_data	(fifo0_data_out),
		    .fifo_wr_data	(fifo0_data_in),
		    .fifo_blk_stat	(fifo0_blk_stat),
		    .fifo_bus_stat	(fifo0_bus_stat));

    // Generate the input signals to the basic FIFO for FIFO 1.
    reg f1_load_dly;
    always @(posedge writ_clk_1) f1_load_dly <= f1_load;
    wire bus_wr_en1 = cpu_fifo_wr1 | capo[01];
    wire blk_wr_en1 = f1_load & ~f1_load_dly;

    assign capo[01] =   (scr8[`SC_FIFO_CAP]   & cpu_read_a1) |
			(scr7[`SC_CMP1_CHAIN] & capi[01]);
    wire fifo1_rd_clk = (scr8[`SC_FIFO1_DYN] == `SC_FIFO1_DYN_ON) &
							 d1_load? cpu_clock :
			(scr8[`SC_FIFO1_DYN] == `SC_FIFO1_DYN_ON) &
							~d1_load? read_clk_1 :
			(scr7[`SC_FIFO1_SRC] != `SC_FIFO1_BUS)  ? cpu_clock :
								  read_clk_1;
    wire fifo1_wr_clk = (scr8[`SC_FIFO1_DYN] == `SC_FIFO1_DYN_ON) &
							 d1_load? cpu_clock :
			(scr8[`SC_FIFO1_DYN] == `SC_FIFO1_DYN_ON) &
							~d1_load? writ_clk_1 :
			(scr7[`SC_FIFO1_SRC] == `SC_FIFO1_BUS)  ? cpu_clock :
								  writ_clk_1;
    wire fifo1_rd_en  = (scr8[`SC_FIFO1_DYN] == `SC_FIFO1_DYN_ON) &
							 d1_load? cpu_fifo_rd1 :
			(scr8[`SC_FIFO1_DYN] == `SC_FIFO1_DYN_ON) &
							~d1_load?
				     (wr_src_a1 == `CS_A1_SRC___F1) :
			(scr7[`SC_FIFO1_SRC] != `SC_FIFO1_BUS)  ? cpu_fifo_rd1 :
				    ((wr_src_a1 == `CS_A1_SRC___F1) | d1_load);
    wire fifo1_wr_en  = (scr8[`SC_FIFO1_DYN] == `SC_FIFO1_DYN_ON) &
							 d1_load? bus_wr_en1 :
			(scr8[`SC_FIFO1_DYN] == `SC_FIFO1_DYN_ON) &
							~d1_load? blk_wr_en1 :
			(scr7[`SC_FIFO1_SRC] == `SC_FIFO1_BUS)  ? bus_wr_en1 :
			(scr8[`SC_FIFO_TRIG] == `SC_FIFO_LEVEL) ? f1_load :
								  blk_wr_en1;
    wire [07:00] fifo1_data_in =
			(scr8[`SC_FIFO1_DYN] == `SC_FIFO1_DYN_ON) &
			(d1_load)                              ? cpu_data :
			(capo[01])                             ? reg_a1 :
			(scr7[`SC_FIFO1_SRC] == `SC_FIFO1_BUS) ? cpu_data :
			(scr7[`SC_FIFO1_SRC] == `SC_FIFO1__A0) ? reg_a0 :
			(scr7[`SC_FIFO1_SRC] == `SC_FIFO1__A1) ? reg_a1 :
			(scr7[`SC_FIFO1_SRC] == `SC_FIFO1_ALU) ? mask_out :8'bX;

    wire [01:00] fifo1_mode = (scr8[`SC_FIFO1_DYN] == `SC_FIFO1_DYN_ON) ?
			    (d1_load) ? 2'b00 : 2'b11 : (scr7[`SC_FIFO1_SRC]);

    DP_FIFO FIFO1 ( .fifo_mode		(fifo1_mode),
		    .fifo_clr		(fifo1_clr),
		    .fifo_lvl		(fifo1_lvl),
		    .fifo_rd_clock	(fifo1_rd_clk),
		    .fifo_wr_clock	(fifo1_wr_clk),
		    .fifo_rd_enable	(fifo1_rd_en),
		    .fifo_wr_enable	(fifo1_wr_en),
		    .fifo_rd_data	(fifo1_data_out),
		    .fifo_wr_data	(fifo1_data_in),
		    .fifo_blk_stat	(fifo1_blk_stat),
		    .fifo_bus_stat	(fifo1_bus_stat));

    // Write to the data path registers
    always @(posedge clk)
    begin
    	if (d0_load && (scr8[`SC_FIFO0_DYN] != `SC_FIFO0_DYN_ON))
	    reg_d0 <= fifo0_data_out;
    	if (d1_load && (scr8[`SC_FIFO1_DYN] != `SC_FIFO1_DYN_ON))
	    reg_d1 <= fifo1_data_out;
    end

    // Compare 1 inputs select
    wire [07:00] cmp1_la= (scr6[`SC_CMPA] == `SC_CMPA_A0_A0) ? reg_a0 :
			  (scr6[`SC_CMPA] == `SC_CMPA_A0_D1) ? reg_a0 :
			  (scr6[`SC_CMPA] == `SC_CMPA_A1_A0) ? reg_a1 :
			  (scr6[`SC_CMPA] == `SC_CMPA_A1_D1) ? reg_a1 : 8'bX;
    wire [07:00] cmp1_lb= (scr6[`SC_CMPB] == `SC_CMPB_A0_A0) ? reg_a0 :
			  (scr6[`SC_CMPB] == `SC_CMPB_A0_D1) ? reg_a0 :
			  (scr6[`SC_CMPB] == `SC_CMPB_A1_A0) ? reg_a1 :
			  (scr6[`SC_CMPB] == `SC_CMPB_A1_D1) ? reg_a1 : 8'bX;
    wire [07:00] cmp1_ra= (scr6[`SC_CMPA] == `SC_CMPA_A0_A0) ? reg_a0 :
			  (scr6[`SC_CMPA] == `SC_CMPA_A0_D1) ? reg_d1 :
			  (scr6[`SC_CMPA] == `SC_CMPA_A1_A0) ? reg_a0 :
			  (scr6[`SC_CMPA] == `SC_CMPA_A1_D1) ? reg_d1 : 8'bX;
    wire [07:00] cmp1_rb= (scr6[`SC_CMPB] == `SC_CMPB_A0_A0) ? reg_a0 :
			  (scr6[`SC_CMPB] == `SC_CMPB_A0_D1) ? reg_d1 :
			  (scr6[`SC_CMPB] == `SC_CMPB_A1_A0) ? reg_a0 :
			  (scr6[`SC_CMPB] == `SC_CMPB_A1_D1) ? reg_d1 : 8'bX;

    wire [07:00] cmp1_r = (cmp_sel) ? cmp1_rb : cmp1_ra;
    wire [07:00] cmp1_l = (cmp_sel) ? cmp1_lb : cmp1_la;

    // Compare masking
    wire [07:00] msk_c0 = (scr6[`SC_C0_MASK] == `SC_C0_MASK_ENBL) ?
						(reg_a0 & scr5[07:00]) : reg_a0;
    wire [07:00] msk_c1 = (scr6[`SC_C1_MASK] == `SC_C1_MASK_ENBL) ?
						(cmp1_l & scr5[15:08]) : cmp1_l;

    // Comparator chain input selection
    wire [03:00] cmp_in_a0 = (scr7[`SC_CMP0_CHAIN] == `SC_CMP0_CHNED) ?
			      {fi[0], zi[0], cli[0], cei[0]} : 4'b1101;
    wire [03:00] cmp_in_a1 = (scr7[`SC_CMP1_CHAIN] == `SC_CMP1_CHNED) ?
			      {fi[1], zi[1], cli[1], cei[1]} : 4'b1101;

    // Comparators
    assign ceo[00] = ((msk_c0 == reg_d0) && cmp_in_a0[00]) ? 1 : 0;
    assign clo[00] = ((msk_c0 <  reg_d0) ||(cmp_in_a0[01] &&
		      (msk_c0 == reg_d0))) ? 1 : 0;
    assign zo[00]  = ((reg_a0 == 8'h00)  && cmp_in_a0[02]) ? 1 : 0;
    assign fo[00]  = ((reg_a0 == 8'hFF)  && cmp_in_a0[03]) ? 1 : 0;

    assign ceo[01] = ((msk_c1 == cmp1_r) && cmp_in_a1[00]) ? 1 : 0;
    assign clo[01] = ((msk_c1 <  cmp1_r) ||(cmp_in_a1[01] && 
		      (msk_c1 == cmp1_r))) ? 1 : 0;
    assign zo[01]  = ((reg_a1 == 8'h00)  && cmp_in_a1[02]) ? 1 : 0;
    assign fo[01]  = ((reg_a1 == 8'hFF)  && cmp_in_a1[03]) ? 1 : 0;

    // ALU Source A selection
    wire [07:00] pi_internal = pi;
    wire [07:00] sa_internal =  (alu_srcA == `CS_SRCA_A1) ? reg_a1 :
				(alu_srcA == `CS_SRCA_A0) ? reg_a0 : 8'bX;
    wire [07:00] srcA = ((scr7[`SC_A0_SRC] == `SC_A0_SRC_PIN) |
    			((scr7[`SC_PI_DYN] == `SC_PI_DYN_EN) & fb_enable))
						? pi_internal : sa_internal;
    wire [07:00] po   = sa_internal;

    // Feedback Enable configuration
    wire src_fb = (fb_enable) ? ((scr7[`SC_MSB] == `SC_MSB_DSBL) ? msbi :
					 srcA[scr7[`SC_MSB_VAL]]) : 1'b0;

    // CRC/PRS chain
    wire cfbo   = (scr7[`SC_FB__CHAIN] == `SC_FB_CHNED) ? cfbi :
		 ((scr8[`SC_EXTCRC]    == `SC_EXTCRC_ENBL) ? route_ci :
							      sir ^ msbo);

    // ALU Source B selection
    wire [07:00] srcB_inp = (alu_srcB == `CS_SRCB_D0) ? reg_d0 :
			    (alu_srcB == `CS_SRCB_D1) ? reg_d1 :
			    (alu_srcB == `CS_SRCB_A0) ? reg_a0 :
			    (alu_srcB == `CS_SRCB_A1) ? reg_a1 : 8'bX;

    wire [07:00] srcB = ((scr7[`SC_PI_DYN] < `SC_PI_DYN_EN) & fb_enable) ? (srcB_inp & {8{cfbo}}) : srcB_inp;

    // Other operations carry generation
    wire co;
    wire regis_ci = co;
    wire arith_ci = (alu_op == `CS_ALU_OP__INC) ? 1'b1 :
		    (alu_op == `CS_ALU_OP__DEC) ? 1'b0 :
		    (alu_op == `CS_ALU_OP__ADD) ? 1'b0 :
		    (alu_op == `CS_ALU_OP__SUB) ? 1'b1 : 1'bX;

    // ALU Carry Chain input selection
    wire ci_a = (scr6[`SC_CI_A] == `SC_CI_A_ARITH) ? arith_ci :
		(scr6[`SC_CI_A] == `SC_CI_A_REGIS) ? regis_ci :
		(scr6[`SC_CI_A] == `SC_CI_A_CHAIN) ? ci   :
		(scr6[`SC_CI_A] == `SC_CI_A_ROUTE) ? route_ci : 1'bX;
    wire ci_b = (scr6[`SC_CI_B] == `SC_CI_B_ARITH) ? arith_ci :
		(scr6[`SC_CI_B] == `SC_CI_B_REGIS) ? regis_ci :
		(scr6[`SC_CI_B] == `SC_CI_B_CHAIN) ? ci   :
		(scr6[`SC_CI_B] == `SC_CI_B_ROUTE) ? route_ci : 1'bX;
    wire ci_source = (ci_chain) ? ci_b : ci_a;

    // ALU Shift Left Chain input selection
    wire sol;
    wire regis_sil = sol;
    wire msb_si = (scr7[`SC_SR_SRC] ==`SC_SR_SRC_MSB) ? msbo : scr6[`SC_DEF_SI];
    wire s_l_a =(scr6[`SC_SI_A] == `SC_SI_A_DEFSI) ? msb_si :
		(scr6[`SC_SI_A] == `SC_SI_A_REGIS) ? regis_sil :
		(scr6[`SC_SI_A] == `SC_SI_A_CHAIN) ? sil :
		(scr6[`SC_SI_A] == `SC_SI_A_ROUTE) ? route_si : 1'bX;
    wire s_l_b =(scr6[`SC_SI_B] == `SC_SI_B_DEFSI) ? msb_si :
		(scr6[`SC_SI_B] == `SC_SI_B_REGIS) ? regis_sil :
		(scr6[`SC_SI_B] == `SC_SI_B_CHAIN) ? sil :
		(scr6[`SC_SI_B] == `SC_SI_B_ROUTE) ? route_si : 1'bX;
    wire s_l_source = (si_chain) ? s_l_b : s_l_a;

    // ALU Shift Right Chain input selection
    wire sor;
    wire regis_sir = sor;
    wire s_r_a =(scr6[`SC_SI_A] == `SC_SI_A_DEFSI) ? scr6[`SC_DEF_SI] :
		(scr6[`SC_SI_A] == `SC_SI_A_REGIS) ? regis_sir :
		(scr6[`SC_SI_A] == `SC_SI_A_CHAIN) ? sir ^ (src_fb & fb_enable):
		(scr6[`SC_SI_A] == `SC_SI_A_ROUTE) ? route_si : 1'bX;
    wire s_r_b =(scr6[`SC_SI_B] == `SC_SI_B_DEFSI) ? scr6[`SC_DEF_SI] :
		(scr6[`SC_SI_B] == `SC_SI_B_REGIS) ? regis_sir :
		(scr6[`SC_SI_B] == `SC_SI_B_CHAIN) ? sir ^ (src_fb & fb_enable):
		(scr6[`SC_SI_B] == `SC_SI_B_ROUTE) ? route_si : 1'bX;
    wire s_r_source = (si_chain) ? s_r_b : s_r_a;

    // Build the adder
    wire [07:00] Ain = srcA;
    wire [07:00] Bin = 
	    (alu_op == `CS_ALU_OP__INC) ? 8'h00 :
	    (alu_op == `CS_ALU_OP__DEC) ? 8'hFF :
	    (alu_op == `CS_ALU_OP__ADD) ?  srcB :
	    (alu_op == `CS_ALU_OP__SUB) ? ~srcB : 8'bX;

    wire [07:00] Cout;
    wire [07:00] Cin = {Cout[06:00], ci_source};
    wire [07:00] Sum = Ain[07:00] ^ Bin[07:00] ^ Cin[07:00];
    assign Cout =   (Ain[07:00] & Bin[07:00])|
		    (Ain[07:00] & Cin[07:00])|
		    (Bin[07:00] & Cin[07:00]);

    // Do the ALU operation
    wire [08:00] alu_out =
	    (alu_op == `CS_ALU_OP_PASS) ? srcA  :
	    (alu_op == `CS_ALU_OP__INC) ? {Cout[7], Sum} :
	    (alu_op == `CS_ALU_OP__DEC) ? {Cout[7], Sum} :
	    (alu_op == `CS_ALU_OP__ADD) ? {Cout[7], Sum} :
	    (alu_op == `CS_ALU_OP__SUB) ? {Cout[7], Sum} :
	    (alu_op == `CS_ALU_OP__XOR) ? srcA  ^ srcB  : 
	    (alu_op == `CS_ALU_OP__AND) ? srcA  & srcB  :
	    (alu_op == `CS_ALU_OP___OR) ? srcA  | srcB  : 8'bX;

    // Build the shift right logic
    wire sri = s_l_source;
    wire [07:00] dri = alu_out[07:00];
    wire [07:00] s_r_input =
    	(scr7[`SC_MSB] == `SC_MSB_DSBL) ? {sri, dri[07:01]} :
	(scr7[`SC_MSB_VAL] == 3'b000)	? {sri, dri[07:02], sri} :
	(scr7[`SC_MSB_VAL] == 3'b001)	? {sri, dri[07:03], sri, dri[01:01]} :
	(scr7[`SC_MSB_VAL] == 3'b010)	? {sri, dri[07:04], sri, dri[02:01]} :
	(scr7[`SC_MSB_VAL] == 3'b011)	? {sri, dri[07:05], sri, dri[03:01]} :
	(scr7[`SC_MSB_VAL] == 3'b100)	? {sri, dri[07:06], sri, dri[04:01]} :
	(scr7[`SC_MSB_VAL] == 3'b101)	? {sri, dri[07:07], sri, dri[05:01]} :
	(scr7[`SC_MSB_VAL] == 3'b110)	? {sri,             sri, dri[06:01]} :
	(scr7[`SC_MSB_VAL] == 3'b111)	? {sri, dri[07:01]} : 9'bX;

    wire sor_tmp =
    	(scr7[`SC_MSB] == `SC_MSB_DSBL) ? dri[00] :
	(scr7[`SC_MSB_VAL] == 3'b000)	? dri[01] :
	(scr7[`SC_MSB_VAL] == 3'b001)	? dri[02] :
	(scr7[`SC_MSB_VAL] == 3'b010)	? dri[03] :
	(scr7[`SC_MSB_VAL] == 3'b011)	? dri[04] :
	(scr7[`SC_MSB_VAL] == 3'b100)	? dri[05] :
	(scr7[`SC_MSB_VAL] == 3'b101)	? dri[06] :
	(scr7[`SC_MSB_VAL] == 3'b110)	? dri[07] :
	(scr7[`SC_MSB_VAL] == 3'b111)	? dri[00] : 1'bX;

    // Do the shift operation
    wire [08:00] shift_out =
	    (shift_op ==`CS_SHFT_OP_PASS) ?
			{(scr7[`SC_SHIFT_DIR] == `SC_SHIFT_SL) ? alu_out[07] : 
						alu_out[00], alu_out[07:00]} :
	    (shift_op ==`CS_SHFT_OP___SL) ? {alu_out[07:00], s_r_source} :
	    (shift_op ==`CS_SHFT_OP___SR) ? {sor_tmp, s_r_input} :
	    (shift_op ==`CS_SHFT_OP__SWP) ? {alu_out[08], alu_out[03:00],
							alu_out[07:04]} : 9'bX;

    // Chaining signals
    assign co =
    	(scr7[`SC_MSB] == `SC_MSB_DSBL) ? Cout[07] :
	(scr7[`SC_MSB_VAL] == 3'b000)	? Cout[00] :
	(scr7[`SC_MSB_VAL] == 3'b001)	? Cout[01] :
	(scr7[`SC_MSB_VAL] == 3'b010)	? Cout[02] :
	(scr7[`SC_MSB_VAL] == 3'b011)	? Cout[03] :
	(scr7[`SC_MSB_VAL] == 3'b100)	? Cout[04] :
	(scr7[`SC_MSB_VAL] == 3'b101)	? Cout[05] :
	(scr7[`SC_MSB_VAL] == 3'b110)	? Cout[06] :
	(scr7[`SC_MSB_VAL] == 3'b111)	? Cout[07] : 1'bX;

    assign sol = (scr7[`SC_MSB] == `SC_MSB_DSBL) ? shift_out[08] :
						shift_out[scr7[`SC_MSB_VAL]+1];
    assign sor = sor_tmp;

    wire msbo  = (scr7[`SC_MSB] == `SC_MSB_DSBL) ? srcA[07] :
						    srcA[scr7[`SC_MSB_VAL]];

    // Shift direction MUX
    wire so_src= (scr7[`SC_SHIFT_DIR] == `SC_SHIFT_SL) ? sol : sor;

    // Overflow detect
    wire vo = (srcA[07] &  srcB[07] & ~alu_out[07]) |
	     (~srcA[07] & ~srcB[07] &  alu_out[07]);

    // Mask the output of the ALU/Shifter
    assign mask_out = (scr6[`SC__A_MASK] == `SC_A_MASK_DSBL) ?
				    shift_out[07:00] : shift_out[07:00] & scr4;

    // Write the results to the A registers
    always @(posedge clk or posedge reset)
    begin
	if (reset)
	begin
	    reg_a0 <= 0;
	    reg_a1 <= 0;
	end
	else
	    case (wr_src_a0)
		`CS_A0_SRC_NONE : ;
		`CS_A0_SRC__ALU : reg_a0 <= mask_out;
		`CS_A0_SRC___D0 : reg_a0 <= reg_d0;
		`CS_A0_SRC___F0 : reg_a0 <= fifo0_data_out;
	    endcase

	    case (wr_src_a1)
		`CS_A1_SRC_NONE : ;
		`CS_A1_SRC__ALU : reg_a1 <= mask_out;
		`CS_A1_SRC___D1 : reg_a1 <= reg_d1;
		`CS_A1_SRC___F1 : reg_a1 <= fifo1_data_out;
	    endcase
    end

    // Select extra synchronization of the FIFO status
    reg  fifo0_blk_extra;
    wire fifo0_async_mux;
    reg  fifo0_add_sync;
    always @(posedge read_clk_0 or posedge reset)
    begin
	if (reset)
	begin
	    fifo0_blk_extra <= 0;
	    fifo0_add_sync  <= 0;
	end
	else
	begin
	    fifo0_blk_extra <= fifo0_blk_stat;
	    fifo0_add_sync  <= fifo0_async_mux;
	end
    end

    reg  fifo1_blk_extra;
    wire fifo1_async_mux;
    reg  fifo1_add_sync;
    always @(posedge read_clk_1 or posedge reset)
    begin
	if (reset)
	begin
	    fifo1_blk_extra <= 0;
	    fifo1_add_sync  <= 0;
	end
	else
	begin
	    fifo1_blk_extra <= fifo1_blk_stat;
	    fifo1_add_sync  <= fifo1_async_mux;
	end
    end

    assign fifo0_async_mux = (scr8[`SC_FIFO_TYPE] == `SC_FIFO__SYNC) ?
					    fifo0_blk_stat : fifo0_blk_extra;
    assign fifo1_async_mux = (scr8[`SC_FIFO_TYPE] == `SC_FIFO__SYNC) ?
					    fifo1_blk_stat : fifo1_blk_extra;
    wire f0_blk_mux = (scr8[`SC_FIFO_SYNC] == `SC_FIFO_SYNC__ADD) ?
					    fifo0_add_sync : fifo0_async_mux;
    wire f1_blk_mux = (scr8[`SC_FIFO_SYNC] == `SC_FIFO_SYNC__ADD) ?
					    fifo1_add_sync : fifo1_async_mux;

    // Register the outputs
    wire [15:00] cmb_out_vector = { fifo1_bus_stat, fifo0_bus_stat,
				    f1_blk_mux,     f0_blk_mux,
				    so_src, msbo,   co,      vo,
				    fo[01], zo[01], clo[01], ceo[01],
				    fo[00], zo[00], clo[00], ceo[00]};
    reg  [15:00] reg_out_vector;
    always @(posedge clk)
    begin
    	reg_out_vector <= cmb_out_vector;
    end

    // Output register select configuration
    wire [15:00] reg_sel ={ f1_bus_sync, f0_bus_sync, f1_blk_sync, f0_blk_sync,
			    so_sync,     cmsb_sync,   co_msb_sync, ov_msb_sync,
			    ff1_sync,    z1_sync,     cl1_sync,    ce1_sync,
			    ff0_sync,    z0_sync,     cl0_sync,    ce0_sync};

    // Select sync or async (if using the parameters).
    wire ce0         = (~reg_sel[00]) ? reg_out_vector[00] : cmb_out_vector[00];
    wire cl0         = (~reg_sel[01]) ? reg_out_vector[01] : cmb_out_vector[01];
    wire z0          = (~reg_sel[02]) ? reg_out_vector[02] : cmb_out_vector[02];
    wire ff0         = (~reg_sel[03]) ? reg_out_vector[03] : cmb_out_vector[03];
    wire ce1         = (~reg_sel[04]) ? reg_out_vector[04] : cmb_out_vector[04];
    wire cl1         = (~reg_sel[05]) ? reg_out_vector[05] : cmb_out_vector[05];
    wire z1          = (~reg_sel[06]) ? reg_out_vector[06] : cmb_out_vector[06];
    wire ff1         = (~reg_sel[07]) ? reg_out_vector[07] : cmb_out_vector[07];
    wire ov_msb      = (~reg_sel[08]) ? reg_out_vector[08] : cmb_out_vector[08];
    wire co_msb      = (~reg_sel[09]) ? reg_out_vector[09] : cmb_out_vector[09];
    wire cmsb        = (~reg_sel[10]) ? reg_out_vector[10] : cmb_out_vector[10];
    wire so          = (~reg_sel[11]) ? reg_out_vector[11] : cmb_out_vector[11];
    wire f0_blk_stat = (~reg_sel[12]) ? reg_out_vector[12] : cmb_out_vector[12];
    wire f1_blk_stat = (~reg_sel[13]) ? reg_out_vector[13] : cmb_out_vector[13];
    wire f0_bus_stat = (~reg_sel[14]) ? reg_out_vector[14] : cmb_out_vector[14];
    wire f1_bus_stat = (~reg_sel[15]) ? reg_out_vector[15] : cmb_out_vector[15];

    // Send the registered stuff out
    assign {f1_bus_stat_reg, f0_bus_stat_reg, f1_blk_stat_reg, f0_blk_stat_reg,
	    so_reg,  cmsb_reg, co_msb_reg, ov_msb_reg,
	    ff1_reg, z1_reg,   cl1_reg,    ce1_reg,
	    ff0_reg, z0_reg,   cl0_reg,    ce0_reg} = reg_out_vector;

endmodule

////////////////////////////////////////////////////////////////////////////////
//									      //
//			BASIC FIFO OPERATIONAL MODEL			      //
//									      //
////////////////////////////////////////////////////////////////////////////////

module DP_FIFO (fifo_mode, fifo_clr, fifo_lvl,
		fifo_wr_clock,  fifo_rd_clock,
		fifo_wr_enable, fifo_rd_enable,
		fifo_wr_data,   fifo_rd_data,
		fifo_blk_stat,  fifo_bus_stat);

    input [1:0]	fifo_mode;			// Input or Output <A0, A1, ALU>
    input	fifo_clr;			// Reset the FIFO flags and pntr
    input	fifo_lvl;			// Control function of flags
    input 	fifo_wr_clock;			// FIFO write clock
    input 	fifo_rd_clock;			// FIFO read clock
    input 	fifo_wr_enable;			// FIFO write enable
    input 	fifo_rd_enable;			// FIFO read enable
    input [7:0] fifo_wr_data;			// FIFO write data
    output[7:0] fifo_rd_data;			// FIFO read data
    output	fifo_blk_stat;			// FIFO status to UDB
    output	fifo_bus_stat;			// FIFO status to CPU

    // Internal FIFO signals
    reg [07:00] fifo_ram [03:00];
    reg [01:00] rd_pointer = 0;
    reg		fifo_full  = 0;
    wire[01:00] rp_minus_1 = rd_pointer - 1;
    reg [01:00] wr_pointer = 0;
    wire[07:00] fifo_rd_data = fifo_ram[rd_pointer];
    wire[07:00] fifo_wr_data;
    reg		rread_inc = 0;
    reg		wread_inc = 0;
    reg		write_inc = 0;

    // Use the FIFO read signals to empty the FIFO RAM
    always @(posedge fifo_rd_clock)
    begin
	if (fifo_rd_enable)
	begin
	    if (rd_pointer != wr_pointer)
	    begin
		rread_inc <= 1;
		@(negedge fifo_rd_clock);
		rread_inc <= 0;
	    end
	end
    end

    // Update the write index if a read has happened when full
    always @(negedge fifo_rd_clock)
    begin
	if (fifo_rd_enable && fifo_full)
	begin
	    @(negedge fifo_rd_enable);
	    @(negedge fifo_wr_clock);
	    wread_inc <= 1;
	    @(negedge fifo_wr_clock);
	    wread_inc <= 0;
	end
    end

    // Use the FIFO write signals to fill the FIFO RAM
    always @(posedge fifo_wr_clock)
    begin
	if (fifo_wr_enable)
	begin
	    fifo_ram[wr_pointer] <= fifo_wr_data;
	    if (wr_pointer != rp_minus_1)
	    begin
		write_inc <= 1;
		@(negedge fifo_wr_clock);
		write_inc <= 0;
	    end
	end
    end

    // write pointer incrementer
    always @(posedge write_inc or posedge wread_inc or posedge fifo_clr)
    begin
	if (fifo_clr)
	    wr_pointer <= 0;
	else
	    wr_pointer <= wr_pointer + 1;
    end

    // Read pointer incrementer
    always @(posedge rread_inc or posedge fifo_clr)
    begin
	if (fifo_clr)
	    rd_pointer <= 0;
	else
	    rd_pointer <= rd_pointer + 1;
    end

    // Keep track of the FIFO full status
    always @(posedge fifo_rd_clock or posedge fifo_wr_clock or posedge fifo_clr)
    begin
	if (fifo_clr)
	    fifo_full <= 0;
    	if (fifo_wr_enable && !fifo_full)
	    if (wr_pointer != rp_minus_1)
	     	fifo_full <= 0;
	    else
	     	fifo_full <= 1;
	if (fifo_rd_enable &&  fifo_full)
	    if (wr_pointer == rp_minus_1)
	    begin
// wait for the next fifo_rd_clock before deasserting fifo_full, otherwise write pointer may not be updated.
		@(posedge fifo_rd_clock);
	     	fifo_full <= 0;
	    end
	    else
	     	fifo_full <= 1;
    end

    // Generate the flags
    wire block_empty   = (wr_pointer == rd_pointer);
    wire block__full   =  fifo_full;
    wire fifo_blk_stat = (fifo_mode == 2'b00) ? block_empty : block__full;

    wire bus_haf_empty = (wr_pointer  - rd_pointer) <= 2;
    wire bus_not__full = ~fifo_full;
    wire bus_haf__full = (wr_pointer  - rd_pointer) >= 2;
    wire bus_not_empty = (wr_pointer != rd_pointer);
    wire bus_stat_empty= (fifo_lvl) ? bus_haf_empty : bus_not__full;
    wire bus_stat__full= (fifo_lvl) ? bus_haf__full : bus_not_empty;
    wire fifo_bus_stat = (fifo_mode == 2'b00) ? bus_stat_empty : bus_stat__full;

endmodule

`endif
`endif
