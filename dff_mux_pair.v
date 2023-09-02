module dff_mux_pair #(
    parameter WIDTH = 4,
    parameter RST_MODE = "SYNC",
    parameter SELECT = 0// 0 for no register, 1 is for register
) (
    input [WIDTH - 1: 0] A,
    input CLK,RST,CEN,
    output [WIDTH - 1: 0]C
);
    wire [WIDTH - 1: 0] A_dff_out;
    
    DFF_para #(WIDTH,RST_MODE) DFF1(A,RST,CLK,CEN,A_dff_out);
    mux_2x1_para_select #(WIDTH,SELECT) MUX1(.reg_out(A_dff_out),.no_reg_out(A),.C(C));
endmodule