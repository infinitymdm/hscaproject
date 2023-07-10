module exponent_op #(parameter WIDTH=8) (
    input  logic       [1:0] op,
    input  logic [WIDTH-1:0] e1, e2,
    input  logic             decrement,
    output logic             shift,
    output logic [WIDTH-1:0] e3
);
    logic [WIDTH-1:0] bias = 2**(WIDTH-1)-1;
    logic [WIDTH-1:0] e; // local for e before subtracting decrement
    always_comb
        case (op)
            00: {e, shift} = {(e1 - e2) + bias, 1'b0};
            01: {e, shift} = e1 + bias;
            default: {e, shift} = {WIDTH{1'bx}}
        endcase

    assign e3 = e - decrement;

endmodule