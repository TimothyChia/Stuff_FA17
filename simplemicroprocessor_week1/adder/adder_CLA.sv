module adder_CLA (input A, B, Cin,
 output S, P,G);

 assign S = A^B^Cin;
 assign   G = A&B;
assign   P = A|B;
 // assign c = (x&y)|(y&z)|(x&z);

endmodule
