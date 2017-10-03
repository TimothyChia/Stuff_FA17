module testbench_for_test_memory(	
    
    );

    logic [15:0] S;
	logic Clk, Reset, Run, Continue;
	logic [11:0] LED;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	logic CE, UB, LB, OE, WE; //control signals for memory?
	logic [19:0] ADDR;
	wire [15:0] Data; //tristate buffers need to be of type wire - this is the CPU Bus


timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1
timeprecision 1ns;

// These signals are internal because the processor will be
// instantiated as a submodule in testbench.
assign Clk = 0;

// // To store expected results
// logic [7:0] ans_1a, ans_2b;

// A counter to count the instances where simulation results
// do no match with expected results
// integer ErrorCnt = 0;


// Make sure the module and signal names match with those in your design
//painful bug due to use of synchronizers to invert buttons.
top_level_for_test_memory top_level_for_test_memory_inst(
                .S,
                .Clk, .Reset, .Run, .Continue,
                .LED,
                .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .HEX6, .HEX7,
                .CE, .UB, .LB, .OE, .WE, //control signals for memory?
                .ADDR,
                .Data //tristate buffers need to be of type wire - this is the CPU Bus
);

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
// Reset = 0;		// Toggle Rest
// S = 8'h0;
// ClearA_LoadB = 0;
// Run = 0;

// #2 Reset = 1;


// #2 Reset = 0;
// #2 S = 8'hF0;
// #2 ClearA_LoadB = 1;	// Toggle LoadA
// #5 ClearA_LoadB = 0;

// #2 S = 8'hF0;
// #2 Run = 1;
// #2 Run = 0;
// $display("testbench complete");  // Command line output in ModelSim

end


endmodule