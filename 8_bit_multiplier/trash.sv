//special register for XAB

module reg_XAB (input  logic Clk, Reset, ClearA_LoadB, Shift_In, ClearA, Shift_En,
              input  logic [16:0]  XAB_next,
              output logic Shift_Out,
              output logic [16:0]  XAB_cur);

    logic X= XAB_cur[16]; // is X reserved in sv?
    logic A= XAB_cur[15:8];
    logic B= XAB_cur[7:0];


    always_ff @ (posedge Clk)
    begin
	 	   XAB_cur <= XAB_
    end

    always_comb
    begin
        if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
          XAB_cur <= 17'h0;
       else if (ClearA)
          A <= 9'h0;
       else if (ClearA_LoadB)
           A <= 9'h0;
           B =

       begin
          //concatenate shifted in data to the previous left-most 7 bits
          //note this works because we are in always_ff procedure block
          Data_Out <= { Shift_In, Data_Out[7:1] };
        end
    end


    assign Shift_Out = Data_Out[0];

endmodule
