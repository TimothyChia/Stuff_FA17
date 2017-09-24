module 8_bi_multiplier.sv
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
  output  logic[6:0]      Ahex2,
  output  logic[6:0]      Ahex3,
  output  logic[6:0]      Bhex0,
  output  logic[6:0]      Bhex1,
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
  logic           X;

  /* Behavior of registers A, B, Sum, and CO */
  always_ff @(posedge Clk) begin

      if (!Reset) begin
          // if reset is pressed, clear the adder's input registers
          A <= 16'h0000;
          B <= 16'h0000;
          Sum <= 16'h0000;
          CO <= 1'b0;
      end else if (!LoadB) begin
          // If LoadB is pressed, copy switches to register B
          B <= SW;
      end else begin
          // otherwise, continuously copy switches to register A
          A <= SW;
      end

      // transfer sum and carry-out from adder to output register
      // every clock cycle that Run is pressed
      if (!Run) begin
          Sum <= Sum_comb;
          CO <= CO_comb;
      end
          // else, Sum and CO maintain their previous values

  end

  /* Decoders for HEX drivers and output registers
   * Note that the hex drivers are calculated one cycle after Sum so
   * that they have minimal interfere with timing (fmax) analysis.
   * The human eye can't see this one-cycle latency so it's OK. */
  always_ff @(posedge Clk) begin

      Ahex0 <= Ahex0_comb;
      Ahex1 <= Ahex1_comb;
      Ahex2 <= Ahex2_comb;
      Ahex3 <= Ahex3_comb;
      Bhex0 <= Bhex0_comb;
      Bhex1 <= Bhex1_comb;
      Bhex2 <= Bhex2_comb;
      Bhex3 <= Bhex3_comb;

  end

  /* Module instantiation
  * You can think of the lines below as instantiating objects (analogy to C++).
   * The things with names like Ahex0_inst, Ahex1_inst... are like a objects
   * The thing called HexDriver is like a class
   * Each time you instantate an "object", you consume physical hardware on the FPGA
   * in the same way that you'd place a 74-series hex driver chip on your protoboard
   * Make sure only *one* adder module (out of the three types) is instantiated*/


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


endmodule
