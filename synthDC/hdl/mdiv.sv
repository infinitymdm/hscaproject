module mdiv #(parameter WIDTH=23) (
    input  logic [WIDTH-1:0] m1, m2,
    output logic [WIDTH-1:0] m3,
    output logic decrement_exponent
);

    logic [2*WIDTH:0] dividend;
    logic   [WIDTH:0] divisor;
    logic   [WIDTH:0] quotient;

    // Perform division
    assign dividend = {1'b1, m1, {WIDTH{1'b0}}};
    assign divisor = {1'b1, m2};
    assign quotient = (dividend / divisor);

    // Assign outputs
    assign decrement_exponent = ~quotient[WIDTH];
    assign m3 = quotient[WIDTH-1:0] << ~quotient[WIDTH];

endmodule