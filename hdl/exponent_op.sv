module exponent_op #(parameter WIDTH=8) (
    input  logic       [1:0] op,
    input  logic [WIDTH-1:0] e1, e2,
    input  logic             decrement,
    output logic             shift,
    output logic [WIDTH-1:0] e3
);

    logic [WIDTH-1:0] e; // local for e before subtracting decrement
    always_comb begin
        case (op)
            00: {e, shift} = {(e1 - e2) + (2**(WIDTH-1)-1), 1'b0};
            01: {e, shift} = {1'b0, (e1 - (2**(WIDTH-1)-1))};
        endcase
        e3 = e - decrement;
    end

endmodule