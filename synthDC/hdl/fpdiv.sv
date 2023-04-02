module fpdiv (input  logic [31:0] dividend, divisor,
              output logic [31:0] quotient
);

    logic        s1, s2, s3; // sign bit
    logic [7:0]  e1, e2, e3; // 8-bit exponent
    logic [22:0] m1, m2, m3; // 23-bit mantissa

    logic decrement_exponent; // This wire tells the exponent calculation to decrement

    // Decompose inputs into floating point components
    assign {s1, e1, m1} = dividend;
    assign {s2, e2, m2} = divisor;

    mantissa_divider #(23) div(.m1, .m2, .m3, .decrement_exponent); // Calculate mantissa
    exponent_subtractor #(8) exp(.e1, .e2, .e3, .decrement(decrement_exponent)); // Calculate exponent
    assign s3 = s1 ^ s2; // Determine output sign

    // Compose output
    assign quotient = {s3, e3, m3};

endmodule