module CLU(input logic [3:0] P,G
            input logic Cin,       //Carry in
            output logic [4:0] C
);

always_comb begin
  C[0]= Cin;
  C[1]= Cin & P[0]   |   G[0];
  C[2]= Cin & P[0] & P[1]   |   G[0] & P[1]   |   G[1];
  C[3]= Cin & P[0] & P[1] & P[2]  |   G[0] & P[1] & P[2]  |
        G[1] & P[2] | G[2];
  //actually seem to need a Cout as well, because of the 16 bit specs
  //C4 = G3 + P3C3
  C[4] = Cin & P[0] & P[1] & P[2] & P[3]  |   G[0] & P[1] & P[2] & P[3]  |
        G[1] & P[2] & P[3]  | G[2] & P[3] | G[3];
end



endmodule
