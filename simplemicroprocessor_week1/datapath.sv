module datapath(
	input logic [15:0] S,
	input logic Clk, Reset, Run, Continue,
	output logic [11:0] LED,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
	output logic CE, UB, LB, OE, WE, //control signals for memory?
	output logic [19:0] ADDR,
	inout wire [15:0] Data //tristate buffers need to be of type wire
);
// put of all of this in in always ff or always comb ?

// for the 2 always style
logic [15:0] MDR_In_next;
logic [15:0] MAR_next, MDR_next, IR_next, PC_next;
logic [15:0] Data_from_SRAM_next, Data_to_SRAM_next;


always_ff @(posedge Clk)
begin
    MDR_In          <= MDR_In_next;
    MAR             <= MAR_next;
    MDR             <= MDR_next;
    IR              <= IR_next;
    PC              <= PC_next;
    Data_from_SRAM  <= Data_from_SRAM_next;
    Data_to_SRAM    <= Data_to_SRAM_next;
end


always_comb
begin

// CPU Bus Datapath 1 mux instead of 4 tristate buffers? 
//GatePC, GateMDR, GateALU, GateMARMUX
case () 
        0 : y = a; 
        1 : y = b; 
        2 : y = c; 
        3 : y = d; 
        default : y = x; 


// PC datapath
// PC needs a reset to 0, an increment, an external value, and values for jumps
if(LD_PC)
    case (PCMUX) 
        0 : PC_next =  ; //cpu bus
        1 : PC_next = b; //jump address?
        2 : PC_next = PC + 1; 
        3 : PC_next = d; 
        default : $display("Error in SEL"); 
    endcase
    PC_next = MDR;
else
    PC_next = PC

// PC adder thing for BR, JSR, and LDR (also useful for the other instructions
// any instruction using offset 11, offset 9, and offset 6

// ADDR2 Mux
    case (ADDR2MUX) 
        0 : PC_next =  ; //cpu bus
        1 : PC_next = b; //jump address?
        2 : PC_next = PC + 1; 
        3 : PC_next = d; 
        default : $display("Error in SEL"); 
    endcase
    PC_next = MDR;
// ADDR1 Mux
case (ADDR1MUX) 
        0 : PC_next =  ; //cpu bus
        1 : PC_next = b; //jump address?
        default : $display("Error in SEL"); 
    endcase
    PC_next = MDR;

{,IR[10:0]}

case (sel) 
  0 : y = a; 
  1 : y = b; 
  2 : y = c; 
  3 : y = d; 
  default : $display("Error in SEL"); 
endcase

PCMUX

// Memory Address Register Datapath
if()

// Memory Data Register Datapath

// Status Register Datapath

// General Purpose Register Datapath

// Arithmetic Logic Unit Datapath

// DR destination register

end


endmodule