
`timescale 1ns / 1ps

module tb_password_controller;

    reg clk;
    reg reset;
    reg enter_pulse;
    reg [7:0] switches;

    wire [7:0] entered_password;
    wire success;
    wire failure;

    // Instantiate password controller
    password_controller uut (
        .clk(clk),
        .reset(reset),
        .enter_pulse(enter_pulse),
        .switches(switches),
        .entered_password(entered_password),
        .success(success),
        .failure(failure)
    );

    // 100 MHz clock (10 ns period)
    always #5 clk = ~clk;

    initial begin

        // Initial values
        clk = 0;
        reset = 1;
        enter_pulse = 0;
        switches = 8'b00000000;

        #20;
        reset = 0;

        // TEST 1: Correct password
        $display("TEST 1: Correct Password");

        @(negedge clk);
        switches = 8'b10110101;
        enter_pulse = 1;

        @(negedge clk);
        enter_pulse = 0;

        #1;

        if (success && !failure)
            $display("PASS: Correct password accepted");
        else
            $display("ERROR: Correct password rejected");

        // Reset before next test
        @(negedge clk);
        reset = 1;

        @(negedge clk);
        reset = 0;

        // TEST 2: Incorrect password
        $display("TEST 2: Incorrect Password");

        switches = 8'b11110000;
        enter_pulse = 1;

        @(negedge clk);
        enter_pulse = 0;

        #1;

        if (failure && !success)
            $display("PASS: Incorrect password rejected");
        else
            $display("ERROR: Incorrect password accepted");

        // End simulation
        #20;
        $finish;

    end

endmodule
