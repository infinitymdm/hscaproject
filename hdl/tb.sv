module tb ();

    int fd_in, fd_out, fstatus; // file descriptor
    int num_pass, num_fail;
    string line;

    logic        clk = 0, reset;
    logic [1:0]  round_mode;
    logic [31:0] dividend, divisor, expected_quotient, quotient;

    // Initilize clk
    always begin
        clk = ~clk; #5;
    end
    // Initialize device under test
    fpdiv dut(clk, reset, dividend, divisor, quotient);

    initial begin
        fd_out = $fopen("results.txt", "w");
        fd_in = $fopen("../fptests/vectors/f32_div_test.tv", "r");

        // Pulse reset
        reset = 1;
        #160;
        reset = 0;

        // Set up test parameters and table header
        num_pass = 0;
        num_fail = 0;
        $fdisplay(fd_out, "       N |        D |        Q");
        $fdisplay(fd_out, "------------------------------");
    end

    int i = 0;
    always @(negedge clk)
        if (!reset) begin
            if (~dut.div.stage) begin
                $display("i = %-d", i);
                $display("N = %b.%b", dut.div.gdiv.product[29:28], dut.div.gdiv.product[27:0]);
                i = (i+1) % 6;
            end
            else begin
                $display("D = %b.%b", dut.div.gdiv.product[29:28], dut.div.gdiv.product[27:0]);
                $display("R = %b.%b", {1'b0, ~dut.div.gdiv.product[28]}, ~dut.div.gdiv.product[27:0]);
            end
        end

    always @(negedge dut.div.rem) begin
        $display("N0   = %b", dut.div.gdiv.numerator);
        #5;
        $display("Q*D0 = %b", dut.div.gdiv.r);
        $display("RREM = %b\n", dut.div.gdiv.remainder);
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
            fstatus = $sscanf(line, "%8h_%8h_%8h_%2b", dividend, divisor, expected_quotient, round_mode);
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