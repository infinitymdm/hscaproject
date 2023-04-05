module goldschmidt #(parameter WIDTH=28) (
    input  logic             clk, k_select, stage_select,
    input  logic [WIDTH-1:0] numerator, denominator,
    output logic [WIDTH-1:0] quotient,
);

    logic [WIDTH-1:0] n, d, k, a, b;

    // Generate initial approximation
    logic [WIDTH-1:0] k0 = {3'b011, {WIDTH-3{1'b0}}}; // 0.75

    // mux inputs
    mux2 #(WIDTH) kmux (k_select, k0, k, b);
    mux4 #(WIDTH) stagemux ({k_select, stage_select}, numerator, denominator, n, d, a);

    // multiply operands
    assign quotient = (a * b) >> WIDTH; // Shift since a*b is 2*WIDTH in length, and we only want the upper bits

    // register outputs to use in next iteraton
    flopenr #(WIDTH) nreg (clk, ~stage_select, 0, quotient, n);
    flopenr #(WIDTH) dreg (clk, stage_select, 0, quotient, d);
    flopenr #(WIDTH) kreg (clk, stage_select, 0, quotient, k);

endmodule