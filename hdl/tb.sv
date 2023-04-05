module tb ();

    int fd, fstatus; // file descriptor
    int num_pass, num_fail;
    string line;

    logic [1:0]  round_mode;
    logic [31:0] dividend, divisor, expected_quotient, quotient;

    // Initialize device under test
    fpdiv dut(dividend, divisor, quotient);

    initial begin
        num_pass = 0;
        num_fail = 0;
        fd = $fopen("../fptests/vectors/f32_div_rne.tv", "r");
        $display("       N |        D |        Q");
        $display("------------------------------");
        while (!$feof(fd)) begin
            fstatus = $fgets(line, fd); // Read in a test vector
            fstatus = $sscanf(line, "%8h_%8h_%8h_%2b", dividend, divisor, expected_quotient, round_mode);
            #10;
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
        $fclose(fd);
        $display("Passed: %d tests", num_pass);
        $display("Failed: %d tests", num_fail);
        $finish;
    end

endmodule