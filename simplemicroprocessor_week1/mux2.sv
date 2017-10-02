module mux2 //parameterized, so no need to write redundant code
          #(parameter width = 8)
          (input [width-1:0] logic in0, in1,
           input logic select,
           output [width-1:0] out);

          always_comb
          begin
            case(select)
              2'b00:
              out = in0;
              2'b01:
              out = in1;
            endcase
          end
  endmodule
