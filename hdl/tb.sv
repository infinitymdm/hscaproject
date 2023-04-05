module tb ();

    int fd, fstatus; // file descriptor
    int num_pass, num_fail;
    string line;

    logic        clk = 0, gclk, reset;
    logic [1:0]  round_mode;
    logic [31:0] dividend, divisor, expected_quotient, quotient;

    // Initilize clk
    always begin
        clk = ~clk; #5;
    end
    clk_div clock_divider (clk, gclk);

    // Initialize device under test
    fpdiv dut(clk, reset, dividend, divisor, quotient);

    initial begin
        // Pulse reset
        reset = 1;
        #100;
        reset = 0;

        // Set up test parameters and table header
        num_pass = 0;
        num_fail = 0;
        fd = $fopen("../fptests/vectors/f32_div_rne.tv", "r");
        $display("       N |        D |        Q");
        $display("------------------------------");
    end

    // Apply stimulus
    always @(posedge gclk) begin
        if (!$feof(fd)) begin
            fstatus = $fgets(line, fd); // Read in a test vector
            fstatus = $sscanf(line, "%8h_%8h_%8h_%2b", dividend, divisor, expected_quotient, round_mode);
        end
        else begin
            $fclose(fd);
            $display("Passed: %d tests", num_pass);
            $display("Failed: %d tests", num_fail);
            $finish;
        end
    end

    // Check output
    always @(negedge gclk) begin
        $write("%h | %h | %b \t ", dividend, divisor, quotient);
        if (quotient !== expected_quotient) begin
            $display("Fail! Expected %b", expected_quotient);
            num_fail++;
        end
        else begin
            $display("Ok");
            num_pass++;
        end
    end

endmodule