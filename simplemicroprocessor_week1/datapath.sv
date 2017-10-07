module datapath(
	input logic [15:0] S, //what's this for?
	input logic Clk, Reset, Run, Continue,

//    inout wire [15:0] Data, //tristate buffers need to be of type wire - this is the CPU Bus. NOT THE CONNECTION TO SRAM.

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

    // output logic [15:0] Data_from_SRAM, Data_to_SRAM
);


// see page 8 of appendix C

// THIS IS THE CPU BUS. NOT THE SRAM. FULLY INTERNAL, NOT A PORT. previously named Data.
logic [15:0] CPU_BUS;
logic [2:0]  CC;
logic [2:0]  CC_next;

// for nzp combinational logic, not register
logic n,z,p;

// for the 2 always style
logic BEN_next;
//logic [15:0] MDR_In_next; //an input?
logic [15:0] MAR_next, MDR_next, IR_next, PC_next;
// logic [15:0] Data_from_SRAM_next, Data_to_SRAM_next;

logic [15:0] ADDR2, ADDR1, ADDR_sum, SR1, SR2, SR2MUX_out; 
logic [2:0] SR1MUX_out, DR;


register reg_file (   
    .Clk, .Load(LD_REG),
    .Write_sel(DR), .Read_sel_1( SR1MUX_out ), .Read_sel_2( IR[0:2] ),
    .Data_In(CPU_BUS),
    .Data_out_1(SR1), .Data_out_2(SR2)
                );



always_ff @(posedge Clk)
begin
	if(Reset) begin
	// MDR_In          <= 16'b0;
    MAR             <= 16'b0;
    MDR             <= 16'b0;
    IR              <= 16'b0;
    PC              <= 16'b0;
	end
	else begin
	// MDR_In          <= MDR_In_next;
    BEN             <= BEN_next;
    MAR             <= MAR_next;
    MDR             <= MDR_next;
    IR              <= IR_next;
    PC              <= PC_next;
    // Data_from_SRAM  <= Data_from_SRAM_next;
    // Data_to_SRAM    <= Data_to_SRAM_next;
    CC              <= CC_next;
	end



end


always_comb
begin

//nzp register
//only loaded when the result from ALU is on the data bus.
//supposedly the priority of nested else if would be enough here, 
//but it's a little confusing so I made it explicit with n z p logic variables.
n = CPU_BUS[15];
z = CPU_BUS == 16'b0;
p = !n && !z;

if(LD_CC) begin
    CC_next = {n,z,p};
end else begin
    CC_next = CC;
end

//BEN register
if(LD_BEN) begin
    if(IR[11:9] == CC ) 
        BEN_next = 1'b1;
    else
        BEN_next = 1'b0;
    end 
else
    BEN_next = BEN;

// CPU Bus Datapath 1 mux instead of 4 tristate buffers
// for select, use a bitstring made out of outputs from CONTROL perhaps.
// if you don't output high z it causes problems.
case ( {GatePC,GateMDR,GateALU,GateMARMUX}  ) 
    8 : CPU_BUS = PC; 
    4 : CPU_BUS = MDR ; 
    4 : CPU_BUS = ALU; 
    1 : CPU_BUS = ADDR_sum; 
    default : CPU_BUS = 16'bz; //for efficiency reasons, put x instead of z?
endcase

// PC datapath
// PC needs a reset to 0, an increment, an external value, and values for jumps
if(LD_PC) begin
    case (PCMUX) 
        0 : PC_next = PC + 1; 
        1 : PC_next = CPU_BUS ;
        2 : PC_next = ADDR_sum ; //jump address?
        // 3 : PC_next = d; 
        default : PC_next = 16'bx; 
    endcase
end else begin
    PC_next = PC;
end
// PC adder thing for BR, JSR, and LDR (also useful for the other instructions
// any instruction using offset 11, offset 9, and offset 6
ADDR_sum = ADDR2 + ADDR1;

// ADDR2 Mux
    case (ADDR2MUX) 
        0 : ADDR2 =   16'b0;
        1 : ADDR2 =  { { 10{IR[5]} }, IR[5:0] }
        2 : ADDR2 =  { { 7{IR[8]} }, IR[8:0] };  
        3 : ADDR2 =  { { 5{IR[10]} }, IR[10:0] }  ; 
        default : ADDR2 = 16'bx ; 
    endcase
// ADDR1 Mux
case (ADDR1MUX) 
        0 : ADDR1 = PC; //Base Register
        1 : ADDR1 = SR1 ;
        default : ADDR1 = 16'bx; 
    endcase

// Memory Address Register Datapath
if(LD_MAR) begin
   MAR_next = CPU_BUS;
end else begin
    MAR_next = MAR;
end
// Memory Data Register Datapath
if(LD_MDR) begin
    case (MIO_EN) 
        0 : MDR_next = CPU_BUS ; //cpu bus
        1 : MDR_next = MDR_In; //jump address?
        default : MDR_next = 16'bx; 
    endcase
end else begin
    MDR_next = MDR;
end
// Status Register Datapath

// General Purpose Register Datapath

// Arithmetic Logic Unit Datapath
// 00 - add
// 01 - AND
// 01 - NOT (wait what, why are they the same. change to 10?
case(ALUK)
    0: ALU = SR1 + SR2MUX_out;//add
    1: ALU = SR1 & SR2MUX_out;//AND
    2: ALU = ~SR1;            //NOT
    default: ALU = 16'bx;
endcase


// DR destination register MUX. Connects to the Reg File.
// = DR;
case (DRMUX)
    0: DR = 3'b111; //R7 by default 
    1: DR = IR[11:9];
endcase

//IR Instruction register Datapath
if(LD_IR) begin
   IR_next = CPU_BUS;
end else begin
    IR_next = IR;
end

// SR1 Mux. Output connects directly to the Reg File
case (SR1MUX) 
    0 : SR1MUX_out = IR[11:9] ;
    1 : SR1MUX_out = IR[8:6]  ; 
endcase
// SR2 Mux. Output connects directly to the ALU B input.
case (SR2MUX) 
    0 : SR2MUX_out =  SR2; // double check this name later.
    1 : SR2MUX_out = { { 11{IR[10]} }, IR[4:0] } ; //1 - immediate
endcase


end //of comb

endmodule