module ripple_adder (
 input [8:0] A, B,
 input c_in,
 output logic [15:0] Sum, //renamed this to match the top level
 output logic CO);    //and renamed this too

 //other variables below
 logic c0, c1, c2, c3, c4, c5, c6, c7;

	full_adder FA0  (.x (A[0]),  .y (B[0]),  .z (c_in), .s(Sum[0]),  .c (c0));
	full_adder FA1  (.x (A[1]),  .y (B[1]),  .z (c0),  .s (Sum[1]),  .c (c1));
	full_adder FA2  (.x (A[2]),  .y (B[2]),  .z (c1),  .s (Sum[2]),  .c (c2));
	full_adder FA3  (.x (A[3]),  .y (B[3]),  .z (c2),  .s (Sum[3]),  .c (c3));
	full_adder FA4  (.x (A[4]),  .y (B[4]),  .z (c3),  .s (Sum[4]),  .c (c4));
	full_adder FA5  (.x (A[5]),  .y (B[5]),  .z (c4),  .s (Sum[5]),  .c (c5));
	full_adder FA6  (.x (A[6]),  .y (B[6]),  .z (c5),  .s (Sum[6]),  .c (c6));
	full_adder FA7  (.x (A[7]),  .y (B[7]),  .z (c6),  .s (Sum[7]),  .c (c7));
	full_adder FA8  (.x (A[8]),  .y (B[8]),  .z (c7),  .s (Sum[8]),  .c (CO));



endmodule
