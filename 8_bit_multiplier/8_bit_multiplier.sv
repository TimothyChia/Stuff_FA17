module 8_bit_multiplier.sv
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
  logic[7:0]     Aval;
  logic[7:0]     Bval;
  logic           data_X;
  logic          AtoB;
  logic Shift_en;

  /* Behavior of registers A, B, Sum, and CO */
  always_ff @(posedge Clk) begin


  end

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
                        .LoadA(LoadA_SH),
                        .LoadB(LoadB_SH),
                        .Execute(Execute_SH),
                        .Shift_En,
                        .Ld_A,
                        .Ld_B );

        //all three share shift enable?
  dreg   reg_X ( .Clk, Load, Reset_XA, D, Q );
  //
  reg_8  reg_A (.*, .Reset(Reset_XA), .Shift_In(data_X), .Load(Ld_A),
               .Shift_Out(AtoB), .Data_Out(A));
  //B_out is garbage really.
  reg_8  reg_B (.*, .Shift_In(AtoB), .Load(Ld_B),
               .Shift_Out(B_out), .Data_Out(B));



 ripple_adder ripple_adder_inst
  (
      .A,             // This is shorthand for .A(A) when both wires/registers have the same name
      .B,
      .Sum(Sum_comb), // Connects the Sum_comb wire in this file to the Sum wire in ripple_adder.sv
      .CO(CO_comb)
  );

  HexDriver        HexAL (
                       .In0(A[3:0]),
                       .Out0(AhexL) );
  HexDriver        HexBL (
                       .In0(B[3:0]),
                       .Out0(BhexL) );

  //When you extend to 8-bits, you will need more HEX drivers to view upper nibble of registers, for now set to 0
  //now modified
  HexDriver        HexAU (
                       .In0(A[7:4]),
                       .Out0(AhexU) );
  HexDriver        HexBU (
                      .In0(B[7:4]),
                       .Out0(BhexU) );
   //
  //  always_comb begin
  //
  //  end



endmodule
