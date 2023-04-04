module tb ();

    int fd; // file descriptor
    int fstatus;
    string line;

    logic [1:0]  round_mode;
    logic [31:0] dividend, divisor, expected_quotient, quotient;

    // Initialize device under test
    fpdiv dut(dividend, divisor, quotient);

    initial begin
        fd = $fopen("../fptests/vectors/f32_div_rne.tv", "r");
        $display("       N |        D |        Q");
        $display("------------------------------");
        while (!$feof(fd)) begin
            fstatus = $fgets(line, fd); // Read in a test vector
            $display("%s", line);
            fstatus = $sscanf(line, "%8h_%8h_%8h_%2b", dividend, divisor, expected_quotient, round_mode);
            #10;
            $write("%h | %h | %h \t ", dividend, divisor, quotient);
            if (quotient !== expected_quotient) begin
                $display("Fail! Expected %h", expected_quotient);
            end
            else begin
                $display("Ok");
            end
        end
        $fclose(fd);
        $finish;
    end

endmodule