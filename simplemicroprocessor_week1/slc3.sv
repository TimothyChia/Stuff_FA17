//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Stephen Kempf
//
// Create Date:    
// Design Name:    ECE 385 Lab 6 Given Code - SLC-3 top-level (External SRAM)
// Module Name:    SLC3
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 09-22-2015 
//    Revised 04-25-2017 
//    Fall 2017 Distribution
//
//------------------------------------------------------------------------------

// Top level for Lab 6 with physical SRAM.
// For simulation with test_memory, you need to add another top-level module which
// instantiates slc3 and test_memory, and write another testbench which instantiate
// that new top-level module.
module slc3(
	input logic [15:0] S,
	input logic Clk, Reset, Run, Continue,
	output logic [11:0] LED,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
	output logic CE, UB, LB, OE, WE, //control signals for memory?
	output logic [19:0] ADDR,
	inout wire [15:0] Data, //tristate buffers need to be of type wire - this is the CPU Bus
	
	
	
	
	output logic [15:0] MDR_In_d, MAR_d, MDR_d, IR_d, PC_d,
	output logic LD_MAR_d, LD_MDR_d, LD_IR_d, LD_BEN_d, LD_CC_d, LD_REG_d, LD_PC_d, LD_LED_d
);



// Declaration of push button active high signals
logic Reset_ah, Continue_ah, Run_ah;

assign Reset_ah = ~Reset;//might have to use actual registers, how to reset? should we reset?
assign Continue_ah = ~Continue;
assign Run_ah = ~Run;

// Internal connections
logic BEN; // indicates whether a BR should be taken
logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED; //load signals for registers (mostly)
logic GatePC, GateMDR, GateALU, GateMARMUX; //tri state signals?
logic [1:0] PCMUX, ADDR2MUX, ALUK; // 2 bit select signals for muxes
logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX; // 1 bit mux select signals
logic MIO_EN; // enable for memory io of some kind?

// Buses or maybe registers if connected properly
logic [15:0] MDR_In; // comes out of the mem2IO
logic [15:0] MAR, MDR, IR, PC;
logic [15:0] Data_from_SRAM, Data_to_SRAM;

// Signals being displayed on hex display
logic [3:0][3:0] hex_4;

// For week 1, hexdrivers will display IR
 HexDriver hex_driver3 (IR[15:12], HEX3);
 HexDriver hex_driver2 (IR[11:8], HEX2);
 HexDriver hex_driver1 (IR[7:4], HEX1);
 HexDriver hex_driver0 (IR[3:0], HEX0);

// alternate version to view the MDR
//HexDriver hex_driver3 (MAR[15:12], HEX3);
//HexDriver hex_driver2 (MAR[11:8], HEX2);
//HexDriver hex_driver1 (MAR[7:4], HEX1);
//HexDriver hex_driver0 (MAR[3:0], HEX0);



// For week 2, hexdrivers will be mounted to Mem2IO
// HexDriver hex_driver3 (hex_4[3][3:0], HEX3);
// HexDriver hex_driver2 (hex_4[2][3:0], HEX2);
// HexDriver hex_driver1 (hex_4[1][3:0], HEX1);
// HexDriver hex_driver0 (hex_4[0][3:0], HEX0);

// The other hex display will show PC for both weeks.
HexDriver hex_driver7 (PC[15:12], HEX7);
HexDriver hex_driver6 (PC[11:8], HEX6);
HexDriver hex_driver5 (PC[7:4], HEX5);
HexDriver hex_driver4 (PC[3:0], HEX4);

// Connect MAR to ADDR, which is also connected as an input into MEM2IO.
// MEM2IO will determine what gets put onto Data_CPU (which serves as a potential
// input into MDR)
assign ADDR = { 4'b00, MAR }; //Note, our external SRAM chip is 1Mx16, but address space is only 64Kx16
assign MIO_EN = ~OE;

// debugging variables for simulation
assign MDR_In_d = MDR_In;
assign MAR_d=MAR;
assign MDR_d = MDR;
assign IR_d = IR;
assign PC_d = PC;

assign LD_MAR_d = LD_MAR;
assign LD_MDR_d = LD_MDR;
assign LD_IR_d = LD_IR;
assign LD_BEN_d = LD_BEN;
assign LD_CC_d = LD_CC;
assign LD_REG_d = LD_REG;
assign LD_PC_d = LD_PC;
assign LD_LED_d = LD_LED;

// You need to make your own datapath module and connect everything to the datapath
// Be careful about whether Reset is active high or low
datapath d0 (
    .S, //what's this for?
    .Clk, .Reset(Reset_ah), .Run(Run_ah), .Continue(Continue_ah),
    //.Data, //tristate buffers need to be of type wire - this is the CPU Bus NOT

    // Internal connections
    .BEN, // indicates whether a BR should be taken
    .LD_MAR, .LD_MDR, .LD_IR, .LD_BEN, .LD_CC, .LD_REG, .LD_PC, .LD_LED, //load signals for registers (mostly)
    .GatePC, .GateMDR, .GateALU, .GateMARMUX, //tri state signals?
    .PCMUX, .ADDR2MUX, .ALUK, // 2 bit select signals for muxes
    .DRMUX, .SR1MUX, .SR2MUX, .ADDR1MUX, // 1 bit mux select signals
    .MIO_EN, // enable for memory io of some kind?

    // Buses or maybe registers if connected properly
    .MDR_In, // comes out of the mem2IO
    .MAR, .MDR, .IR, .PC
    // .Data_from_SRAM, .Data_to_SRAM

    );

// Our SRAM and I/O controller
 Mem2IO memory_subsystem(
    .*, .Reset(Reset_ah), .ADDR(ADDR), .Switches(S),
    .HEX0(hex_4[0][3:0]), .HEX1(hex_4[1][3:0]), .HEX2(hex_4[2][3:0]), .HEX3(hex_4[3][3:0]),
    .Data_from_CPU(MDR), .Data_to_CPU(MDR_In),
    .Data_from_SRAM(Data_from_SRAM), .Data_to_SRAM(Data_to_SRAM)
);

// for the simulation, since bypassing mem2IO
// assign Data_to_SRAM = MDR;
// assign MDR_In = Data_from_SRAM;
// assign ADDR

// Data_Mem as referenced in the lab manual doesn't exist here since we use this tristate.
// The tri-state buffer serves as the interface between Mem2IO and SRAM
tristate #(.N(16)) tr0(
    .Clk(Clk), .tristate_output_enable(~WE), .Data_write(Data_to_SRAM), .Data_read(Data_from_SRAM), .Data(Data)
);

// State machine and control signals
ISDU state_controller(
    .*, .Reset(Reset_ah), .Run(Run_ah), .Continue(Continue_ah),
    .Opcode(IR[15:12]), .IR_5(IR[5]), .IR_11(IR[11]),
    .Mem_CE(CE), .Mem_UB(UB), .Mem_LB(LB), .Mem_OE(OE), .Mem_WE(WE)
);

endmodule
