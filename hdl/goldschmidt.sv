module goldschmidt_div #(parameter WIDTH=29) (
    input  logic             clk, reset, mode, stage,
    input  logic [WIDTH-1:0] numerator, denominator,
    output logic [WIDTH-1:0] quotient
);

    logic [2*WIDTH-1:0] s, c;
    logic [WIDTH-1:0] n, d, k, a, b, j;

    // Generate initial approximation
    logic [WIDTH-1:0] k0 = {3'b011, {WIDTH-3{1'b0}}}; // 0.75

    // mux inputs to get operands
    mux2 #(WIDTH) kmux (mode, k0, k, b);
    mux4 #(WIDTH) stagemux ({mode, stage}, numerator, denominator, n, d, a);

    // multiply operands
    mult_cs #(WIDTH) mult(a, b, 0, s, c);
    assign j = (s+c) >> WIDTH-2; // Truncate lower bits, keeping guard bits

    // Output should match n
    assign quotient = n;

    // register outputs to use in next iteraton
    flopenr #(WIDTH) nreg (clk, ~stage, reset, j, n);
    flopenr #(WIDTH) dreg (clk, stage, reset, j, d);
    flopenr #(WIDTH) kreg (clk, stage, reset, (~j)>>1, k);

endmodule

module goldschmidt_ctrl (
    input  logic clk, reset,
    output logic mode, stage
);

    logic [3:0] count;

    // state logic implemented using a counter
    always @(posedge clk, posedge reset)
        if (reset) // next cycle will be 0
            count = 13;
        else if (count >= 13) // reset after the 15th cycle
            count = 0;
        else
            count++;

    // output logic
    always_comb begin
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
        if (count < 13) begin
            clk_out = 1; // Pulse clk_out once every 12 cycles
            count++;
        end
        else begin
            clk_out = 0;
            count = 0;
        end

endmodule