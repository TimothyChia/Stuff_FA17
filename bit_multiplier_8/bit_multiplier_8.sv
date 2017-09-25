module bit_multiplier_8
(
  input   logic           Clk,        // 50MHz clock is only used to get timing estimate data
  input   logic           Reset,      // M23 From push-button 0.  Remember the button is active low (0 when pressed)
  input   logic           Run,        // R24 From push-button 3.
  input   logic           ClearA_LoadB,//N21 From push-button 1
  input   logic[7:0]      S,         // From slider switches, continuously read for S

  // all outputs are registered
  output  logic           X,         // Carry-out.  Goes to the green LED to the left of the hex displays.
  output  logic[15:0]     Sum,        // Goes to the red LEDs.  You need to press "Run" before the sum shows up here.
  output logic [6:0]  Ahex0, Ahex1, Bhex0, Bhex1,
  output logic[7:0]     Aval, //used in the testbench.
  output logic[7:0]     Bval,
  output logic Dummy,
  output logic[8:0] D_S_ext_flipped, D_S_ext_neg
  );
  //wires for synchronized inputs
  logic Reset_SH, Run_SH, ClearA_LoadB_SH;
  logic[7:0]      S_S;



  /* Declare Internal Wires
   * Wheather an internal logic signal becomes a register or wire depends
   * on if it is written inside an always_ff or always_comb block respectivly */
  logic[6:0]      Ahex1_comb, Ahex0_comb, Bhex1_comb, Bhex0_comb;
  // logic[7:0]     Aval; //wtf is this
  // logic[7:0]     Bval;

  //XA
  logic[8:0]     adder_In,XA_Adder_Out;
  //X
  logic           XtoA, Reset_X;
  //A
  logic          AtoB, Reset_A;
  // for AB registers
  logic[7:0]     A;  //
  logic[7:0]     B;  //

  //adder
  logic CO_comb; //carry out is trash?


  //control unit
  logic         Shift_En;
  logic         Ld_X;
  logic         Ld_A;
  logic         Ld_B;
  logic         B_out; //garbage
  logic         X_in;

  logic Clr_XA;
  logic Add;
  logic Sub;
  logic D;
  logic M_bit;
  //various useful versions of S
  logic[8:0] S_ext, S_ext_flipped, S_ext_neg;

  logic something; //must be a trash somewjere


  /* Decoders for HEX drivers and output registers
   * Note that the hex drivers are calculated one cycle after Sum so
   * that they have minimal interfere with timing (fmax) analysis.
   * The human eye can't see this one-cycle latency so it's OK. */
  always_ff @(posedge Clk) begin

      Ahex1 <= Ahex1_comb;
      Ahex0 <= Ahex0_comb;

      Bhex1 <= Bhex1_comb;
      Bhex0 <= Bhex0_comb;

  end

  /* Module instantiation
   */

   control          control_unit (
                        .Clk(Clk),
                        .Reset(Reset_SH),
                        .ClearA_LoadB(ClearA_LoadB_SH),
                        .M_bit(M_bit),
                        .Run(Run_SH),

                        .Shift_En(Shift_En),
                        .Clr_XA(Clr_XA),
                        .Ld_B(Ld_B),
                        .Add(Add), .Sub(Sub)
                         );


  Dreg   reg_X ( .Clk(Clk), .Load(Ld_X), .Reset(Reset_X), .D(X_in) , .Q(XtoA) );
  reg_8  reg_A (.Clk(Clk), .Reset(Reset_A), .Shift_In(XtoA), .Load(Ld_A), .Shift_En(Shift_En), .D(XA_Adder_Out[7:0]),
               .Shift_Out(AtoB), .Data_Out(A)   );
  //B_out is garbage really.
  //annoying bug due to the similar names, do NOT use "Reset", it's active low.
  reg_8  reg_B (.Clk(Clk),.Reset(Reset_SH), .Shift_In(AtoB), .Load(Ld_B),.Shift_En(Shift_En), .D(S_S[7:0]),
               .Shift_Out(B_out), .Data_Out(B));


//sign extending A is the same thing as taking XA after a shift has occurred.
 ripple_adder ripple_adder_inst
  (
      .A(adder_In),             // This is shorthand for .A(A) when both wires/registers have the same name
      .B({XtoA,A}), //attempt at concatenation, dunno if it'll work
      .c_in(0),
      .Sum(XA_Adder_Out),
      .CO(CO_comb) //garbage?
  );



  ripple_adder S_inverter
   (
       .A(S_ext_flipped),             // This is shorthand for .A(A) when both wires/registers have the same name
       .B(9'b1),
       .c_in(1'b0),
       .Sum(S_ext_neg), // Connects the Sum_comb wire in this file to the Sum wire in ripple_adder.sv
       .CO(something)
   );

   //these just display the contents of A and B
  HexDriver        HexAL (
                       .In0(A[3:0]),
                       .Out0(Ahex0_comb) );
  HexDriver        HexBL (
                       .In0(B[3:0]),
                       .Out0(Bhex0_comb) );
  HexDriver        HexAU (
                       .In0(A[7:4]),
                       .Out0(Ahex1_comb) );
  HexDriver        HexBU (
                      .In0(B[7:4]),
                       .Out0(Bhex1_comb) );

   //Input synchronizers required for asynchronous inputs (in this case, from the switches)
	  //These are array module instantiations
	  //Note: S stands for SYNCHRONIZED, H stands for active HIGH
	  //Note: We can invert the levels inside the port assignments
    // these are pretty much just flipflops.
	  sync button_sync[2:0] (Clk, {~Reset, ~ClearA_LoadB, ~Run}, {Reset_SH, ClearA_LoadB_SH,  Run_SH});
	  sync S_sync[7:0] (Clk, S, S_S); //looks like it needs modification.


   always_comb begin
      X=XtoA;
      Sum[7:0]=S_S; //repurposing to test the synchronization of the switches.

        M_bit=B[0];

       //sign extend S, call it S_ext
       if(S_S[7])
         S_ext={1'b1,S_S};
       else
         S_ext={1'b0,S_S};

        S_ext_flipped=S_ext^9'b111111111; //plz pay attention to the syntax of literals.

       //mux for XA adder
       if(Sub)
         adder_In = S_ext_neg;
       else if(!M_bit)
          adder_In = 9'b000000000;
       else //should trigger if Add is true
         adder_In = S_ext;

         //mux for X
      if(Shift_En)
        X_in=XtoA;
      else
        X_in=XA_Adder_Out[8];

      //if an add state, then ld x and a
      Ld_X=Add;
      Ld_A=Add;

      //should only occur in state A, the initial state?
      Reset_X=Clr_XA;
      Reset_A=Clr_XA;

      //Reset_B

      Aval=A;
      Bval=B;

      Dummy=Sub;
      D_S_ext_flipped=S_ext_flipped;
      D_S_ext_neg=S_ext_neg;
   end



endmodule
