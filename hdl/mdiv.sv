module mdiv #(parameter WIDTH=23) (
    input  logic             clk, reset,
    input  logic [WIDTH-1:0] m1, m2,
    output logic [WIDTH-1:0] m3, r,
    output logic decrement_exponent
);
    localparam LEADS = 3;
    localparam GUARDS = 4;

    logic [LEADS+WIDTH+GUARDS-1:0] dividend, divisor, quotient, remainder;

    // Add leading 1 and guard bits to operand mantissae
    assign dividend = {{LEADS-1{1'b0}}, 1'b1, m1, {GUARDS{1'b0}}};
    assign divisor = {{LEADS-1{1'b0}}, 1'b1, m2, {GUARDS{1'b0}}};

    // Perform Goldschmidt iterative division
    logic mode, stage, rem;
    goldschmidt_ctrl gctrl(.clk, .reset, .mode, .stage, .rem);
    goldschmidt_div #(LEADS+WIDTH+GUARDS) gdiv(.clk, .reset, .mode, .stage, .rem, .numerator(dividend), .denominator(divisor), .quotient, .remainder);

    // Assign outputs
    assign decrement_exponent = ~quotient[LEADS+WIDTH+GUARDS-1];
    assign m3 = ~quotient[LEADS+WIDTH+GUARDS-1] ? quotient[WIDTH+GUARDS-1:GUARDS] : quotient[WIDTH+GUARDS:GUARDS+1]; // TODO: round instead of truncating
    assign r = remainder[WIDTH+GUARDS-1:GUARDS];

endmodule