module datapath(
	input logic [15:0] S, //what's this for?
	input logic Clk, Reset, Run, Continue,

    inout wire [15:0] Data //tristate buffers need to be of type wire - this is the CPU Bus

	// Internal connections
    input logic BEN, // indicates whether a BR should be taken
    input logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED, //load signals for registers (mostly)
    input logic GatePC, GateMDR, GateALU, GateMARMUX, //tri state signals?
    input logic [1:0] PCMUX, ADDR2MUX, ALUK, // 2 bit select signals for muxes
    input logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX, // 1 bit mux select signals
    input logic MIO_EN, // enable for memory io of some kind?

    // Buses or maybe registers if connected properly
    input logic [15:0] MDR_In, // comes out of the mem2IO
    output logic [15:0] MAR, MDR, IR, PC
    // logic [15:0] Data_from_SRAM, Data_to_SRAM;


);



// for the 2 always style
logic BEN_next;
logic [15:0] MDR_In_next;
logic [15:0] MAR_next, MDR_next, IR_next, PC_next;
logic [15:0] Data_from_SRAM_next, Data_to_SRAM_next;

logic [15:0] ADDR2, ADDR1, ADDR_sum, SR1, SR2, ALUA, ALUB, SR2MUX_out; // does this already exist somewhere? used for adder
logic [2:0] SR1MUX_out, DR;

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

// CPU Bus Datapath 1 mux instead of 4 tristate buffers
// for select, use a bitstring made out of outputs from CONTROL perhaps.
case ( {GatePC,GateMDR,GateALU,GateMARMUX}  ) 
    1 : Data = PC; 
    2 : Data = MDR ; 
    4 : Data = ALU; 
    8 : Data = MARMUX; 
    default : Data = x; 

// PC datapath
// PC needs a reset to 0, an increment, an external value, and values for jumps
if(LD_PC) begin
    case (PCMUX) 
        0 : PC_next =  ; //cpu bus
        1 : PC_next = ADDR_sum ; //jump address?
        2 : PC_next = PC + 1; 
        3 : PC_next = d; 
        default : $display("Error in SEL"); 
    endcase
end else begin
    PC_next = PC;
end
// PC adder thing for BR, JSR, and LDR (also useful for the other instructions
// any instruction using offset 11, offset 9, and offset 6
ADDR_sum = ADDR2 + ADDR1;

// ADDR2 Mux
    case (ADDR2MUX) 
        0 : ADDR2 = { { 5{IR[10]} }, IR[10:0] }  ; 
        1 : ADDR2 = { { 7{IR[8]} }, IR[8:0] };
        2 : ADDR2 = { { 10{IR[5]} }, IR[5:0] }; 
        3 : ADDR2 = IR; 
        default : $display("Error in SEL"); 
    endcase
// ADDR1 Mux
case (ADDR1MUX) 
        0 : ADDR1 = SR1 ; // double check this name later.
        1 : ADDR1 = PC; 
        default : $display("Error in SEL"); 
    endcase

// Memory Address Register Datapath
if(LD_MAR) begin
   MAR_next = Data;
end else
    MAR_next = MAR;
end
// Memory Data Register Datapath
if(LD_MDR) begin
    case (MIO_EN) 
        0 : MDR_next = Data ; //cpu bus
        1 : MDR_next = MDR_In; //jump address?
        default : $display("Error in SEL"); 
    endcase
end else
    MDR_next = MDR;
end
// Status Register Datapath

// General Purpose Register Datapath

// Arithmetic Logic Unit Datapath

// DR destination register MUX. Connects to the Reg File.
= DR;
if(DRMUX) begin
    DR = 3'b111;
end else
    DR = IR[11:9];
end

//IR Instruction register Datapath
if(LD_IR) begin
   IR_next = Data;
end else
    IR_next = IR;
end
// SR1 Mux. Output connects directly to the Reg File
case (SR1MUX) 
    0 : SR1MUX_out = IR[11:9] ;
    1 : SR1MUX_out = IR[8:6]  ; 
    default : $display("Error in SEL"); 
endcase
// SR2 Mux. Output connects directly to the ALU B input.
ALUB = SR2MUX_out;
case (SR2MUX) 
    0 : SR2MUX_out = { { 11{IR[10]} }, IR[4:0] } ; // double check this name later.
    1 : SR2MUX_out = SR2; 
    default : $display("Error in SEL"); 
endcase

//BEN the BR logic datapath for branching


endmodule