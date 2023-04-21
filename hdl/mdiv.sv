module mdiv #(parameter WIDTH=23) (
    input  logic             clk, reset,
    input  logic             round_mode,
    input  logic [WIDTH-1:0] m1, m2,
    output logic [WIDTH-1:0] m3,
    output logic decrement_exponent
);
    localparam LEADS = 3;
    localparam GUARDS = 4;

    logic [WIDTH+GUARDS-1:0] unrounded_quotient;
    logic [LEADS+WIDTH+GUARDS-1:0] dividend, divisor, quotient;

    // Add leading 1 and guard bits to operand mantissae
    assign dividend = {{LEADS-1{1'b0}}, 1'b1, m1, {GUARDS{1'b0}}};
    assign divisor = {{LEADS-1{1'b0}}, 1'b1, m2, {GUARDS{1'b0}}};

    // Perform Goldschmidt iterative division
    logic mode, stage, rem;
    goldschmidt_ctrl gctrl(.clk, .reset, .mode, .stage, .rem);
    logic r_sign, r_zero;
    goldschmidt_div #(LEADS+WIDTH+GUARDS) gdiv(.clk, .reset, .mode, .stage, .rem, .numerator(dividend), .denominator(divisor), .quotient, .rem_sign(r_sign), .rem_zero(r_zero));

    // Assign outputs
    assign decrement_exponent = ~quotient[LEADS+WIDTH+GUARDS-1];
    assign unrounded_quotient = ~quotient[LEADS+WIDTH+GUARDS-1] ? quotient[WIDTH+GUARDS-1:0] : quotient[WIDTH+GUARDS:1];

    // Round quotient
    logic [WIDTH-1:0] m3_rne, m3_rz;
    round_ne #(WIDTH+GUARDS, WIDTH) rne(unrounded_quotient, ~r_sign | r_zero, m3_rne);
    round_z  #(WIDTH+GUARDS, WIDTH) rz (unrounded_quotient, r_sign, m3_rz);
    mux2 #(WIDTH) round_mux(round_mode, m3_rne, m3_rz, m3);

endmodule