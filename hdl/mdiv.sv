module mdiv #(parameter WIDTH=23) (
    input  logic             clk, reset,
    input  logic [WIDTH-1:0] m1, m2,
    output logic [WIDTH-1:0] m3,
    output logic decrement_exponent
);

    logic [WIDTH+5:0] dividend, divisor, quotient; // 1 leading 1, 4 guard bits

    // Add leading 1 and 4 guard bits to operand mantissae
    assign dividend = {1'b1, m1, 4'b0};
    assign divisor = {1'b1, m2, 4'b0};

    // Perform Goldschmidt iterative division
    logic mode, stage;
    goldschmidt_ctrl gctrl(.clk, .reset, .mode, .stage);
    goldschmidt_div gdiv(.clk, .reset, .mode, .stage, .numerator(dividend), .denominator(divisor), .quotient);

    // Assign outputs
    assign decrement_exponent = ~quotient[WIDTH+5];
    assign m3 = ~quotient[WIDTH+5] ? quotient[WIDTH+4:4] : quotient[WIDTH+5:5]; // TODO: round instead of truncating

endmodule