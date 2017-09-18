module CLU(input logic [3:0] P,G
            input logic Cin,       //Carry in
            output logic [3:0] C
);

always_comb begin
  C[0]= Cin;
  C[1]= Cin & P[0]   |   G[0];
  C[2]= Cin & P[0] & P[1]   |   G[0] & P[1]   |   G[1];
  C[3]= Cin & P[0] & P[1] & P[2]  |   G[0] & P[1] & P[2]  |
        G[1] & P[2] | G[2];
end

endmodule
