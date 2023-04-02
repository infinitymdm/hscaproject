module f32decomp (
    input  logic [31:0] f,
    output logic        s,
    output logic  [7:0] e,
    output logic [22:0] m
);

    assign {s, e, m} = f;

endmodule