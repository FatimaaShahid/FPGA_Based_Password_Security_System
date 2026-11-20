
`timescale 1ns / 1ps

module tb_top_module;

    // Inputs
    reg CLK100MHZ = 0;
    reg [15:0] SW = 16'h0000;

    reg BTNC = 0;
    reg BTNU = 0;
    reg BTND = 0;

    // Outputs
    wire [6:0] SEG;
    wire [7:0] AN;
    wire DP;

    wire LED16_R;
    wire LED16_G;
    wire LED16_B;

    wire AUD_PWM;
    wire AUD_SD;

    // Existing top module - no changes required
    top_module DUT (
        .CLK100MHZ(CLK100MHZ),
        .SW(SW),
        .BTNC(BTNC),
        .BTNU(BTNU),
        .BTND(BTND),
        .SEG(SEG),
        .AN(AN),
        .DP(DP),
        .LED16_R(LED16_R),
        .LED16_G(LED16_G),
        .LED16_B(LED16_B),
        .AUD_PWM(AUD_PWM),
        .AUD_SD(AUD_SD)
    );

    // 100 MHz clock
    always #5 CLK100MHZ = ~CLK100MHZ;

    // Simulate button pulses directly.
    // This bypasses the existing debounce modules.

    task press_BTNC;
    begin
        @(negedge CLK100MHZ);
        force DUT.submit_pulse = 1'b1;
        repeat (2) @(negedge CLK100MHZ);
        release DUT.submit_pulse;
        repeat (3) @(negedge CLK100MHZ);
    end
    endtask

    task press_BTNU;
    begin
        @(negedge CLK100MHZ);
        force DUT.admin_pulse = 1'b1;
        repeat (2) @(negedge CLK100MHZ);
        release DUT.admin_pulse;
        repeat (3) @(negedge CLK100MHZ);
    end
    endtask

    task press_BTND;
    begin
        @(negedge CLK100MHZ);
        force DUT.reset_pulse = 1'b1;
        repeat (2) @(negedge CLK100MHZ);
        release DUT.reset_pulse;
        repeat (3) @(negedge CLK100MHZ);
    end
    endtask

    // Change switch value
    task set_switches;
        input [15:0] value;
    begin
        @(negedge CLK100MHZ);
        SW = value;
        repeat (4) @(negedge CLK100MHZ);
    end
    endtask

    // Print current results
    task show_result;
        input [8*60-1:0] message;
    begin
        $display("--------------------------------------------");
        $display("%0s", message);
        $display("Switches     : %h", SW);
        $display("Display mode : %d", DUT.display_mode);
        $display("Red LED      : %b", LED16_R);
        $display("Green LED    : %b", LED16_G);
        $display("Audio enable : %b", AUD_SD);
        $display("--------------------------------------------");
    end
    endtask

    // Main test sequence
    initial begin

        $display("============================================");
        $display(" FPGA PASSWORD LOCK - SIMULATION START");
        $display("============================================");

        // TEST 1: SYSTEM STARTUP
        press_BTND;
        show_result("TEST 1: Startup - ENTER expected");

        // TEST 2: CORRECT NORMAL PASSWORD
        set_switches(16'hB5A7);
        press_BTNC;
        show_result("TEST 2: Correct password - PASS expected");

        // TEST 3: RESET
        press_BTND;
        show_result("TEST 3: Reset - ENTER expected");

        // TEST 4: INCORRECT NORMAL PASSWORD
        set_switches(16'h5678);
        press_BTNC;
        show_result("TEST 4: Wrong password - FAIL expected");

        // TEST 5: RESET
        press_BTND;

        // TEST 6: ADMIN REQUEST
        press_BTNU;
        show_result("TEST 6: Admin request - AdPASS expected");

        // TEST 7: INCORRECT ADMIN PASSWORD
        set_switches(16'h2468);
        press_BTNC;
        show_result("TEST 7: Wrong admin password - DENIED expected");

        // TEST 8: ADMIN RETRY
        press_BTNC;
        show_result("TEST 8: Retry - AdPASS expected");

        // TEST 9: CORRECT ADMIN PASSWORD
        set_switches(16'h1234);
        press_BTNC;
        show_result("TEST 9: Correct admin - SETPASS expected");

        // TEST 10: ENTER NEW PASSWORD
        set_switches(16'hABCD);
        show_result("TEST 10: New password - ABCD expected");

        // TEST 11: SAVE NEW PASSWORD
        press_BTNC;
        show_result("TEST 11: Password saved - SAVED expected");

        // TEST 12: RESET
        press_BTND;
        show_result("TEST 12: Reset - ENTER expected");

        // TEST 13: VERIFY SAVED PASSWORD
        set_switches(16'h0000);
        set_switches(16'hABCD);
        press_BTNC;
        show_result("TEST 13: Saved password - PASS expected");

        $display("============================================");
        $display(" SIMULATION COMPLETED");
        $display("============================================");

        #100;
        $finish;

    end

endmodule
