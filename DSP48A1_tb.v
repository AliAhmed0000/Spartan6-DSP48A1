`timescale 1ns/1ps
module DSP48A1_tb ();
    // I/Os signals
    //data ports
    
    reg [17:0] A,B,D;
    reg [47:0] C;
    reg CARRYIN;
    //control input ports
    reg CLK;
    reg [7:0] OPMODE;
    //clock enable ports
    reg CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP;
    //reset enable ports
    reg RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP;
    //cascade ports
    reg [17:0] BCIN;
    reg [47:0] PCIN;
//outputs
    //data ports
    wire [35:0] M;
    wire [47:0] P;
    wire CARRYOUT,CARRYOUTF;
    //cascade ports
    wire [17:0] BCOUT;
    wire [47:0] PCOUT;

    DSP48A1 #(.A0REG(1),.B0REG(1),.A1REG(1),.B1REG(1),
                .CREG(1),.DREG(1),.MREG(1),.PREG(1),
                .CARRYINREG(1),.CARRYOUTREG(1),.OPMODEREG(1),
                .CARRYINSEL("CARRYIN"),.B_INPUT("CASCADE"),.RSTTYPE("ASYNC"))

                     D1(A,B,C,D,CARRYIN,M,P,CARRYOUT,CARRYOUTF,CLK,OPMODE,
                    CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP,
                    RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP,
                    BCIN,BCOUT,PCIN,PCOUT);
//==================//

    initial begin
        CLK = 0;

        forever
        #1 CLK = ~CLK;
    end
    //BCOUT is out after 2 posedges(cycles)
    //M     is out after 3 posedges(cycles)

    //P    and POUT     is out after 4 posedges(cycles)
    //Cout and CoutF    is out after 4 posedges(cycles)
    initial begin
        RSTA = 1;
        RSTB = 1;
        RSTC = 1;
        RSTD = 1;
        RSTCARRYIN = 1;
        RSTM = 1;
        RSTOPMODE = 1;
        RSTP = 1;

        CEB = 1;
        CEA = 1;
        CEC = 1;
        CECARRYIN = 1;
        CED = 1;
        CEM = 1;
        CEOPMODE = 1;
        CEP = 1;

        #2

        RSTA = 0;
        RSTB = 0;
        RSTC = 0;
        RSTD = 0;
        RSTCARRYIN = 0;
        RSTM = 0;
        RSTOPMODE = 0;
        RSTP = 0;

        #2;
        //Testcase 0: (A x Bcin) + Pcin + CIN
        //opmode
        //7   6   5   4   3   2   1   0 
        //0   x   x   0   0   1   0   1
        A = 'd3020;
        BCIN = 'd3;
        PCIN = 'd5123;
        CARRYIN = 1;
        OPMODE = 'b0110_0101;
        #8;
        @(negedge CLK);
        @(negedge CLK);
        //now (P = 'd14184)
        //Testcase 1: C - (concatenated + CIN)
        //opmode
        //7   6   5   4   3   2   1   0 
        //1   x   x   0   1   1   1   1
        C = 'd20040050; // 'h131C972
        {D[11:0],A[17:0],BCIN[17:0]} = 'd2554; //'h9fa
        
        
        #4;
        OPMODE = 'b1000_1111;
        CARRYIN = 0;
        #2;
        @(negedge CLK);
        @(negedge CLK);
        

        //now P = 'h1 0000 0131 BF77
        //Testcase 2: (D - BCIN) x A +CIN
        //opmode
        //7   6   5   4   3   2   1   0 
        //0   1   x   1   0   0   0   1

        D = 'h3ffff;
        //concatenated_sig = 'hfff000_0009fa after 1 cycle
        //after 1 more cycle P = C - Concatenated --> as the recent testcase as opcode not changed yet
        //P = 'h 131C972 - 'hfff000_0009fa = FFFF 0010 0131 BF78 //carryout is set suiiii

        BCIN = 'heffd;
        A = 'd5;
        //concatenated_sig = 'hfff000_14effd after 2 cycle (as A and B passes through 2 stages of pipeline)
        //P = 'h 131C972 - 'h fff000_14effd = 'h FFFF 0010 011C D975 //carryout still set
        #4;
        OPMODE = 'b0101_0001;
        CARRYIN = 0;
        #6;
        @(negedge CLK);
        @(negedge CLK);
        //now P = 'h f500a

        //it's observed that 4aff1 appeared before the last result
        //that's because P = BCIN * A ='h effd *'h 5, as the opmode 
        $stop;
    end

    
endmodule