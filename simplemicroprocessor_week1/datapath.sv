module datapath(
	input logic [15:0] S, //what's this for?
	input logic Clk, Reset, Run, Continue,
    output logic [11:0] LED,
//    inout wire [15:0] Data, //tristate buffers need to be of type wire - this is the CPU Bus. NOT THE CONNECTION TO SRAM.

	// Internal connections
    output logic BEN, // indicates whether a BR should be taken
    input logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED, //load signals for registers (mostly)
    input logic GatePC, GateMDR, GateALU, GateMARMUX, //tri state signals?
    input logic [1:0] PCMUX, ADDR2MUX, ALUK, // 2 bit select signals for muxes
    input logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX, // 1 bit mux select signals
    input logic MIO_EN, // enable for memory io of some kind?

    // Buses or maybe registers if connected properly
    input logic [15:0] MDR_In, // comes out of the mem2IO
    output logic [15:0] MAR, MDR, IR, PC,

    // output logic [15:0] Data_from_SRAM, Data_to_SRAM

    output logic   [15:0] R7d, R6d, R5d, R4d, R3d, R2d, R1d, R0d,
    output logic [15:0] CPU_BUSd, ALUd,ADDR_sumd,ADDR1d,ADDR2d,

    output logic [2:0] CCd,
    output logic BENd, n_d, z_d, p_d
);


// see page 8 of appendix C

// THIS IS THE CPU BUS. NOT THE SRAM. FULLY INTERNAL, NOT A PORT. previously named Data.
logic [15:0] CPU_BUS;
logic [11:0] LED_next; //seems a little odd holding this in a register, but 2 pause states means it should work as expected.

logic [15:0] ALU; //for the output of the ALU
logic [2:0]  CC;
logic [2:0]  CC_next;

// for nzp combinational logic, not register
logic n,z,p;
//logic [15:0] n;

// for the 2 always style
logic BEN_next;
//logic [15:0] MDR_In_next; //an input?
logic [15:0] MAR_next, MDR_next, IR_next, PC_next;
// logic [15:0] Data_from_SRAM_next, Data_to_SRAM_next;

logic [15:0] ADDR2, ADDR1, ADDR_sum, SR1, SR2, SR2MUX_out; 
logic [2:0] SR1MUX_out, DR;

logic [15:0] ALU_sum;

register reg_file (   
    .Clk, .Load(LD_REG), .Reset,
    .Write_sel(DR), .Read_sel_1( SR1MUX_out ), .Read_sel_2( IR[2:0] ),
    .Data_In(CPU_BUS),
    .Data_out_1(SR1), .Data_out_2(SR2),
    .*
                );


carry_lookahead_adder address_adder
(
    .A(ADDR1),
    .B(ADDR2),
    .Sum(ADDR_sum),
    .CO()
);
carry_lookahead_adder ALU_adder
(
    .A(SR1),
    .B(SR2MUX_out),
    .Sum(ALU_sum),
    .CO()
);

//  CPU_BUS_MUX cpubm (.select({GatePC,GateMDR,GateALU,GateMARMUX}  ),
//                 .PC,.MDR,.ALU,.ADDR_sum,.dc(16'bx),
//                 .CPU_BUS,
//              );



assign CPU_BUSd=CPU_BUS;
assign ALUd=ALU;
assign ADDR_sumd=ADDR_sum;
assign ADDR1d=ADDR1;
assign ADDR2d=ADDR2;
assign CCd=CC;
assign BENd=BEN;
assign n_d=n;
assign z_d=z;
assign p_d=p;

//assign n=CPU_BUS[15];
//assign z = (CPU_BUS == 16'b0)? 1:0; //added parantheses to try to eliminate erroneous don't care.
//assign p = (!n && !z) ? 1:0  ;


always_ff @(posedge Clk)
begin
	if(Reset) begin
	// MDR_In          <= 16'b0;
    MAR             <= 16'b0;
    MDR             <= 16'b0;
    IR              <= 16'b0;
    PC              <= 16'b0;
    // CC              <= 3'b0; //note unconditional branch won't work properly if you reset to 0
	end
	else begin
	// MDR_In          <= MDR_In_next;
    BEN             <= BEN_next;
    MAR             <= MAR_next;
    MDR             <= MDR_next;
    IR              <= IR_next;
    PC              <= PC_next;
    CC              <= CC_next;
    LED             <= LED_next;
	end



end


always_comb
begin

//nzp register
//only loaded when the result from ALU is on the data bus.
//supposedly the priority of nested else if would be enough here, 
//but it's a little confusing so I made it explicit with n z p logic variables.
//not sure why, but a CPU_BUS value of 0000 is resulting in xxx for nzp here.

 n=CPU_BUS[15];
 z = (CPU_BUS == 16'b0)? 1:0; //added parantheses to try to eliminate erroneous don't care.
 p = (!n && !z) ? 1:0  ;

if(LD_CC) begin
    CC_next = {1'b1,z,p};
end else begin
    CC_next = CC;
end

if(LD_LED)
    LED_next = IR[11:0];
else
    LED_next = LED;


//BEN register
//see appendix A, this should actually be BEN=1 if any bits match, not all bits match.
if(LD_BEN) begin
    if(  (IR[11] == CC[2])  ||     (IR[10] == CC[1])  ||  (IR[9] == CC[0])   ) 
        BEN_next = 1'b1;
    else
        BEN_next = 1'b0;
    end 
else
    BEN_next = BEN;

// CPU Bus Datapath 1 mux instead of 4 tristate buffers
// for select, use a bitstring made out of outputs from CONTROL perhaps.
// if you don't output high z it causes problems. 1
// nzp is having erroneous don't care values. because of using x here?   3
//switching to 0 default fixed nzp, probably won't introduce any other errors if the state machine is correct.
case ( {GatePC,GateMDR,GateALU,GateMARMUX}  ) 
   8 : CPU_BUS = PC; 
   4 : CPU_BUS = MDR ; 
   2 : CPU_BUS = ALU; 
   1 : CPU_BUS = ADDR_sum; 
   default : CPU_BUS = 16'bx; //for efficiency reasons, put x instead of z? 2
endcase



// PC datapath
// PC needs a reset to 0, an increment, an external value, and values for jumps
if(LD_PC) begin
    case (PCMUX) 
        0 : PC_next = PC + 16'b1; 
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
// No idea why this doesn't work, but it produces 0000+FFFF = 02
// ADDR_sum = ADDR2 + ADDR1;




// ADDR1 Mux
case (ADDR1MUX) 
        0 : ADDR1 = PC; //Base Register
        1 : ADDR1 = SR1 ;
    endcase
// ADDR2 Mux

// THIS SEXT SYNTAX DOES NOT WORK FOR SOME REASON.
case (ADDR2MUX) 
    0 : ADDR2 =   16'b0;
    1 : ADDR2 =  { { 10{IR[5]} }, IR[5:0] };
    2 : ADDR2 =  { { 7{IR[8]} }, IR[8:0] };  
    3 : ADDR2 =  { { 5{IR[10]} }, IR[10:0] }  ; 
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
        1 : MDR_next = MDR_In; //from mem2IO
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
// 01 - NOT (wait what, why are they the same. change to 10? must have been a typo by 385 staff.
case(ALUK)
    // 0: ALU = SR1 + SR2MUX_out;//add
    0: ALU = ALU_sum;//add    
    1: ALU = SR1 & SR2MUX_out;//AND
    2: ALU = ~SR1;            //NOT
    default: ALU = 16'b0;
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
    1 : SR2MUX_out = { { 11{IR[4]} }, IR[4:0] } ; //1 - immediate
endcase


end //of comb

endmodule