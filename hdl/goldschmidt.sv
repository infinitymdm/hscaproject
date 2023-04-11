module goldschmidt_div #(parameter WIDTH=30) (
    input  logic             clk, reset, mode, stage,
    input  logic [WIDTH-1:0] numerator, denominator,
    output logic [WIDTH-1:0] quotient
);

    logic [2*WIDTH-1:0] sum, carry;
    logic [WIDTH-1:0] n, d, k, a, b, product;

    // Generate initial approximation
    logic [WIDTH-1:0] k0 = {3'b011, {WIDTH-3{1'b0}}}; // 0.75

    // mux inputs to get operands
    mux2 #(WIDTH) kmux (mode, k0, k, b);
    mux4 #(WIDTH) stagemux ({mode, stage}, numerator, denominator, n, d, a);

    // multiply operands
    mult_cs #(WIDTH) mult(a, b, 0, sum, carry);
    assign product = (sum + carry) >> WIDTH-2; // Truncate lower bits, keeping guard bits

    // Output should match n
    assign quotient = n;

    // register outputs to use in next iteraton
    flopenr #(WIDTH) nreg (clk, ~stage, reset, product, n);
    flopenr #(WIDTH) dreg (clk, stage, reset, product, d);
    flopenr #(WIDTH) kreg (clk, stage, reset, {1'b0,~product[WIDTH-2:0]}, k);

endmodule

module goldschmidt_ctrl (
    input  logic clk, reset,
    output logic mode, stage
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