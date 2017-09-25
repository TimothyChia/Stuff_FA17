//modified because a 8 bit needs more states

//Two-always example for state machine

module control (input  logic Clk, Reset, ClearA_LoadB, Run, M_bit,
                output logic Clr_XA,Ld_B, Shift_En, Add, Sub);

    // Declare signals curr_state, next_state of type enum
    // with enum values of A, B, ..., F as the state values
	 // Note that the length implies a max of 8 states, so you will need to bump this up for 8-bits
   //bumped it up to add more states.
   //be careful not to use the same names as other things. like M.
    enum logic [4:0] {A, B, C, D, E, F, G,H,I,J,K,L,M,N,O,P,Q,R,S,T}   curr_state, next_state;

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

            A :    if(Run)
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
            J :    next_state = K;
            K :    next_state = L;
            L :    next_state = M;
            M :    next_state = N;
            N :    next_state = O;
            O :    next_state = P;
            P :    next_state = Q;
            Q :    next_state = R;
            // this state machine goes way faster than a human finger can move. annoying bug because of that.

            R :    if (!Run)
                       next_state = S;
           //should just stop in this state until reset or Run is pressed a second time.
           //do NOT clear XA in this state.
            S:     if(Run)
                      next_state = T;
           //used to clear XA before Running consecutively
            T :    next_state = B;

        endcase

		  // Assign outputs based on ‘state’
        case (curr_state)
	   	   A:
	         begin
                Clr_XA = 1; //specifications are unclear about whether to clear B on pressing reset
                Ld_B = ClearA_LoadB;
                Add =1'b0;
                Shift_En = 1'b0;
                Sub=1'b0;
		      end
          //the add states
          B,D,F,H,J,L,N:
            begin
              Clr_XA=1'b0;
              Ld_B=1'b0;
              Add =1'b1;
              Shift_En=1'b0;
              Sub=1'b0;
            end
            //the shift states
          C,E,G,I,K,M,O,Q:
            begin
              Clr_XA=1'b0;
              Ld_B=1'b0;
              Add =1'b0;
              Shift_En=1'b1;
              Sub=1'b0;
            end
      //special add state for the 8th partial product
      P:
        begin
        Clr_XA=1'b0;
        Ld_B=1'b0;
        Add =1'b1;
        Shift_En=1'b0;
          if(M_bit)
            Sub=1'b1;
          else
            Sub=1'b0;
        end
          //special state for after calculation is done
      R:
        begin
             Clr_XA = 0;
             Ld_B = 0;
             Add =1'b0;
             Shift_En = 1'b0;
             Sub=1'b0;
        end
          //special state for chaining multiplication. same as A, but auto-progresses to B.
      S:
        begin
             Clr_XA = 0; //specifications are unclear about whether to clear B on pressing reset
             Ld_B = 0;
             Add =1'b0;
             Shift_En = 1'b0;
             Sub=1'b0;
       end
       //prepare to do a consecutive multiply
       T:
           begin
                Clr_XA = 1;
                Ld_B = 0;
                Add =1'b0;
                Shift_En = 1'b0;
                Sub=1'b0;
          end

	   	   default:  //default case, can also have default assignments for Ld_A and Ld_B before case
                  //notice this means the default case is shifting the registers
		      begin
            Clr_XA = ClearA_LoadB;
            Ld_B = ClearA_LoadB;
            Add =1'b0;
            Shift_En = 1'b0;
            Sub=1'b0;
		      end
        endcase
    end

endmodule
