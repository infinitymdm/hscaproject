module goldschmidt_div #(parameter WIDTH=30) (
    input  logic             clk, reset, mode, stage, rem,
    input  logic [WIDTH-1:0] numerator, denominator,
    output logic [WIDTH-1:0] quotient, remainder
);

    logic [2*WIDTH-1:0] sum, carry;
    logic [WIDTH-1:0] n, d, k, a, b, product, r;

    // Generate initial approximation
    logic [WIDTH-1:0] k0 = {3'b011, {WIDTH-3{1'b0}}}; // 0.75

    // mux inputs to get operands
    mux4 #(WIDTH) kmux ({rem, mode}, k0, k, 0, numerator, b);
    mux4 #(WIDTH) stagemux ({mode, stage}, numerator, denominator, n, d, a);

    // multiply operands
    mult_cs #(WIDTH) mult(a, b, 0, sum, carry);
    assign product = (sum + carry) >> WIDTH-2; // Truncate lower bits, keeping guard bits
    assign r = numerator - product; // Remainder calculation

    // Output should match n
    assign quotient = n;

    // register outputs to use in next iteraton
    flopenr #(WIDTH) regn (clk, ~stage, reset, product, n);
    flopenr #(WIDTH) regd (clk, stage, reset, product, d);
    flopenr #(WIDTH) regk (clk, stage, reset, {1'b0,~product[WIDTH-2:0]}, k);
    flopenr #(WIDTH) regr (clk, rem, reset, r, remainder);

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
        mode = (count >= 2);
        stage = count[0];
    end

endmodule

module clk_div (
    input  logic clk,
    output logic clk_out
);

    int count = 0;

    always @(posedge clk)
        if (count < 11) begin
            clk_out = 1; // Pulse clk_out once every 12 cycles
            count++;
        end
        else begin
            clk_out = 0;
            count = 0;
        end

endmodule