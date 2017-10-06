module top_level_for_test_memory(	
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

//think the compiler complains about all the Data connections I made

// logic   [19:0]  A; //no idea what this does, but it's for the test memory
							//should really go back and read my own comments sometime, this was supposed to be the address input.

slc3 slc3_inst(
                .S,
                .Clk, .Reset, .Run, .Continue,
                .LED,
                .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .HEX6, .HEX7,
                .CE, .UB, .LB, .OE, .WE, //control signals for memory?
                .ADDR,
                .Data, //tristate buffers need to be of type wire - this is the CPU Bus
					 
					 .MDR_In_d, .MAR_d, .MDR_d, .IR_d, .PC_d,
					 .*
);


test_memory test_memory_inst (.Clk,
                .Reset(~Reset), //invert to get active high.
                .I_O(Data),
                .A(ADDR), // do this lol.
                .CE,
                .UB,
                .LB,
                .OE,
                .WE );

                endmodule