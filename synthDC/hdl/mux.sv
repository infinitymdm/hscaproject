module mux2 #(parameter SIZE=8) (
    input  logic            s,
    input  logic [SIZE-1:0] a, b,
    output logic [SIZE-1:0] y
);

    assign y = s ? b : a;

endmodule

module mux4 #(parameter SIZE=8) (
    input  logic      [1:0] s,
    input  logic [SIZE-1:0] a, b, c, d,
    output logic [SIZE-1:0] y
);

    always_comb
        case (s)
            0: y = a;
            1: y = b;
            2: y = c;
            3: y = d;
            default: y = {SIZE{1'bx}};
        endcase

endmodule