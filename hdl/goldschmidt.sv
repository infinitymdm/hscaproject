module goldschmidt #(parameter WIDTH=30) (
    input  logic             clk, reset,
    input  logic [1:0]       sA, sB,
    input  logic             enableN, enableD, enableK, enableQD,
    input  logic [WIDTH-1:0] numerator, denominator,
    output logic [WIDTH-1:0] quotient,
    output logic             rem_sign
);

    logic [2*WIDTH-1:0] product, sum, carry;
    logic [WIDTH-1:0] n, d, k, a, b, qd;
    logic [WIDTH-1:0] r1, r2;

    // Generate initial approximation
    logic [WIDTH-1:0] k0 = {3'b011, {WIDTH-3{1'b0}}}; // 0.75

    // mux inputs to get operands
    mux4 #(WIDTH) muxA (sA, k0, k, quotient, d, b);
    mux4 #(WIDTH) muxB (sB, numerator, denominator, n, d, a);

    // multiply operands
    mult_cs #(WIDTH) mult(a, b, 1'b0, sum, carry);
    assign product = (sum + carry);

    // Calculate remainder info
    assign rem_sign = qd > numerator;

    // Output should match n
    assign quotient = n;

    // register outputs to use in next iteraton
    flopenr #(WIDTH) regN  (clk, enableN,  reset, product[2*WIDTH-3:WIDTH-2],                      n);
    flopenr #(WIDTH) regD  (clk, enableD,  reset, product[2*WIDTH-3:WIDTH-2],                      d);
    flopenr #(WIDTH) regK  (clk, enableK,  reset, {1'b0,~product[2*WIDTH-4:WIDTH-2]},              k);
    flopenr #(WIDTH) regQD (clk, enableQD, reset, {product[2*WIDTH-3:2*WIDTH-5], {WIDTH-3{1'b0}}}, qd);

endmodule

module div_ctrl (
    input  logic       clk, reset,
    output logic [1:0] sA, sB,
    output logic       enableN, enableD, enableK, enableQD
);

    logic [3:0] count;
    logic mode, stage, rem;

    // Alias outputs for readability
    always_comb begin
        sA = {rem, mode};
        sB = {mode, stage};
        enableN = ~stage;
        enableD = stage;
        enableK = stage;
        enableQD = rem;
    end

    // state logic implemented using a counter
    always @(posedge clk, posedge reset)
        if (reset) // next cycle will be 0
            count = 11;
        else if (count >= 11) // reset after the 11th cycle
            count = 0;
        else
            count++;

    // output logic
    always_comb begin
        rem = (count == 11); // Calculate remainder on last cycle
        mode = (count >= 2) && (count < 11);
        stage = count[0];
    end

endmodule
