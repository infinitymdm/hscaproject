module round_ne #(parameter WIDTH_IN, WIDTH_OUT) (
    input  logic [WIDTH_IN-1:0]  x,
    input  logic                 rem_is_positive,
    output logic [WIDTH_OUT-1:0] y
);
    localparam ULP = WIDTH_IN - WIDTH_OUT;

    always_comb
        if (x[ULP-1] && rem_is_positive) // If the remainder is positive AND 1st guard bit is 1
            y = x[WIDTH_IN:ULP] + 2**ULP; // Add an ULP
        else
            y = x[WIDTH_IN:ULP]; // truncate without adding

endmodule

module round_z #(parameter WIDTH_IN, WIDTH_OUT) (
    input  logic [WIDTH_IN-1:0]  x,
    input  logic                 rem_is_negative,
    output logic [WIDTH_OUT-1:0] y
);
    localparam ULP = WIDTH_IN - WIDTH_OUT;

    always_comb
        

endmodule