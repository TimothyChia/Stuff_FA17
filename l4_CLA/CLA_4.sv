//carry look ahead adder, 4 bit.

module CLA_4( input logic [3:0] A, B, //bits to be added
            input logic Cin,       //Carry in
            output logic [3:0] S,  //the S bits
            output logic PG, GG    //group propagate and generate
  );

  logic [3:0] C;
  logic [2:0] P,G;
  //
  //  C3,C2,C1,C0,
  //       P2,P1,P0,
  //       G2,G1,G0
  // ;

  G = A&B;
  P = A|B;
  PG= P[0]&P[1]&P[2]&P[3];
  GG= G[3]   |   G[2]&P[3]   |   G[1]&P[3]&P[2]   |   G[0]&P[3]&P[2]&P[1];

  C[0]= Cin;
  C[1]= Cin & P[0]   |   G[0];
  C[2]= Cin & P[0] & P[1]   |   G[0] & P[1]   |   G[1];
  C[3]= Cin & P[0] & P[1] & P[2]  |   G[0] & P[1] & P[2]  |
        G[1] & P[2] | G[2];
