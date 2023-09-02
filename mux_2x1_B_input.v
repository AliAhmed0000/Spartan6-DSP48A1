module mux_2x1_B_input #(
    parameter WIDTH = 4,
    parameter SELECT = "DIRECT"  //DIRECT OR CASCADE
) (
    input [WIDTH - 1: 0] B_in,B_cin,
    
    output [WIDTH - 1: 0]C
);
    // assign C = (SELECT == 1)? reg_out: no_reg_out;
    assign C = (SELECT == "DIRECT") ? B_in : ((SELECT == "CASCADE") ? B_cin : 0);
endmodule