module mantissa_op #(parameter WIDTH=23) (
    input  logic             clk, reset,
    input  logic             round_mode,
    input  logic       [1:0] op,
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
    logic [1:0] sA, sB;
    logic enableN, enableD, enableK, enableQD;
    div_ctrl dctrl(.clk, .reset, .sA, .sB, .enableN, .enableD, .enableK, .enableQD);
    logic r_sign;
    goldschmidt #(LEADS+WIDTH+GUARDS) gdiv(
        .clk, .reset,
        .sA, .sB,
        .enableN, .enableD, .enableK, .enableQD,
        .numerator(dividend), .denominator(divisor), .quotient,
        .rem_sign(r_sign));

    // Round quotient
    logic [LEADS+WIDTH+GUARDS-1:0] q_rne, q_rz, q;
    round_ne #(LEADS+WIDTH+GUARDS, GUARDS) rne(quotient, ~r_sign, q_rne);
    round_z  #(LEADS+WIDTH+GUARDS, GUARDS) rz (quotient, r_sign, q_rz);
    mux2 #(LEADS+WIDTH+GUARDS) round_mux(round_mode, q_rne, q_rz, q);

    // Assign outputs
    assign decrement_exponent = ~q[WIDTH+GUARDS+1];
    assign m3 = decrement_exponent ? q[WIDTH+GUARDS:GUARDS] : q[WIDTH+GUARDS+1:GUARDS+1];

endmodule