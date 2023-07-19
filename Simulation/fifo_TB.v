/* See Component Author Guide Section on Simulation for more information */

/* 1ns is the reference time, 100ps is the precision, i.e #33.1 is a delay of 33100 ps, #33.01 is a delay of 33000 ps */
`timescale 1ns/100ps

`include "defines.v"

`include "cypress.v"

module fifo_TB;

	// clocks
	reg bus_clk;
	reg cpu_clk;

	// fifo status
	wire f0NotFull;
	wire f0Empty;
	wire f1NotFull;
	wire f1Empty;

	// 
	reg [7:0] f0In;
	reg [7:0] f1In;
	reg [7:0] f0Out;
	reg [7:0] f1Out;

	fifo fifo_1 (.clock(bus_clk), .f0NotFull(f0NotFull), .f0Empty(f0Empty), .f1NotFull(f1NotFull), .f1Empty(f1Empty));

	initial	/* This loop runs only once */ 
	begin
$dumpfile("fifo_TB.vcd");
$dumpvars(0,fifo_TB);
//$dumpvars;
		bus_clk = 0;

		#10;
		wait(f0NotFull);

		f0In = 8'hff;
		fifo_TB.fifo_1.fifo.U0.fifo0_write(f0In);
		#2;
		f0In = 8'h88;
		fifo_TB.fifo_1.fifo.U0.fifo0_write(f0In);
		#2;
		f0In = 8'h44;
		fifo_TB.fifo_1.fifo.U0.fifo0_write(f0In);
		#2;
		f0In = 8'h11;
		fifo_TB.fifo_1.fifo.U0.fifo0_write(f0In);
		#2;
		wait(~f0Empty);
		// note: when FIFO becomes full fifo0_read hangs as it's interpreting status signal
		// incorrectly when FIFO is in DYN mode.
		fifo_TB.fifo_1.fifo.U0.fifo0_read(f0Out);
		if (f0Out != 8'hff) begin $display("Fifo0 returned bad value %m"); $stop; end
		#2;
//		wait(~f0Empty);
		fifo_TB.fifo_1.fifo.U0.fifo0_read(f0Out);
		if (f0Out != 8'h88) begin $display("Fifo0 returned bad value %m"); $stop; end
		#2;
//		wait(~f0Empty);
		fifo_TB.fifo_1.fifo.U0.fifo0_read(f0Out);
		if (f0Out != 8'h44) begin $display("Fifo0 returned bad value %m"); $stop; end
		#2;
//		wait(~f0Empty);
		fifo_TB.fifo_1.fifo.U0.fifo0_read(f0Out);
		if (f0Out != 8'h11) begin $display("Fifo0 returned bad value %m"); $stop; end
		#2;

//		force fifo_1.fifo_d0_load = 1'b0;
		#10;
		$finish;
	end

    always // UDB Clock generator
	begin
		begin
			#4 bus_clk = !bus_clk;	/* every 4 reference time units, toggle clock. Ensure that clock is initialized to 0 or 1, or this line makes no sense */
		end
	end

	initial  // CPU clock generator
	begin
		cpu_clk = 0;
		while(1)
		begin
			/* connect the instance's cpu_clk to the testbench's cpu_clk */
			fifo_1.fifo.U0.cpu_clock = cpu_clk;

			#1 cpu_clk = !cpu_clk;	/* cpu_clk is the freq at which CPU reads and writes are simulated */
		end
	end

	// 
	// Write an command/data byte to the OpenJTAG decoder
	//
	/*
	task write_decode_fifo;
		input [7:0] openJtagCmd;
		begin
			wait (dInReq);
			dut.Datapath_1_u0.fifo0_write(openJtagCmd);
		end
	endtask
    */
endmodule    
