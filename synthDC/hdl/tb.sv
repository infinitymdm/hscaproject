module tb ();

    logic [31:0] dividend, divisor, quotient;

    fpdiv dut(dividend, divisor, quotient);

    initial begin
        #10;
        dividend = 32'd1065453024;
        #10;
        divisor  = 32'd1072351345;
        #10;
        $display("q = %d", quotient);
    end

endmodule