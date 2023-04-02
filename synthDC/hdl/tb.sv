module tb ();

    logic [31:0] dividend, divisor, quotient;

    fpdiv dut(dividend, divisor, quotient);

    initial begin
        #10;
        dividend = 32'b00111111111100110011001110011000;
        #10;
        divisor  = 32'b00111111100000010110100110010000;
        #10;
        $display("q expected = 00111111111100001000110000011110");
        $display("q =          %b", quotient);
    end

endmodule