module fpdiv (
    input  logic        clk, reset, rm,
    input  logic  [1:0] op,
    input  logic [31:0] n, d,
    output logic [31:0] result
);

    logic        s1, s2, s3; // sign bit
    logic [7:0]  e1, e2, e3; // 8-bit exponent
    logic [22:0] m1, m2, m3; // 23-bit mantissa

    logic decrement_exponent; // This wire tells the exponent calculation to decrement

    // Unpack inputs into floating point components
    f32unpack fd1(n, s1, e1, m1);
    f32unpack fd2(d, s2, e2, m2);

    assign s3 = s1 ^ s2; // Determine output sign
    esub #(8) exp(.e1, .e2, .e3, .decrement(decrement_exponent)); // Calculate exponent
    mantissa_op #(23) div(.clk, .reset, .round_mode(rm), .op, .m1, .m2, .m3, .decrement_exponent); // Calculate mantissa (takes 12 cycles)

    // Pack output into f32 format
    f32pack fq(s3, e3, m3, result);

endmodule