module tb ();

    int fd_in, fd_out, fstatus; // file descriptor
    int num_pass, num_fail;
    string line;

    logic        clk = 0, reset;
    logic        round_mode;
    logic  [1:0] op;
    logic  [1:0] extra; // extra bits that I'm not sure about
    logic [31:0] dividend, divisor, expected_quotient, quotient;

    // Initilize clk
    always begin
        clk = ~clk; #5;
    end
    // Initialize device under test
    fpdiv dut(clk, reset, round_mode, op, dividend, divisor, quotient);

    initial begin
        fd_out = $fopen("results_div.txt", "w");
        fd_in = $fopen("../fptests/vectors/f32_div_rne.tv", "r");
        op = 2'b00;     // 00=div, 01=sqrt
        round_mode = 0; // 0=rne, 1=rz

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

    always @(negedge dut.divsqrt.enableN) begin
        #1;
        $display("N = %b", dut.divsqrt.goldschmidt.n);
    end

    always @(negedge dut.divsqrt.enableD) begin
        #1;
       $display("D = %b", dut.divsqrt.goldschmidt.d);
    end


    always @(negedge dut.divsqrt.enableK) begin
        #1;
        $display("K = %b", dut.divsqrt.goldschmidt.k);
    end

    always @(negedge dut.divsqrt.goldschmidt.enableQD) begin
        #1;
        $display("QD = %b", dut.divsqrt.goldschmidt.qd);
    end

    // Check output when starting a new operation
    always @(negedge dut.divsqrt.dctrl.rem) begin
        if (!reset && |dividend) begin
            #1;
            $fwrite(fd_out, "%h | %h | %h \t ", dividend, divisor, quotient);
            if (quotient !== expected_quotient) begin
                $fdisplay(fd_out, "Fail! Expected %h", expected_quotient);
                $fdisplay(fd_out, "Expected: %b", expected_quotient);
                $fdisplay(fd_out, "Actual:   %b", quotient);
                $fdisplay(fd_out, "QD: %b", dut.divsqrt.goldschmidt.qd);
                $fdisplay(fd_out, "-R: %b", dut.divsqrt.r_sign);
                num_fail++;
            end
            else begin
                $fdisplay(fd_out, "Ok");
                num_pass++;
            end
        end
        if (!$feof(fd_in)) begin
            #1
            fstatus = $fgets(line, fd_in); // Read in a test vector
            fstatus = $sscanf(line, "%8h_%8h_%8h_%2b", dividend, divisor, expected_quotient, extra);
            $display("Fetched args");
            $display("N0 = %b", dut.divsqrt.m1);
            $display("D0 = %b", dut.divsqrt.m2);
        end
        else begin
            #1;
            $fclose(fd_in);
            $fdisplay(fd_out, "Passed: %d tests", num_pass);
            $fdisplay(fd_out, "Failed: %d tests", num_fail);
            $fclose(fd_out);
            #4;
            $finish;
        end
    end

endmodule