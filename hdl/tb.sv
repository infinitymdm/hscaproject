module tb ();

    int fd_in, fd_out, fstatus; // file descriptor
    int num_pass, num_fail;
    string line;

    logic        clk = 0, reset;
    logic        round_mode;
    logic  [1:0] op;
    logic [31:0] dividend, divisor, expected_quotient, quotient;

    // Initilize clk
    always begin
        clk = ~clk; #5;
    end
    // Initialize device under test
    fpdiv dut(clk, reset, round_mode, dividend, divisor, quotient);

    initial begin
        fd_out = $fopen("results.txt", "w");
        fd_in = $fopen("../fptests/vectors/f32_div_rne.tv", "r");
        round_mode = 0;

        // Pulse reset
        reset = 1;
        #120;
        reset = 0;

        // Set up test parameters and table header
        num_pass = 0;
        num_fail = 0;
        $fdisplay(fd_out, "       N |        D |        Q");
        $fdisplay(fd_out, "------------------------------");
    end

    always @(negedge dut.div.rem) begin
        $display("\nRemainder");
        $display("Sign = %b", dut.div.r_sign);
        $display("Zero = %b\n", dut.div.r_zero);
    end

    // Check output when starting a new operation
    always @(negedge dut.div.rem) begin
        if (!reset && |dividend) begin
            $fwrite(fd_out, "%h | %h | %h \t ", dividend, divisor, quotient);
            if (quotient !== expected_quotient) begin
                $fdisplay(fd_out, "Fail! Expected %h", expected_quotient);
                num_fail++;
            end
            else begin
                $fdisplay(fd_out, "Ok");
                num_pass++;
            end
        end
        if (!$feof(fd_in)) begin
            fstatus = $fgets(line, fd_in); // Read in a test vector
            fstatus = $sscanf(line, "%8h_%8h_%8h_%2b", dividend, divisor, expected_quotient, op);
            #5;
            $display("N = %b", dut.div.gdiv.numerator);
            $display("D = %b\n", dut.div.gdiv.denominator);
        end
        else begin
            $fclose(fd_in);
            $fdisplay(fd_out, "Passed: %d tests", num_pass);
            $fdisplay(fd_out, "Failed: %d tests", num_fail);
            $fclose(fd_out);
            #5;
            $finish;
        end
    end

endmodule