module testbench_for_test_memory(	
    
    );

	 timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1
timeprecision 1ns;

	 
logic [15:0] S;
logic  Reset, Run, Continue;
logic [11:0] LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
logic CE, UB, LB, OE, WE; //control signals for memory?
logic [19:0] ADDR;
// wire [15:0] Data; //tristate buffers need to be of type wire - this is the CPU Bus


logic [15:0] MDR_In_d, MAR_d, MDR_d, IR_d, PC_d;

logic LD_MAR_d, LD_MDR_d, LD_IR_d, LD_BEN_d, LD_CC_d, LD_REG_d, LD_PC_d, LD_LED_d;

logic   [15:0] R7d, R6d, R5d, R4d, R3d, R2d, R1d, R0d;
logic [15:0] CPU_BUSd, ALUd,ADDR_sumd,ADDR1d,ADDR2d;
logic [1:0] ADDR2MUXd;

     logic [2:0] CCd;
     logic BENd, n_d, z_d, p_d;

// These signals are internal because the processor will be
// instantiated as a submodule in testbench.
logic Clk = 0;

// // To store expected results
// logic [7:0] ans_1a, ans_2b;

// A counter to count the instances where simulation results
// do no match with expected results
// integer ErrorCnt = 0;


// Make sure the module and signal names match with those in your design
//painful bug due to use of synchronizers to invert buttons.
top_level_for_test_memory top_level_for_test_memory_inst(
                .S,
                .Clk, .Reset(~Reset), .Run(~Run), .Continue(~Continue),
                .LED,
                .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .HEX6, .HEX7,
                .CE, .UB, .LB, .OE, .WE, //control signals for memory?
                .ADDR,
                .Data(), //tristate buffers need to be of type wire - this is the CPU Bus
					 //don't know why we instantiate Data to nothing, but the TA claims this fixes the sim perrors
					 
					 					 .MDR_In_d, .MAR_d, .MDR_d, .IR_d, .PC_d,
					.*
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
 Reset = 0;		// Toggle Rest
 Run = 0;
 Continue = 0;
 
 #2 Reset = 1;
 #2 Reset = 0;
    S = 11;

 #2 Run = 1;
 #2 Run = 0;

 #50

#2 Continue = 1;
#2 Continue = 0; 
#10

#2 Continue = 1;
#2 Continue = 0; 
#10

#2 Continue = 1;
#2 Continue = 0; 
#10

#2 Continue = 1;
#2 Continue = 0; 
#10


#2 Continue = 1;
#2 Continue = 0; 
#10

#2 Continue = 1;
#2 Continue = 0; 
#10

#2 Continue = 1;
#2 Continue = 0; 
#10

#2 Continue = 1;
#2 Continue = 0; 
#10


#2 Continue = 1;
#2 Continue = 0; 
#10

#2 Continue = 1;
#2 Continue = 0; 
#10

#2 Continue = 1;
#2 Continue = 0; 
#10

#2 Continue = 1;
#2 Continue = 0; 
#10


#2 Continue = 1;
#2 Continue = 0; 
#10

#2 Continue = 1;
#2 Continue = 0; 
#10

#2 Continue = 1;
#2 Continue = 0; 
#10

#2 Continue = 1;
#2 Continue = 0; 
#10


 $display("testbench complete");  // Command line output in ModelSim

end


endmodule