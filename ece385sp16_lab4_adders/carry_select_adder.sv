module carry_select_adder (
	input logic [15:0] A,B,
	output logic [15:0] Sum,
	output logic CO // oh, not zero.
	);
	
	//would be better to use a packed array for these.
logic c0_4, c0_8, c0_12, c0_16; //these are the carryouts of the 4bit adders when c_in = 0
logic [15:0] Sum0; //sum when c_in = 0

logic c1_4, c1_8, c1_12, c1_16; //these are the carryouts of the 4bit adders when c_in = 1	
logic [15:0] Sum1; //sum when c_in = 1
//assume c_in is 0	

logic c_4, c_8, c_12, c_16; // used to get the actual c_in for each 4bit adder

logic m_out0, m_out1, m_out2; //output from mux
//what is operator precedence



//assume Cin is 0 so don't build extra adder and mux
full_adder_4 FA0_0(.A(A[3:0]), .B(B[3:0]), .c_in(0), .S(Sum0[3:0]), .c_out(c0_4));
//full_adder_4 FA1_0(.A(A[3:0]), .B(B[3:0]), .c_in(1), .S(Sum1[3:0]), .c_out(c1_4));


full_adder_4 FA0_1(.A(A[7:4]), .B(B[7:4]), .c_in(c_4), .S(Sum0[7:4]), .c_out(c0_8));
full_adder_4 FA1_1(.A(A[7:4]), .B(B[7:4]), .c_in(c_4), .S(Sum1[7:4]), .c_out(c1_8));

full_adder_4 FA0_2(.A(A[11:8]), .B(B[11:8]), .c_in(c_8), .S(Sum0[11:8]), .c_out(c0_12));
full_adder_4 FA1_2(.A(A[11:8]), .B(B[11:8]), .c_in(c_8), .S(Sum1[11:8]), .c_out(c1_12));

full_adder_4 FA0_3(.A(A[15:12]), .B(B[15:12]), .c_in(c_12), .S(Sum0[15:12]), .c_out(c0_16));
full_adder_4 FA1_3(.A(A[15:12]), .B(B[15:12]), .c_in(c_12), .S(Sum1[15:12]), .c_out(c1_16));

//multiplexers should really be in a for loop
//mux_2to1_4 MUX0 (.sum0(Sum0[3:0]), .sum1(Sum1[3:0]), .sel(0), .out());
mux_2to1_4 MUX1 (.sum0(Sum0[7:4]), .sum1(Sum1[7:4]), .sel(c_4), .out(Sum[7:4]));
mux_2to1_4 MUX2 (.sum0(Sum0[11:8]), .sum1(Sum1[11:8]), .sel(c_8), .out(Sum[11:8]));
mux_2to1_4 MUX3 (.sum0(Sum0[15:12]), .sum1(Sum1[15:12]), .sel(c_12), .out(Sum[15:12])); 


always_comb 
begin
 c_4 = c0_4;
 c_8 = c0_8   | (c1_8&c_4);
 c_12 = c0_12 | (c1_12&c_8);
 c_16 = c0_16 | (c1_16&c_12);
 CO = c_16;


Sum[3:0]=Sum0[3:0]; //since the LSB mux was commented out

end

endmodule
