module carry_select_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a carry select.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
     
endmodule




//////here is what i have so far:

module adder_carry_select (
	input logic Clk, Reset, Load_B, Run,
	input logic [15:0] SW,
	output logic [15:0] Sum,
	output logic CO,
	output logic [6:0] Ahex0, Ahex1, Ahex2, Ahex3, Bhex0, Bhex1, Bhex2, Bhex3);
 
 //other variables below
 logic [15:0] A, B;
 HexDriver HA0(SW[15:12], Ahex0);
 HexDriver HA1(SW[11:8], Ahex1);
 HexDriver HA2(SW[7:4], Ahex2);
 HexDriver HA3(SW[3:0], Ahex3);
 
 HexDriver HB0(SW[15:12], Bhex0);
 HexDriver HB1(SW[11:8], Bhex1);
 HexDriver HB2(SW[7:4], Bhex2);
 HexDriver HB3(SW[3:0], Bhex3);
 
 if(load_A)
	assign A[15:0] = SW[15:0];
	
 if(load_B)
	assign B[15:0] = SW[15:0];
	
full_adder_4 F4_0(.A(A[15:12]), .B(B[15:12]), .c_in)
full_adder_4 F4_1()
full_adder_4 F4_2()
full_adder_4 F4_3()
	

endmodule
