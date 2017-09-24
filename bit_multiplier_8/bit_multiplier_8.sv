module bit_multiplier_8
(
  input   logic           Clk,        // 50MHz clock is only used to get timing estimate data
  input   logic           Reset,      // From push-button 0.  Remember the button is active low (0 when pressed)
  input   logic           Run,        // From push-button 3.
  input   logic           ClearA_LoadB,      // From push-button 1
  input   logic[7:0]      S,         // From slider switches

  // all outputs are registered
  output  logic           X,         // Carry-out.  Goes to the green LED to the left of the hex displays.
  output  logic[15:0]     Sum,        // Goes to the red LEDs.  You need to press "Run" before the sum shows up here.
  output  logic[6:0]      Ahex0,      // Hex drivers display both inputs to the adder.
  output  logic[6:0]      Ahex1,

  output  logic[6:0]      Bhex2,
  output  logic[6:0]      Bhex3
  );

  /* Declare Internal Registers */
  logic[15:0]     A;  // use this as an input to your adder
  logic[15:0]     B;  // use this as an input to your adder

  /* Declare Internal Wires
   * Wheather an internal logic signal becomes a register or wire depends
   * on if it is written inside an always_ff or always_comb block respectivly */
  logic[6:0]      AhexU;
  logic[6:0]      AhexL;
  logic[6:0]      BhexU;
  logic[6:0]      BhexL;
  logic[7:0]     Aval; //wtf is this
  logic[7:0]     Bval;

  logic[8:0]     XA_Adder_Out;
  logic           XtoA;
  logic          AtoB;
  logic         Shift_En;
  logic         Ld_X;
  logic         Ld_A;
  logic         Ld_B;
  logic B_out; //garbage
  logic         X_in;

  logic[8:0] S_ext;
  logic[8:0] S_ext_flipped;


  /* Decoders for HEX drivers and output registers
   * Note that the hex drivers are calculated one cycle after Sum so
   * that they have minimal interfere with timing (fmax) analysis.
   * The human eye can't see this one-cycle latency so it's OK. */
  always_ff @(posedge Clk) begin

      Ahex0 <= Ahex0_comb;
      Ahex1 <= Ahex1_comb;

      Bhex2 <= Bhex2_comb;
      Bhex3 <= Bhex3_comb;

  end

  /* Module instantiation
   */

   control          control_unit (
                        .Clk(Clk),
                        .Reset(Reset_SH),
                        .ClearA_LoadB(ClearA_LoadB_SH),
                        .M(B[0]),
                        .Run(Run_SH),

                        .Shift_En,
                        .Clr_XA,
                        .Ld_B,
                        .Add, .Sub
                         );


  dreg   reg_X ( .Clk, Load(Ld_X), .Reset(Reset_X), D() , Q(XtoA) );
  reg_8  reg_A (.*, .Reset(Reset_XA), .Shift_In(XtoA), .Load(Ld_A),
               .Shift_Out(AtoB), .Data_Out(A) , .D(XA_Adder_Out[7:0])  );
  //B_out is garbage really.
  reg_8  reg_B (.*, .Shift_In(AtoB), .Load(Ld_B),
               .Shift_Out(B_out), .Data_Out(B));


//sign extending A is the same thing as taking XA after a shift has occurred.
 ripple_adder ripple_adder_inst
  (
      .A(adder_In),             // This is shorthand for .A(A) when both wires/registers have the same name
      .B({XtoA,A}), //attempt at concatenation, dunno if it'll work
      .Sum(XA_Adder_Out),
      .CO(CO_comb) //garbage?
  );



  ripple_adder S_inverter
   (
       .A(S_ext_flipped),             // This is shorthand for .A(A) when both wires/registers have the same name
       .B(1),
       .Sum(S_ext_neg), // Connects the Sum_comb wire in this file to the Sum wire in ripple_adder.sv
       .CO(ssomething)
   );

   //these just display the contents of A and B
  HexDriver        HexAL (
                       .In0(A[3:0]),
                       .Out0(AhexL) );
  HexDriver        HexBL (
                       .In0(B[3:0]),
                       .Out0(BhexL) );
  HexDriver        HexAU (
                       .In0(A[7:4]),
                       .Out0(AhexU) );
  HexDriver        HexBU (
                      .In0(B[7:4]),
                       .Out0(BhexU) );

   //Input synchronizers required for asynchronous inputs (in this case, from the switches)
	  //These are array module instantiations
	  //Note: S stands for SYNCHRONIZED, H stands for active HIGH
	  //Note: We can invert the levels inside the port assignments
    // these are pretty much just flipflops.
	  sync button_sync[3:0] (Clk, {~Reset, ~ClearA_LoadB, ~Run}, {Reset_SH, ClearA_LoadB_SH,  Run_SH});
	  sync S_sync[7:0] (Clk, S, S_S); //looks like it needs modification.


   always_comb begin

       //sign extend S, call it S_ext
       if(S[7])
         S_ext={1'b1,S};
       else
         S_ext={1'b0,S};

        S_ext_flipped=S^1;

       //mux for XA adder
       if(Sub)
         adder_In = S_ext_neg;
       else if(!Add)
          adder_In = 9'b000000000;
       else //should trigger if Add is true
         adder_In = S_ext;

         //mux for X
      if(Shift_En)
        X_in=XtoA;
      else
        X_in=XA_Adder_Out[8]

      //if an add state, then ld x and a
      Ld_X=Add;
      Ld_A=Add;

      //should only occur in state A, the initial state?
      Reset_X=Clr_XA;
      Reset_A=Clr_XA;

      //Reset_B

   end



endmodule
