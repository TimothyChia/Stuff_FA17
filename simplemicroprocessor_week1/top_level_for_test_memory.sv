module top_level_for_test_memory(	
    input logic [15:0] S,
	input logic Clk, Reset, Run, Continue,
	output logic [11:0] LED,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
	output logic CE, UB, LB, OE, WE, //control signals for memory?
	output logic [19:0] ADDR,
	inout wire [15:0] Data //tristate buffers need to be of type wire - this is the CPU Bus
    );

slc3 slc3_inst(
                .S,
                .Clk, .Reset, .Run, .Continue,
                .LED,
                .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .HEX6, .HEX7,
                .CE, .UB, .LB, .OE, .WE, //control signals for memory?
                .ADDR,
                .Data //tristate buffers need to be of type wire - this is the CPU Bus
);


test_memory test_memory_inst (.Clk,
                .Reset, 
                .I_O(Data),
                .A,
                .CE,
                .UB,
                .LB,
                .OE,
                .WE );