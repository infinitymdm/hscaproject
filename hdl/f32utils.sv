module f32pack (
    input  logic        s,
    input  logic  [7:0] e,
    input  logic [22:0] m,
    output logic [31:0] f
);

    assign f = {s, e, m};

endmodule

module f32unpack (
    input  logic [31:0] f,
    output logic        s,
    output logic  [7:0] e,
    output logic [22:0] m
);

    assign {s, e, m} = f;

endmodule