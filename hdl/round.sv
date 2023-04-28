module round_ne #(parameter WIDTH=28, ULP=4) (
    input  logic [WIDTH-1:0] x,
    input  logic             rem_is_positive,
    output logic [WIDTH-1:0] y
);
    logic [WIDTH-1:0] lsb = {{WIDTH-1{1'b0}}, 1'b1};

    always_comb
        if (x[ULP-1] && rem_is_positive) begin// If the remainder is positive AND 1st guard bit is 1
            $display("x:   %b", x);
            $display("LSB: %b", (lsb << ULP));
            y = x + (lsb << ULP); // Add an ULP
            $display("y:   %b", y);
        end
        else
            y = {x[WIDTH-1:ULP], {ULP{1'b0}}}; // truncate

endmodule

module round_z #(parameter WIDTH=28, ULP=4) (
    input  logic [WIDTH-1:0] x,
    input  logic             rem_is_negative,
    output logic [WIDTH-1:0] y
);

    always_comb
        if (~x[ULP-1] && rem_is_negative) // If remainder is negative and 1st guard bit is zero
            y = x - (1'b1 << ULP); // Subtract an ULP
        else
            y = {x[WIDTH-1:ULP], {ULP{1'b0}}}; // truncate

endmodule