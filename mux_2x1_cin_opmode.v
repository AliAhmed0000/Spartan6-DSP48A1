module mux_2x1_cin_opmode #(
    //parameter WIDTH = 4,
    parameter SELECT = "OPMODE5"  //OPMODE5 OR CARRYIN
) (
    input OPMODE_5,
    input CIN,
    
    
    output C
);
    // assign C = (SELECT == 1)? reg_out: no_reg_out;
    assign C = (SELECT == "OPMODE5") ? OPMODE_5 : ((SELECT == "CARRYIN") ? CIN : 0);
endmodule