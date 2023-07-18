/*******************************************************************************
* Copyright 2000, 2009, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
********************************************************************************/

module cy_and2 (a, b, y);

input   a; 
input   b; 
output  y; 
wire    y; 

assign y = a & b; 

endmodule // module cy_and2


module cy_and3 (a, b, c, y);

input   a; 
input   b; 
input   c; 
output  y; 
wire    y; 

assign y = a & b & c; 

endmodule // module cy_and3


module cy_and4 (a, b, c, d, y);

input   a; 
input   b; 
input   c; 
input   d; 
output  y; 
wire    y; 

assign y = a & b & c & d; 

endmodule // module cy_and4


module cy_or2 (a, b, y);

input   a; 
input   b; 
output  y; 
wire    y; 

assign y = a | b; 

endmodule // module cy_or2


module cy_or3 (a, b, c, y);

input   a; 
input   b; 
input   c; 
output  y; 
wire    y; 

assign y = a | b | c; 

endmodule // module cy_or3


module cy_or4 (a, b, c, d, y);

input   a; 
input   b; 
input   c; 
input   d; 
output  y; 
wire    y; 

assign y = a | b | c | d; 

endmodule // module cy_or4


module cy_xor2 (a, b, y);

input   a; 
input   b; 
output  y; 
wire    y; 

assign y = a ^ b; 

endmodule // module cy_xor2


module cy_xor3 (a, b, c, y);

input   a; 
input   b; 
input   c; 
output  y; 
wire    y; 

assign y = a ^ b ^ c; 

endmodule // module cy_xor3


module cy_xor4 (a, b, c, d, y);

input   a; 
input   b; 
input   c; 
input   d; 
output  y; 
wire    y; 

assign y = a ^ b ^ c ^ d; 

endmodule // module cy_xor4


module cy_inv (a, y);

input   a; 
output  y; 
wire    y; 

assign y = ~a; 

endmodule // module cy_inv


module cy_mux2x1 (a0, a1, s, y);

input   a0; 
input   a1; 
input   s; 
output  y; 
wire    y; 

assign y = s & a1 | ~s & a0; 

endmodule // module cy_mux2x1


module cy_mux4x1 (a0, a1, a2, a3, s0, s1, y);

input   a0; 
input   a1; 
input   a2; 
input   a3; 
input   s0; 
input   s1; 
output  y; 
wire    y; 

assign y = s0 & s1 & a3 | ~s0 & 
	s1 & a2 | s0 & ~s1 & 
	a1 | ~s0 & ~s1 & a0; 

endmodule // module cy_mux4x1


module cy_mux8x1 (a0, a1, a2, a3, a4, a5, a6, a7, s0, s1, s2, y);

input   a0; 
input   a1; 
input   a2; 
input   a3; 
input   a4; 
input   a5; 
input   a6; 
input   a7; 
input   s0; 
input   s1; 
input   s2; 
output  y; 
wire    y; 

assign y = s0 & s1 & s2 & a7 | 
	~s0 & s1 & s2 & a6 | 
	s0 & ~s1 & s2 & a5 | 
	~s0 & ~s1 & s2 & a4 | 
	s0 & s1 & ~s2 & a3 | 
	~s0 & s1 & ~s2 & a2 | 
	s0 & ~s1 & ~s2 & a1 | 
	~s0 & ~s1 & ~s2 & a0; 

endmodule // module cy_mux8x1
