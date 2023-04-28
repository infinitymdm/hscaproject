module tb ();

    int fd_in, fd_out, fstatus; // file descriptor
    int num_pass, num_fail;
    string line;

    logic        clk = 0, reset;
    logic        round_mode;
    logic  [1:0] op;
    logic  [1:0] extra; // extra bits that I'm not sure about
    logic [31:0] radicand, expected_result, result;

    // Initilize clk
    always begin
        clk = ~clk; #5;
    end
    // Initialize device under test
    fpdiv dut(clk, reset, round_mode, op, radicand, 32'b0, result);

    initial begin
        fd_out = $fopen("results_sqrt.txt", "w");
        fd_in = $fopen("../fptests/vectors/f32_sqrt_test.tv", "r");
        op = 2'b01;     // 00=div, 01=sqrt
        round_mode = 0; // 0=rne, 1=rz

        // Pulse reset
        reset = 1;
        #155;
        reset = 0;
        #5;

        // Set up test parameters and table header
        num_pass = 0;
        num_fail = 0;
        $fdisplay(fd_out, "       N |        Q");
        $fdisplay(fd_out, "-------------------");
    end

    always @(negedge dut.divsqrt.enableN) begin
        #1;
        $display("N = %b", dut.divsqrt.goldschmidt.n);
    end

    always @(negedge dut.divsqrt.enableK) begin
        #1;
        $display("D = %b", dut.divsqrt.goldschmidt.d);
        $display("K = %b", dut.divsqrt.goldschmidt.k);
    end

    // Check output when starting a new operation
    always @(posedge dut.divsqrt.sctrl.signal) begin
        if (!reset) begin
            $fwrite(fd_out, "%h | %h \t ", radicand, result);
            if (result !== expected_result) begin
                $fdisplay(fd_out, "Fail! Expected %h", expected_result);
                $fdisplay(fd_out, "Expected: %b", expected_result);
                $fdisplay(fd_out, "Actual:   %b", result);
                num_fail++;
            end
            else begin
                $fdisplay(fd_out, "Ok");
                num_pass++;
            end
        end
        if (!$feof(fd_in)) begin
            fstatus = $fgets(line, fd_in); // Read in a test vector
            fstatus = $sscanf(line, "%8h_%8h_%2b", radicand, expected_result, extra);
            $display("Fetched args");
            $display("N0 = %b", radicand[22:0]);
            fstatus = $fgets(line, fd_in); // Every other line isn't useful
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