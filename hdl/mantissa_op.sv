module mantissa_op #(parameter WIDTH=23) (
    input  logic             clk, reset,
    input  logic             round_mode,
    input  logic       [1:0] op,
    input  logic             shift,
    input  logic [WIDTH-1:0] m1, m2,
    output logic [WIDTH-1:0] m3,
    output logic decrement_exponent
);
    localparam LEADS = 3;
    localparam GUARDS = 4;

    logic [LEADS+WIDTH+GUARDS-1:0] n, d, quotient;

    // Add leading 1 and guard bits to operand mantissae
    assign n = {{LEADS-1{1'b0}}, 1'b1, m1, {GUARDS{1'b0}}};
    assign d = {{LEADS-1{1'b0}}, 1'b1, m2, {GUARDS{1'b0}}};

    // Perform Goldschmidt iterative division
    logic [1:0] dsA, dsB;
    logic dEnN, dEnD, dEnK, dEnQD;
    div_ctrl dctrl (clk, reset, dsA, dsB, dEnN, dEnD, dEnK, dEnQD);
    logic [1:0] ssA, ssB;
    logic sEnN, sEnD, sEnK, sEnQD;
    sqrt_ctrl sctrl (clk, reset, ssA, ssB, sEnN, sEnD, sEnK, sEnQD);
    logic [1:0] sA, sB;
    logic enableN, enableD, enableK, enableQD;
    mux2 #(8) muxCtrl (
        |op, 
        {dsA, dsB, dEnN, dEnD, dEnK, dEnQD},
        {ssA, ssB, sEnN, sEnD, sEnK, sEnQD}, 
        {sA, sB, enableN, enableD, enableK, enableQD});
    logic r_sign;
    goldschmidt #(LEADS+WIDTH+GUARDS) goldschmidt (
        .clk, .reset,
        .op,
        .sA, .sB,
        .enableN, .enableD, .enableK, .enableQD,
        .numerator(n), .denominator(d), .quotient,
        .rem_sign(r_sign));

    // Round quotient
    logic [LEADS+WIDTH+GUARDS-1:0] q_rne, q_rz, q;
    round_ne #(LEADS+WIDTH+GUARDS, GUARDS) rne(quotient, ~r_sign, q_rne);
    round_z  #(LEADS+WIDTH+GUARDS, GUARDS) rz (quotient, r_sign, q_rz);
    mux2 #(LEADS+WIDTH+GUARDS) round_mux(round_mode, q_rne, q_rz, q);

    // Assign outputs
    assign decrement_exponent = ~q[WIDTH+GUARDS+1];
    assign m3 = (decrement_exponent ? q[WIDTH+GUARDS:GUARDS] : q[WIDTH+GUARDS+1:GUARDS+1]) >> shift;

endmodule