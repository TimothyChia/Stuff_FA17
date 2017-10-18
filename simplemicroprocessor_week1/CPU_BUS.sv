// module CPU_BUS_MUX (input  logic [3:0] select,
//                 input logic [15:0] PC,MDR,ALU,ADDR_sum,dc,
//                 output logic  [15:0] CPU_BUS

//              );


// always_comb
// begin

// if(select==4'b1000) begin
//   CPU_BUS = PC; 
// end else if(select=4'b0100)begin
//  CPU_BUS = MDR ; 
// end else if(select=4'b0010)begin
//  CPU_BUS = ALU; 
// end else if(select==4'b0001)begin
//   CPU_BUS = ADDR_sum; 
// end else begin
//   CPU_BUS = dc; //for efficiency reasons, put x instead of z? 2
// end

// end

// endmodule