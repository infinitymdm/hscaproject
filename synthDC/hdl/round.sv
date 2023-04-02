module round_f32 (input logic x[31:0], // Also need to decide how many guard bits to have
                  input logic mode,
                  output logic y[31:0]
);

    assign y = x; // TODO

endmodule