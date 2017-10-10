// not for week 1

//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module ISDU (   input logic         Clk,
                                    Reset,
                                    Run,
                                    Continue,

                input logic[3:0]    Opcode,
                input logic         IR_5,  // for AND ANDi ADD ADDi
                input logic         IR_11, // for JSR
                input logic         BEN,  // handle the nzp comparison outside of the ISDU

                output logic        LD_MAR,
                                    LD_MDR,
                                    LD_IR,
                                    LD_BEN,
                                    LD_CC,
                                    LD_REG,
                                    LD_PC,
                                    LD_LED, // for PAUSE instruction

                output logic        GatePC,
                                    GateMDR,
                                    GateALU,
                                    GateMARMUX,

                output logic [1:0]  PCMUX,
                output logic        DRMUX,
                                    SR1MUX,
                                    SR2MUX,
                                    ADDR1MUX,
                output logic [1:0]  ADDR2MUX,
                                    ALUK,

                output logic        Mem_CE,
                                    Mem_UB,
                                    Mem_LB,
                                    Mem_OE,
                                    Mem_WE

                // output logic [4:0] state
                );

    enum logic [4:0] {  Halted,
                        P1A,P1B,P2A,P2B,P3A,P3B,
                        PauseIR1,
                        PauseIR2,
                        S_18,
                        S_33_1,
                        S_33_2,
                        S_35,
                        S_32,
                        S_01, //ADD
            S_05, //AND
            S_09 ,//NOT
            S_06, //LDR_0
            S_25_1 ,//LDR_1
            S_25_2, //LDR_2
            S_27, //LDR_3
            S_07, //STR_0
            S_23 , //STR_1
            S_16_1, //STR_2
            S_16_2, //STR_3
            S_04, //JSR_0. would normally decide JSR or JSRR, but this lab only has JSR.
            S_21, //JSR_1. for JSR
            S_12, //JMP
            S_00, //BR_0
            S_22 //BR_1
                        }   State, Next_state;   // Internal state logic

    always_ff @ (posedge Clk)
    begin
        if (Reset)
            State <= Halted;
        else
            State <= Next_state;
    end

    always_comb
    begin
        // Default next state is staying at current state
        Next_state = State;

//numbering of these states based on official LC3 states, 
//with extra added due to lack of R signal from memory
        unique case (State)
            Halted :
                if (Run)
                    Next_state = S_18;
            
            
            S_18 :  //Fetch0
                Next_state = S_33_1;
            // Any states involving SRAM require more than one clock cycles.
            // The exact number will be discussed in lecture. (it's 2)
            S_33_1 :  //Fetch1
                Next_state = S_33_2;
                
            S_33_2 : //Fetch2
                Next_state = S_35;
                
            S_35 : //Fetch3
                Next_state = S_32;
            
        // Next_state = PauseIR1;
            // PauseIR1 and PauseIR2 are only for Week 1 such that TAs can see
            // the values in IR.
            //repurposing for the PAUSE instruction.
            PauseIR1 :
                if (~Continue)
                    Next_state = PauseIR1;
                else
                    Next_state = PauseIR2;
            PauseIR2 :
                if (Continue)
                    Next_state = PauseIR2;
                else
                    Next_state = S_18; //fetch again

            S_32 : // Decode
                case (Opcode)
                    4'b0001 : //ADD or ADDi
                        Next_state = S_01;
                    4'b0101 : //AND
                        Next_state = S_05;
                    4'b1001 : //NOT
                        Next_state = S_09;
                    4'b0000 : //BR
                        Next_state = S_00;
                    4'b1100 : //JMP
                        Next_state = S_12;
                    4'b0100 : //JSR and JSRR
                        Next_state = S_04;
                    4'b0110 : //LDR
                        Next_state = S_06;
                    4'b0111 : //STR
                        Next_state = S_07;
                    4'b1101 : //PAUSE  
                        Next_state = PauseIR1; //THIS NEEDS TO BE COMPLETED.

                    // You need to finish the rest of opcodes.....

                    default :
                        Next_state = S_18;
                endcase

            S_01 : //ADD
                Next_state = S_18;

            // You need to finish the rest of states.....
            S_05 : //AND
                Next_state = S_18;
        
            S_09 : //NOT
                Next_state = S_18;

            S_06 : //LDR_0
                Next_state = S_25_1;
            S_25_1 : //LDR_1
                Next_state = S_25_2;
            S_25_2 : //LDR_2
                Next_state = S_27;
            S_27 : //LDR_3
                Next_state = S_18;

            S_07 : //STR_0
                Next_state = S_23;
            S_23 :  //STR_1
                Next_state = S_16_1;
            S_16_1 : //STR_2
                Next_state = S_16_2;
            S_16_2 : //STR_3
                Next_state = S_18;

            S_04 : //JSR_0. would normally decide JSR or JSRR, but this lab only has JSR.
                Next_state = S_21;
                //state 20 for JSRR, but NA for this lab.
            S_21 : //JSR_1. for JSR
                Next_state = S_18;

            S_12 : //JMP
                Next_state = S_18;

            S_00 : //BR_0
              if(BEN)
                Next_state = S_22;
              else
                Next_state = S_18;
            S_22 : //BR_1
                Next_state = S_18;
            default : ;

        endcase

        // default controls signal values; within a process, these can be
        // overridden further down (in the case statement, in this case)
        LD_MAR = 1'b0;
        LD_MDR = 1'b0;
        LD_IR = 1'b0;
        LD_BEN = 1'b0;
        LD_CC = 1'b0;
        LD_REG = 1'b0;
        LD_PC = 1'b0;
        LD_LED = 1'b0;

        GatePC = 1'b0;
        GateMDR = 1'b0;
        GateALU = 1'b0;
        GateMARMUX = 1'b0;

        ALUK = 2'b00;

        PCMUX = 2'b00;
        DRMUX = 1'b0;
        SR1MUX = 1'b0;
        SR2MUX = 1'b0;
        ADDR1MUX = 1'b0;
        ADDR2MUX = 2'b00;

        Mem_OE = 1'b1;
        Mem_WE = 1'b1;

        // Assign control signals based on current state
        case (State)
            Halted: ;

            
            S_18 : //Fetch. MAR<-PC and PC++
                begin 
                    GatePC = 1'b1; // put PC on data bus
                    LD_MAR = 1'b1; // load MAR from data bus
                    PCMUX = 2'b00; // select PC+1
                    LD_PC = 1'b1; // load PC
                end
            S_33_1 : //connect memory to MDR
                Mem_OE = 1'b0;
            S_33_2 : // MDR <-M(MAR) 
                begin
                    Mem_OE = 1'b0;
                    LD_MDR = 1'b1;
                end
            S_35 : //IR<-MDR
                begin
                    GateMDR = 1'b1;
                    LD_IR = 1'b1;
                end
            PauseIR1: LD_LED = 1'b1;
            PauseIR2: LD_LED = 1'b1;

            S_32 : //Decode
                LD_BEN = 1'b1;   //update BEN
            S_01 : //ADD
                begin
                    SR1MUX = 1'b1;  //1 - IR[8:6]
                    SR2MUX = IR_5; // 1 - immediate5
                    DRMUX = 1'b1;  // 1 - IR[11:9]
                    LD_REG = 1'b1;  // DR <- CPU Bus (ALU)

                    ALUK = 2'b00;  // 00 - add
                    GateALU = 1'b1; // CPU Bus <- ALU
                    LD_CC = 1'b1;   // nzp <- logic (CPU Bus(ALU) )
                end

            S_05 : //AND
              begin
                    SR1MUX = 1'b1;  // 1 -IR[8:6]
                    SR2MUX = IR_5; // 1 -5 immediate
                    DRMUX = 1'b1;  // 1 - IR[11:9]
                    LD_REG = 1'b1;  // DR <- CPU Bus (ALU)

                    ALUK = 2'b01; // 01 - AND
                    GateALU = 1'b1; // CPU Bus <- ALU
                    LD_CC = 1'b1;   // nzp <- logic (CPU Bus(ALU) )
              end

            S_09 : //NOT
            begin
                    SR1MUX = 1'b1;  // IR[8:6]
                    DRMUX = 1'b1;  // 1 - IR[11:9]
                    LD_REG = 1'b1;  // DR <- CPU Bus (ALU)

                    ALUK = 2'b10; // 10 - NOT
                    GateALU = 1'b1; // CPU Bus <- ALU
                    LD_CC = 1'b1;   // nzp <- logic (CPU Bus(ALU) )
            end

            S_06 : //LDR_0
            begin
                    SR1MUX = 1'b1;  // 1 - BaseR = IR[8:6]

                    ADDR1MUX = 1'b1; //1 - ADDR1 = SR1
                    ADDR2MUX = 2'b01; //1 - offset 6

                    GateMARMUX = 1'b1; //CPU Bus <- SR1 + offset6
                    LD_MAR = 1'b1;  // MAR <- BaseR + SEXT(offset6);
            end
            S_25_1 : //LDR_1
                Mem_OE = 1'b0; //connect memory to MDR
            S_25_2 ://LDR_2
                begin
                    Mem_OE = 1'b0;
                    LD_MDR = 1'b1;
                end
            S_27 ://LDR_3
                begin
                    DRMUX = 1'b1;  // 1 - IR[11:9]
                    LD_REG = 1'b1; //DR <- CPU Bus(MDR)
                
                    GateMDR = 1'b1; //CPU Bus <- MDR
                end

            S_07 : //STR_0. Set MAR.
                begin
                    SR1MUX = 1'b1;  // 1- BaseR = IR[8:6]
                    ADDR1MUX = 1'b1; //1 - ADDR1 = SR1
                    ADDR2MUX = 2'b01; //1 - offset 6
                    GateMARMUX = 1'b1; //CPU Bus <- SR1 + offset6
                    LD_MAR = 1'b1;  // MAR <- BaseR + SEXT(offset6);
                end
            S_23 :  //STR_1. Set MDR.
                begin
                    SR1MUX = 1'b0;  // 0 - SR = IR[11:9]
                    ADDR1MUX = 1'b01; //1 - ADDR1 = SR1
                    ADDR2MUX = 2'b00; //0 - ADDR2 = 0
                    GateMARMUX = 1'b1; //CPU Bus <- SR1 + 0
                    Mem_OE = 1'b1; // MDR <- CPU Bus (probably)
                    LD_MDR = 1'b1;
                end
            S_16_1 : //STR_2. Write MDR to memory
                Mem_WE= 1'b0;
            S_16_2 : //STR_3. Wait for memory to finish writing.
                Mem_WE= 1'b0;

            S_04 : //JSR_0. Save PC in R7. Choose JSR or JSRR. For this lab, just JSR.
                begin
                GatePC = 1'b1;
                DRMUX   = 1'b0; //0 DR = R7  
                LD_REG = 1'b1;  //DR <- PC (incremeneted by fetch)
                end
         // S_20: JSRR version for state 20. But not needed for this lab.
                // SR1MUX = 1'b1;  // BaseR = IR[8:6]
                // ADDR1MUX = 1'b1; //0 ADDR1 = SR1
                // ADDR2MUX = 1'b00; //3 ADDR2 = 0
                // LD_PC = 1'b1; // PC <- BaseR + 0
            S_21 : //JSR_1. JSR. 
                begin
                ADDR1MUX = 1'b0; //0 ADDR1 = PC
                ADDR2MUX = 2'b11; //3 ADDR2 = offset 11
                LD_PC = 1'b1; // PC <- PC+offset 11
                PCMUX = 2'b10; //2 - ADDR_sum
                end

            S_12 : //JMP
                begin
                SR1MUX = 1'b1;  // 1 - BaseR = IR[8:6]
                ADDR1MUX = 1'b1; // 1 ADDR1 = SR1 (BaseR)
                ADDR2MUX = 2'b00; //0 ADDR2 =  0
                LD_PC = 1'b1; // PC <- BaseR +0
                PCMUX = 2'b10; //2 - ADDR_sum
                end
            S_00 : //BR_0
                ;  //checks BEN, handled in the transition rules up above.
            S_22 : //BR_1. Since BEN==1, branch.
                begin
                ADDR1MUX = 1'b0; //0 ADDR1 = PC
                ADDR2MUX = 2'b10; //2 ADDR2 = offset 9
                LD_PC = 1'b1; // PC <- PC+offset 9
                PCMUX = 2'b10; //2 - ADDR_sum
                end
            default : ;
        endcase
    end

     // These should always be active
    assign Mem_CE = 1'b0;
    assign Mem_UB = 1'b0;
    assign Mem_LB = 1'b0;

endmodule
