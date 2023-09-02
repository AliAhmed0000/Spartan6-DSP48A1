module DSP48A1(A,B,C,D,CARRYIN,M,P,CARRYOUT,CARRYOUTF,CLK,OPMODE,CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP,RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP,BCIN,BCOUT,PCIN,PCOUT);
//parameters//
    //1st stage of pipeline
    parameter A0REG = 0;
    parameter B0REG = 0;
    //2nd stage of pipeline
    parameter A1REG = 1;
    parameter B1REG = 1;
    //other paras
    parameter CREG = 1;
    parameter DREG = 1;
    parameter MREG = 1;
    parameter PREG = 1;
    parameter CARRYINREG = 1;
    parameter CARRYOUTREG = 1;
    parameter OPMODEREG = 1;

    parameter CARRYINSEL = "OPMODE5";// This attribute can be set to the string "CARRYIN" or "OPMODE5".

    parameter B_INPUT = "DIRECT";// This attribute can be set to the string "DIRECT" or "CASCADE".

    parameter RSTTYPE = "SYNC";// This attribute can be set to the string "SYNC" or "ASYNC".
//inputs    
    //data ports
    input [17:0] A,B,D;
    input [47:0] C;
    input CARRYIN;
    //control input ports
    input CLK;
    input [7:0] OPMODE;
    //clock enable ports
    input CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP;
    //reset enable ports
    input RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP;
    //cascade ports
    input [17:0] BCIN;
    input [47:0] PCIN;
//outputs
    //data ports
    output [35:0] M;
    output [47:0] P;
    output CARRYOUT,CARRYOUTF;
    //cascade ports
    output [17:0] BCOUT;
    output [47:0] PCOUT;
///////////////////////////
    
    //stage 0
    //D
    wire [17:0] D_pair_out;
    dff_mux_pair #(.WIDTH(18),.RST_MODE(RSTTYPE),.SELECT(DREG)) D_REG(D,CLK,RSTD,CED,D_pair_out);

    //B
    wire [17:0] B_mux0_out;
    wire [17:0] B_pair0_out;

    mux_2x1_B_input #(.WIDTH(18),.SELECT(B_INPUT)) B0_MUX(.B_in(B),.B_cin(BCIN),.C(B_mux0_out)); //unique mux for B input as its parameter(selector also) equals "DIRECT" or "CASCADE" not 0 or 1
    dff_mux_pair #(.WIDTH(18),.RST_MODE(RSTTYPE),.SELECT(B0REG)) B0_REG(B_mux0_out,CLK,RSTB,CEB,B_pair0_out);

    //A
    wire [17:0] A_pair0_out;
    dff_mux_pair #(.WIDTH(18),.RST_MODE(RSTTYPE),.SELECT(A0REG)) A0_REG(A,CLK,RSTA,CEA,A_pair0_out);

    //C
    wire [47:0] C_pair0_out;
    dff_mux_pair #(.WIDTH(48),.RST_MODE(RSTTYPE),.SELECT(CREG)) C_REG(C,CLK,RSTC,CEC,C_pair0_out);

    //opmode
    wire [7:0] OPMODE_pair0_out;
    dff_mux_pair #(.WIDTH(8),.RST_MODE(RSTTYPE),.SELECT(OPMODEREG)) OPMODE_REG(OPMODE,CLK,RSTOPMODE,CEOPMODE,OPMODE_pair0_out);
    //================//
    //stage 1
    //pre-adder/subtractor
    wire [17:0] pre_add_sub_out;
    assign pre_add_sub_out = (OPMODE_pair0_out[6] == 1)? (D_pair_out - B_pair0_out) : (D_pair_out + B_pair0_out);

    //White MUX
    wire [17:0] mux1_out; //white mux (unshaded)
    mux_2_to_1 #(.WIDTH(18)) B1_MUX(.A(pre_add_sub_out),.B(B_pair0_out),.SELECT(OPMODE_pair0_out[4]),.C(mux1_out)); //this mux works like: 0 --> B, 1 --> A

    //pipeline 1
    wire[17:0] A1_REG_out,B1_REG_out;
    dff_mux_pair #(.WIDTH(18),.RST_MODE(RSTTYPE),.SELECT(B1REG)) B1_REG(mux1_out,CLK,RSTB,CEB,B1_REG_out);

    dff_mux_pair #(.WIDTH(18),.RST_MODE(RSTTYPE),.SELECT(A1REG)) A1_REG(A_pair0_out,CLK,RSTA,CEA,A1_REG_out);

    assign BCOUT = B1_REG_out; //first output, suuiiiiiii
    //concatenated signal
    wire[47:0] D_A_B_concatenate;
    assign D_A_B_concatenate ={D_pair_out[11:0],A1_REG_out[17:0],B1_REG_out[17:0]};
    //stage 2

    //multiplier
    wire[35:0] multip_out,M_REG_out;//update 16/8/2023 from [47:0] to [35:0]
    assign multip_out = B1_REG_out * A1_REG_out;
    dff_mux_pair #(.WIDTH(36),.RST_MODE(RSTTYPE),.SELECT(MREG)) M_REG(multip_out,CLK,RSTM,CEM,M_REG_out);

    assign M = M_REG_out; //second output, suuiiiiiii

    //carry in part
    wire CARRYIN_signal;
    mux_2x1_cin_opmode #(.SELECT(CARRYINSEL)) MUX_CIN(.OPMODE_5(OPMODE_pair0_out[5]),.CIN(CARRYIN),.C(CARRYIN_signal));

    wire CYI_REG_out;
    dff_mux_pair #(.WIDTH(1),.RST_MODE(RSTTYPE),.SELECT(CARRYINREG)) CYI_REG(CARRYIN_signal,CLK,RSTCARRYIN,CECARRYIN,CYI_REG_out);
    //stage 3
    wire[47:0] P_signal;
    //MUX_X
    wire[47:0] MUX_X_out;
    assign MUX_X_out =  (OPMODE_pair0_out[1:0] == 2'b00)? 'b0: 
                        (OPMODE_pair0_out[1:0] == 2'b01)? {12'b0,M_REG_out}:  //update from M_REG_out to {12'b0,M_REG_out}
                        (OPMODE_pair0_out[1:0] == 2'b10)? P_signal: D_A_B_concatenate;

    //MUX_Z
    wire[47:0] MUX_Z_out;
    assign MUX_Z_out =  (OPMODE_pair0_out[3:2] == 2'b00)? 'b0: 
                        (OPMODE_pair0_out[3:2] == 2'b01)? PCIN:
                        (OPMODE_pair0_out[3:2] == 2'b10)? P_signal: C_pair0_out;

    //Post-adder/subtractor
    wire[47:0] post_add_sub_out;
    wire post_add_sub_carry_out;
    assign {post_add_sub_carry_out , post_add_sub_out} = (OPMODE_pair0_out[7] == 1'b0)? (MUX_X_out + MUX_Z_out + CYI_REG_out):(MUX_Z_out -(MUX_X_out + CYI_REG_out));

    //stage 4
    //P
    dff_mux_pair #(.WIDTH(48),.RST_MODE(RSTTYPE),.SELECT(PREG)) P_REG(post_add_sub_out,CLK,RSTP,CEP,P_signal);
    assign P = P_signal; //output spotted
    assign PCOUT = P_signal; //output spotted
    //COUT
    wire CYO_REG_out;
    dff_mux_pair #(.WIDTH(1),.RST_MODE(RSTTYPE),.SELECT(CARRYOUTREG)) CYO_REG(post_add_sub_carry_out,CLK,RSTCARRYIN,CECARRYIN,CYO_REG_out);
    assign CARRYOUT = CYO_REG_out;
    assign CARRYOUTF = CYO_REG_out;

endmodule