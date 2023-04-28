module goldschmidt #(parameter WIDTH=30) (
    input  logic             clk, reset,
    input  logic       [1:0] op,
    input  logic       [1:0] sA, sB,
    input  logic             enableN, enableD, enableK, enableQD,
    input  logic [WIDTH-1:0] numerator, denominator,
    output logic [WIDTH-1:0] quotient,
    output logic             rem_sign
);

    logic [2*WIDTH-1:0] product, sum, carry;
    logic [WIDTH-1:0] n, d, k, a, b, qd;
    logic [WIDTH-1:0] r1, r2;

    // Generate initial approximation
    logic [WIDTH-1:0] k0;
    logic [WIDTH-1:0] dk0 = {3'b011, {WIDTH-3{1'b0}}}; // 0.75
    logic [WIDTH-1:0] sk0 = 'b001_1011_0101_0000_0100_1111_0100_00; // approx 0.853553390593274
    mux2 #(WIDTH) muxIA (|op, dk0, sk0, k0);

    // mux inputs to get operands
    logic [WIDTH-1:0] b0;
    mux4 #(WIDTH) muxA (sA, k0, k, n, d, a);
    mux4 #(WIDTH) muxB0 (sB, numerator, denominator, n, d, b0);
    mux2 #(WIDTH) muxB1 (&sB & |op, b0, a << 3, b);

    // multiply operands
    mult_cs #(WIDTH) mult(a, b, 1'b0, sum, carry);
    assign product = (sum + carry);

    // Calculate remainder info
    assign rem_sign = |op ? 1'b0 : qd > numerator;

    // Output should match n
    assign quotient = n;

    // multiplex k register for 2-d (division) or (3-d)/2 (square root)
    logic [WIDTH-1:0] twos, threes, k_next;
    assign twos = {1'b0,~product[2*WIDTH-4:WIDTH-2]};
    assign threes = {~product[2*WIDTH-3], product[2*WIDTH-4], ~product[2*WIDTH-5:WIDTH-2]};
    mux2 #(WIDTH) muxK (|op, twos, threes, k_next);

    // register outputs to use in next iteraton
    flopenr #(WIDTH) regN  (clk, enableN,  reset, product[2*WIDTH-3:WIDTH-2],                      n);
    flopenr #(WIDTH) regD  (clk, enableD,  reset, product[2*WIDTH-3:WIDTH-2],                      d);
    flopenr #(WIDTH) regK  (clk, enableK,  reset, k_next,                                          k);
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

module sqrt_ctrl (
    input  logic       clk, reset,
    output logic [1:0] sA, sB,
    output logic       enableN, enableD, enableK, enableQD
);

    logic [3:0] count, enables;
    logic signal; // local that just exists for the sake of timing

    // Set up enables for easy assignment
    assign {enableN, enableD, enableK, enableQD} = enables;

    // state logic implemented using counter
    always @(posedge clk, posedge reset)
        if (reset) // next cycle will be 0
            count = 15;
        else if (count >= 15)
            count = 0;
        else
            count++;

    // output logic
    // This is pretty verbose since this takes 3 cycles per iteration
    // Patterns are a bit more difficult with 3 iterations
    always_comb begin
        case (count)
            0:  begin
                    signal = 1;
                    sA = 2'b00;
                    sB = 2'b00;
                end
            1:  begin
                    sA = 2'b00;
                    sB = 2'b11; // Setting this to 11 during sqrt forces both inputs to the multiplier to use A
                end
            2:  begin
                    sA = 2'b10;
                    sB = 2'b10;
                end
            3:  begin
                    sA = 2'b01;
                    sB = 2'b10;
                end
            4:  begin
                    sA = 2'b01;
                    sB = 2'b11;
                end
            5:  begin
                    sA = 2'b10;
                    sB = 2'b10;
                end
            3:  begin
                    sA = 2'b01;
                    sB = 2'b10;
                end
            4:  begin
                    sA = 2'b01;
                    sB = 2'b11;
                end
            5:  begin
                    sA = 2'b10;
                    sB = 2'b10;
                end
            3:  begin
                    sA = 2'b01;
                    sB = 2'b10;
                end
            4:  begin
                    sA = 2'b01;
                    sB = 2'b11;
                end
            5:  begin
                    sA = 2'b10;
                    sB = 2'b10;
                end
            3:  begin
                    sA = 2'b01;
                    sB = 2'b10;
                end
            4:  begin
                    sA = 2'b01;
                    sB = 2'b11;
                end
            5:  begin
                    sA = 2'b10;
                    sB = 2'b10;
                end
            15: begin
                    signal = 0;
                    sA = 2'b01;
                    sB = 2'b10;
                end
        endcase
        case (count % 3)
            0: enables = 4'b1000;
            1: enables = 4'b0100;
            2: enables = 4'b0110;
            default: enables = 4'bxxxx;
        endcase
    end

endmodule