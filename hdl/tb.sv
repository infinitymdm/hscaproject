module tb ();

    logic [31:0] dividend, divisor, quotient;

    fpdiv dut(dividend, divisor, quotient);

    initial begin
        #10;
        dividend = 32'h8683F7FF;
        #10;
        divisor  = 32'hC07F3FFF;
        #10;
        $display("q expected = 05845B44");
        $display("q          = %h", quotient);
    end

endmodule