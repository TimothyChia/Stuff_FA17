module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1
timeprecision 1ns;

// These signals are internal because the processor will be
// instantiated as a submodule in testbench.
logic Clk = 0;
logic Reset, ClearA_LoadB, Run;
logic [7:0] S,Aval,Bval;
// logic [3:0] LED;
// logic [7:0] Aval,
// 		 Bval;
logic [6:0] Ahex0,
		 Ahex1,
		 Bhex0,
		 Bhex1;
logic X;
logic[15:0]     Sum;
logic Dummy;
logic[8:0] D_S_ext_flipped, D_S_ext_neg;

// To store expected results
logic [7:0] ans_1a, ans_2b;

// A counter to count the instances where simulation results
// do no match with expected results
integer ErrorCnt = 0;

// Instantiating the DUT
// Make sure the module and signal names match with those in your design
//painful bug due to use of synchronizers to invert buttons.
bit_multiplier_8 bit_multiplier(.*,
              .Clk,        // 50MHz clock is only used to get timing estimate data
             .Reset(~Reset),      // M23 From push-button 0.  Remember the button is active low (0 when pressed)
             .Run(~Run),        // R24 From push-button 3.
         .ClearA_LoadB(~ClearA_LoadB)//N21 From push-button 1
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
S = 8'h0;
ClearA_LoadB = 0;
Run = 0;

#2 Reset = 1;


#2 Reset = 0;
#2 S = 8'hFF;
#2 ClearA_LoadB = 1;	// Toggle LoadA
#5 ClearA_LoadB = 0;

#2 S = 8'hFF;
#2 Run = 1;
#2 Run = 0;
#22
$display("testbench complete");  // Command line output in ModelSim

//
// #22 Execute = 1;
//     ans_1a = (8'h33 ^ 8'h55); // Expected result of 1st cycle
//     // Aval is expected to be 8’h33 XOR 8’h55
//     // Bval is expected to be the original 8’h55
//     if (Aval != ans_1a)
// 	 ErrorCnt++;
//     if (Bval != 8'h55)
// 	 ErrorCnt++;
//     F = 3'b110;	// Change F and R
//     R = 2'b01;
//
// #2 Execute = 0;	// Toggle Execute
// #2 Execute = 1;
//
// #22 Execute = 0;
//     // Aval is expected to stay the same
//     // Bval is expected to be the answer of 1st cycle XNOR 8’h55
//     if (Aval != ans_1a)
// 	 ErrorCnt++;
//     ans_2b = ~(ans_1a ^ 8'h55); // Expected result of 2nd  cycle
//     if (Bval != ans_2b)
// 	 ErrorCnt++;
//     R = 2'b11;
// #2 Execute = 1;
//
// // Aval and Bval are expected to swap
// #22 if (Aval != ans_2b)
// 	 ErrorCnt++;
//     if (Bval != ans_1a)
// 	 ErrorCnt++;
//
//
// if (ErrorCnt == 0)
// 	$display("Success!");  // Command line output in ModelSim
// else
// 	$display("%d error(s) detected. Try again!", ErrorCnt);
end
endmodule
