module register (input  logic Clk, Load,
                input [2:0] Write_sel, Read_sel_1, Read_sel_2
                input [15:0] Data_In,
                output [15:0] Data_out_1, Data_out_2);

      logic [15:0] R7, R6, R5, R4, R3, R2, R1, R0;

//I wonder if the reset in Reg_16 is enough or if we need to add a reset case here

      always_ff @ (posedge Clk)
        begin
          if(Load)
            case(DR)
              3'b000: R0 <= BUS;
              3'b001: R1 <= BUS;
              3'b010: R2 <= BUS;
              3'b011: R3 <= BUS;
              3'b100: R4 <= BUS;
              3'b101: R5 <= BUS;
              3'b110: R6 <= BUS;
              3'b111: R7 <= BUS;
              default: ;

            case(SR1) //match input with respective SR1
              3'b000: SR1_OUT[0] <= R0
              3'b001: SR1_OUT[1] <= R1
              3'b010: SR1_OUT[2] <= R2
              3'b011: SR1_OUT[3] <= R3
              3'b100: SR1_OUT[4] <= R4
              3'b101: SR1_OUT[5] <= R5
              3'b110: SR1_OUT[6] <= R6
              3'b111: SR1_OUT[7] <= R7
              default: ;

            case(SR2) //match input with respective SR2
              3'b000: SR2_OUT[0] <= R0
              3'b001: SR2_OUT[1] <= R1
              3'b010: SR2_OUT[2] <= R2
              3'b011: SR2_OUT[3] <= R3
              3'b100: SR2_OUT[4] <= R4
              3'b101: SR2_OUT[5] <= R5
              3'b110: SR2_OUT[6] <= R6
              3'b111: SR2_OUT[7] <= R7
              default: ;


        end
