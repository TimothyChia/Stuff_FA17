module register (input  logic Clk, Load,
                input logic [2:0] Write_sel, Read_sel_1, Read_sel_2,
                input logic [15:0] Data_In,
                output logic  [15:0] Data_out_1, Data_out_2);

      logic [15:0] R7, R6, R5, R4, R3, R2, R1, R0;

//I wonder if the reset in Reg_16 is enough or if we need to add a reset case here
//Changed since the read has to be asynchronous if Add is being done in a single state.
      always_ff @ (posedge Clk)
        begin
           
        if(Load)
          begin
            case(Write_sel)
              3'b000: R0 <= Data_In;
              3'b001: R1 <= Data_In;
              3'b010: R2 <= Data_In;
              3'b011: R3 <= Data_In;
              3'b100: R4 <= Data_In;
              3'b101: R5 <= Data_In;
              3'b110: R6 <= Data_In;
              3'b111: R7 <= Data_In;
              default: ;
            endcase
          end

        end

    always_comb
    begin
            case(Read_sel_1) //match input with respective SR1
              3'b000: Data_out_1 = R0;
              3'b001: Data_out_1 = R1;
              3'b010: Data_out_1 = R2;
              3'b011: Data_out_1 = R3;
              3'b100: Data_out_1 = R4;
              3'b101: Data_out_1 = R5;
              3'b110: Data_out_1 = R6;
              3'b111: Data_out_1 = R7;
              default: ;
            endcase
            
            case(Read_sel_2) //match input with respective SR2
              3'b000: Data_out_2 = R0;
              3'b001: Data_out_2 = R1;
              3'b010: Data_out_2 = R2;
              3'b011: Data_out_2 = R3;
              3'b100: Data_out_2 = R4;
              3'b101: Data_out_2 = R5;
              3'b110: Data_out_2 = R6;
              3'b111: Data_out_2 = R7;
              default: ;
            endcase

    end

endmodule
