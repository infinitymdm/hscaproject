module exponent_subtractor #(parameter WIDTH=8) (
    input  logic [WIDTH-1:0] e1, e2,
    input  logic             decrement,
    output logic [WIDTH-1:0] e3
);

    assign e3 = e1 - e2 + 2**WIDTH - 1 - decrement;

endmodule