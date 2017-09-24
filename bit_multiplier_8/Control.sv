//modified because a 8 bit needs more states

//Two-always example for state machine

module control (input  logic Clk, Reset, ClearA_LoadB, Run, M,
                output logic Clr_XA,Ld_B, Shift_En, Add, Sub);

    // Declare signals curr_state, next_state of type enum
    // with enum values of A, B, ..., F as the state values
	 // Note that the length implies a max of 8 states, so you will need to bump this up for 8-bits
   //bumped it up to add 4 more states.
    enum logic [3:0] {A, B, C, D, E, F, G,H,I,J}   curr_state, next_state;

	//updates flip flop, current state is the only one
    always_ff @ (posedge Clk)
    begin
        if (Reset)
            curr_state <= A;
        else
            curr_state <= next_state;
    end

    // Assign outputs based on state
	always_comb
    begin

		  next_state  = curr_state;	//required because I haven't enumerated all possibilities below
        unique case (curr_state)

            A :    if(Execute)
                       next_state = B;
            B :    next_state = C;
            C :    next_state = D;
            D :    next_state = E;
            E :    next_state = F;
//additional states to finish shifting
            F :    next_state = G;
            G :    next_state = H;
            H :    next_state = I;
            I :    next_state = J;

            J :    if (~Execute)
                       next_state = A;

        endcase

		  // Assign outputs based on ‘state’
        case (curr_state)
	   	   A:
	         begin
                Clr_XA = ClearA_LoadB;
                Ld_B = ClearA_LoadB;
                Add =1'b0;
                Shift_En = 1'b0;
                Sub=0'b0;
		      end
          //the add states
          B,D,F,H,J,L,N:
            begin
              Clr_XA=1'b0;
              Ld_B=1'b0;
              Add =1'b1;
              Shift_En=1'b0;
              Sub=0'b0;
            end
            //the shift states
          C,E,G,I,K,M,O,Q:
            begin
              Clr_XA=1'b0;
              Ld_B=1'b0;
              Add =1'b0;
              Shift_En=1'b1;
              Sub=0'b0;
            end
      //special add state for the 8th partial product
      P:
        begin
        Clr_XA=1'b0;
        Ld_B=1'b0;
        Add =1'b0;
        Shift_En=1'b0;
          if(M)
            Sub=0'b1;
          else
            Sub=0'b0;
        end




	   	   default:  //default case, can also have default assignments for Ld_A and Ld_B before case
                  //notice this means the default case is shifting the registers
		      begin
                Ld_A = 1'b0;
                Ld_B = 1'b0;
                Shift_En = 1'b1;
		      end
        endcase
    end

endmodule
