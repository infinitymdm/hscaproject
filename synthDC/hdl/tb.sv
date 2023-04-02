module tb ();

    logic [31:0] dividend, divisor, quotient;

    fpdiv dut(dividend, divisor, quotient);

    initial begin
        #10;
        dividend = 32'b00111111100000011000010111100000;
        #10;
        divisor  = 32'b00111111111010101100100001110001;
        #10;
        $display("q = %b", quotient);
    end

endmodule