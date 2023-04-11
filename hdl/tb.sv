module tb ();

    int fd, fstatus; // file descriptor
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
        fd = $fopen("../fptests/vectors/f32_div_test.tv", "r");

        // Pulse reset
        reset = 1;
        #160;
        reset = 0;

        // Set up test parameters and table header
        num_pass = 0;
        num_fail = 0;
        $display("       N |        D |        Q");
        $display("------------------------------");
    end

    int i = 0;
    always @(negedge clk)
        if (!reset) begin
            if (~dut.div.stage) begin
                $display("i = %-d", i);
                $display("N = %b", dut.div.gdiv.product);
                i = (i+1) % 6;
            end
            else begin
                $display("D = %b", dut.div.gdiv.product);
                $display("R = %b", (~dut.div.gdiv.product)>>1);
            end
        end

    // Check output when starting a new operation
    always @(negedge dut.div.mode) begin
        if (!reset && |dividend) begin
            $write("%h | %h | %h \t ", dividend, divisor, quotient);
            if (quotient !== expected_quotient) begin
                $display("Fail! Expected %h", expected_quotient);
                num_fail++;
            end
            else begin
                $display("Ok");
                num_pass++;
            end
        end
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

endmodule