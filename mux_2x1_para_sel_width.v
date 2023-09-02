module mux_2x1_para_select #(
    parameter WIDTH = 4,
    parameter SELECT = 0
) (
    //0 = no reg --> A, 1 = reg --> B
    input [WIDTH - 1: 0] no_reg_out,reg_out,
    
    output [WIDTH - 1: 0]C
);
    assign C = (SELECT == 1)? reg_out: no_reg_out;
endmodule