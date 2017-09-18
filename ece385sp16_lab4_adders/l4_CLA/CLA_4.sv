//carry look ahead adder, 4 bit.

module CLA_4( input logic [3:0] A, B, //bits to be added
              input logic Cin,       //Carry in
              output logic [3:0] S,  //the S bits
              output logic PG, GG    //group propagate and generate
            //should maybe have a Cout output?
  );

  logic [4:0] C; //now wider to fit the unused Cout from the CLU
  logic [3:0] P,G;

  //generates C, using P and G
  CLU CLU_0(.P(P), .G(G), .Cin(Cin), .C(C) ); //explicitly connected even though names are the same

  //these adders generate S, P, G, but require C to get S
  adder_CLA CLA_0 (.A (A[0]), .B (B[0]), .Cin (C[0]), .S (S[0]), .P (P[0]), .G(G[0]));
	adder_CLA CLA_1 (.A (A[1]), .B (B[1]), .Cin (C[1]), .S (S[1]), .P (P[1]), .G(G[1]));
	adder_CLA CLA_2 (.A (A[2]), .B (B[2]), .Cin (C[2]), .S (S[2]), .P (P[2]), .G(G[2]));
	adder_CLA CLA_3 (.A (A[3]), .B (B[3]), .Cin (C[3]), .S (S[3]), .P (P[3]), .G(G[3]));

  always_comb begin
  //equations typed to mirror the lab documentation as closely as possible.
    PG= P[0]&P[1]&P[2]&P[3];
    GG= G[3]   |   G[2]&P[3]   |   G[1]&P[3]&P[2]   |   G[0]&P[3]&P[2]&P[1];


  end




endmodule
