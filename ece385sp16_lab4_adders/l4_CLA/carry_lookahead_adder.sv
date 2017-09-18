module carry_lookahead_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a CLA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
     logic[15:0]     S


    logic [4:0] C;
    logic [3:0] P,G; //technically P0,P4,P8,P12

    //generates C, using P and G
    CLU CLU_0(.P(P), .G(G), .Cin(Cin), .C(C) ); //explicitly connected even though names are the same

      //these adders generate S, P, G, but require C to get S
      //each adder handles 4 bits.
     CLA_4 CLA_4_0 (.A (A[3:0]), .B (B[3:0]), .Cin (C[0]), .S (S[3:0]), .PG (P[0]), .GG(G[0]));
     CLA_4 CLA_4_0 (.A (A[7:4]), .B (B[7:4]), .Cin (C[1]), .S (S[7:4]), .PG (P[1]), .GG(G[1]));
     CLA_4 CLA_4_0 (.A (A[11:8]), .B (B[11:8]), .Cin (C[2]), .S (S[11:8]), .PG (P[2]), .GG(G[2]));
     CLA_4 CLA_4_0 (.A (A[15:12]), .B (B[15:12]), .Cin (C[3]), .S (S[15:12]), .PG (P[3]), .GG(G[3]));
     
always_comb begin
  Sum=S; //quartus should optimize this naming quirk out, but it might be needed to keep compatability with testbench
  C[0]=0; //another slight difference from the CLA_4 this copies in format. look into class/library?
  CO=C[4];
end

endmodule
