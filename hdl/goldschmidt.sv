module goldschmidt_div #(parameter WIDTH=30) (
    input  logic             clk, reset, mode, stage, rem,
    input  logic [WIDTH-1:0] numerator, denominator,
    output logic [WIDTH-1:0] quotient, remainder
);

    logic [2*WIDTH-1:0] product, sum, carry;
    logic [WIDTH-1:0] n, d, k, a, b, r;

    // Generate initial approximation
    logic [WIDTH-1:0] k0 = {3'b011, {WIDTH-3{1'b0}}}; // 0.75

    // mux inputs to get operands
    mux4 #(WIDTH) modemux ({rem, mode}, k0, k, quotient, {WIDTH{1'bz}}, b);
    mux4 #(WIDTH) stagemux ({mode, stage}, numerator, denominator, n, d, a);

    // multiply operands
    mult_cs #(WIDTH) mult(a, b, {WIDTH{1'bz}}, sum, carry);
    assign product = (sum + carry);
    assign remainder = numerator - r; // Remainder calculation

    // Output should match n
    assign quotient = n;

    // register outputs to use in next iteraton
    flopenr #(WIDTH) regn (clk, ~stage, reset, product[2*WIDTH-3:WIDTH-2], n);
    flopenr #(WIDTH) regd (clk, stage, reset, product[2*WIDTH-3:WIDTH-2], d);
    flopenr #(WIDTH) regk (clk, stage, reset, {1'b0,~product[2*WIDTH-4:WIDTH-2]}, k);
    flopenr #(WIDTH) regr (clk, rem, reset, {product[2*WIDTH-3:2*WIDTH-5], {WIDTH-3{1'b0}}}, r);

endmodule

module goldschmidt_ctrl (
    input  logic clk, reset,
    output logic mode, stage, rem
);

    logic [3:0] count;

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
