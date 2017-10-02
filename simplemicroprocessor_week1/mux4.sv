module mux4(input [15:0] logic in0, in1, in2, in3
            input logic [1:0] select,
            output [15:0] out);

      always_comb
        begin
          case(select)
          2'b00:
            out = in0;
          2'b01:
            out = in1;
          2'b10:
            out = in2;
          2'b11:
            out = in3;
          endcase
        end

endmodule
