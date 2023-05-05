module goldschmidt #(parameter LEADS=2, WIDTH=28) (
    input  logic                   clk, reset,
    input  logic             [1:0] op,
    input  logic             [1:0] sA, sB,
    input  logic                   enableN, enableD, enableK, enableQD,
    input  logic [LEADS+WIDTH-1:0] n0, d0,
    output logic [LEADS+WIDTH-1:0] result,
    output logic                   r_sign
);
    localparam SIZE = LEADS+WIDTH;

    logic [2*SIZE-1:0] product, sum, carry;
    logic [SIZE-1:0] n, d, k, a, b, qd;

    // Generate initial approximation
    logic [SIZE-1:0] k0;
    logic [SIZE-1:0] dk0 = {{LEADS{1'b0}}, 2'b11, {WIDTH-2{1'b0}}}; // 0.75
    logic [SIZE-1:0] sk0 = {{LEADS{1'b0}}, 28'b0110110101000001001111001101}; // approx 0.853553390593274
    mux2 #(SIZE) muxIA (|op, dk0, sk0, k0);

    // mux inputs to get operands
    always_comb begin
        // muxA
        case (sA)
            0: a = k0;
            1: a = k;
            2: a = n;
            default: a = {SIZE{1'bz}};
        endcase
        // muxB
        case (sB)
            0: b = n0;
            1: b = d0;
            2: b = n;
            3: b = d;
            default: b = a;
        endcase
    end

    // multiply operands
    mult_cs #(SIZE) mult(a, b, 1'b0, sum, carry);
    assign product = (sum + carry);

    // Calculate remainder info
    assign r_sign = |op ? 1'b0 : qd > n0;

    // Output should match n
    assign result = n;

    // multiplex k register for 2-d (division) or (3-d)/2 (square root)
    logic [SIZE-1:0] k_next;
    always_comb
        // muxK
        case (~|op | |sB)
            1:  k_next = {{LEADS-1{1'b0}}, ~product[2*SIZE-LEADS-2:SIZE-LEADS]};
            0:  k_next = {{LEADS-1{1'b0}}, ~product[2*SIZE-LEADS-2], product[2*SIZE-LEADS-2], ~product[2*SIZE-LEADS-3:SIZE-LEADS+1]};
            default: k_next = product[2*SIZE-LEADS-1:SIZE-LEADS]; // k^2
        endcase

    // register outputs to use in next iteraton
    flopenr #(SIZE) regN  (clk, enableN,  reset, product[2*SIZE-LEADS-1:SIZE-LEADS],                           n);
    flopenr #(SIZE) regD  (clk, enableD,  reset, product[2*SIZE-LEADS-1:SIZE-LEADS],                           d);
    flopenr #(SIZE) regK  (clk, enableK,  reset, k_next,                                                       k);
    flopenr #(SIZE) regQD (clk, enableQD, reset, {product[2*SIZE-LEADS-1:2*SIZE-2*LEADS], {SIZE-LEADS{1'b0}}}, qd);

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
                    sA = 2'b00; // k0
                    sB = 2'b00; // n0
                end
            1:  begin
                    sA = 2'b00; // k0
                    sB = 2'bxx; // Forces both to use a
                end
            2:  begin
                    sA = 2'b01; // k
                    sB = 2'b00; // n0
                end
            3:  begin
                    sA = 2'b01; // k
                    sB = 2'b10; // n
                end
            4:  begin
                    sA = 2'b01; // k
                    sB = 2'bxx; // k
                end
            5:  begin
                    sA = 2'b01; // k
                    sB = 2'b11; // d
                end
            6:  begin
                    sA = 2'b01; // k
                    sB = 2'b10; // n
                end
            7:  begin
                    sA = 2'b01; // k
                    sB = 2'bxx; // k
                end
            8:  begin
                    sA = 2'b01; // k
                    sB = 2'b11; // d
                end
            9:  begin
                    sA = 2'b01; // k
                    sB = 2'b10; // n
                end
            10:  begin
                    sA = 2'b01; // k
                    sB = 2'bxx; // k
                end
            11:  begin
                    sA = 2'b01; // k
                    sB = 2'b11; // d
                end
            12:  begin
                    sA = 2'b01; // k
                    sB = 2'b10; // n
                end
            13:  begin
                    sA = 2'b01; // k
                    sB = 2'bxx; // k
                end
            14:  begin
                    sA = 2'b01; // k
                    sB = 2'b11; // d
                end
            15: begin
                    signal = 0;
                    sA = 2'b01; // k
                    sB = 2'b10; // n
                end
        endcase
        case (count % 3)
            //              ndk
            0: enables = 4'b1000;
            1: enables = 4'b0010;
            2: enables = 4'b0110;
            default: enables = 4'bxxxx;
        endcase
    end

endmodule