module mux_2_to_1 #(
    parameter WIDTH = 4
) (
    //0 = no reg --> A, 1 = reg --> B
    input [WIDTH - 1: 0] A,B,
    input SELECT,
    
    output [WIDTH - 1: 0]C
);
    assign C = (SELECT == 1)? A: B;
endmodule