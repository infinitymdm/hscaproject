module mantissa_divider #(parameter WIDTH=24) (
    input  logic [WIDTH-1:0] m1, m2,
    output logic [WIDTH-1:0] m3,
    output logic decrement_exponent
);

    logic [WIDTH:0] dividend, divisor;
    logic [WIDTH+4:0] quotient;

    // Perform division
    assign dividend = {1'b1, m1};
    assign divisor = {1'b1, m2};
    assign quotient = dividend / divisor;

    // Assign outputs
    assign decrement_exponent = ~quotient[WIDTH];
    assign m3 = quotient[WIDTH] ? quotient[WIDTH-1:0] : {quotient[WIDTH-2:0], 1'b0};

endmodule