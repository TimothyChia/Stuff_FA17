
module mux_2to1_4 (
 input [3:0] sum0, sum1,
 input sel,
 output [3:0] out,
 );

 if(sel)
	assign out[3:0] = sum1[3:0];
 
 if(~sel)
	assign out[3:0] = sum0[3:0];
 
endmodule