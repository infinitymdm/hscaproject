module mantissa_op #(parameter WIDTH=23) (
    input  logic             clk, reset,
    input  logic             round_mode,
    input  logic       [1:0] op,
    input  logic             shift,
    input  logic [WIDTH-1:0] m1, m2,
    output logic [WIDTH-1:0] m3,
    output logic decrement_exponent
);
    localparam LEADS = 2;
    localparam GUARDS = 4;

    logic [LEADS+WIDTH+GUARDS-1:0] n, d, result;

    // Add leading 1 and guard bits to operand mantissae
    assign n = {{LEADS-1{1'b0}}, 1'b1, m1, {GUARDS{1'b0}}} << shift;
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
    goldschmidt #(LEADS, WIDTH+GUARDS) goldschmidt (
        .clk, .reset,
        .op,
        .sA, .sB,
        .enableN, .enableD, .enableK, .enableQD,
        .n0(n), .d0(d), .result,
        .r_sign);

    // Accomodate for out-of-range outputs and chop off leads
    logic [WIDTH+GUARDS-1:0] q;
    assign decrement_exponent = ~result[WIDTH+GUARDS]; // WIDTH+GUARDS targets the 1st digit above the radix point
    assign q = result[WIDTH+GUARDS-1:0] << decrement_exponent;

    // Round result
    logic [WIDTH+GUARDS-1:0] q_rne, q_rz;
    round_ne #(WIDTH+GUARDS, GUARDS) rne(q, ~r_sign, q_rne);
    round_z  #(WIDTH+GUARDS, GUARDS) rz (q, r_sign, q_rz);
    mux2 #(WIDTH) round_mux(round_mode, q_rne[WIDTH+GUARDS-1:GUARDS], q_rz[WIDTH+GUARDS-1:GUARDS], m3);    

endmodule