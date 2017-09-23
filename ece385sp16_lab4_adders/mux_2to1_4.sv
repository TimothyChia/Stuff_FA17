module mux_2to1_4 (
 input [3:0] sum0, sum1,
 input sel,
 output [3:0] out
 );


/* if(sel)	assign out = sum1;

 else	assign out = sum0; */

 assign out = (sel)? sum1:sum0;
 endmodule
