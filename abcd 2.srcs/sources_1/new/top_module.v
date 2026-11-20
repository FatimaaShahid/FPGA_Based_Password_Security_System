module top_module(
    input  wire CLK100MHZ,
    input  wire [15:0] SW,

    input  wire BTNC,
    input  wire BTNU,
    input  wire BTND,

    output wire [6:0] SEG,
    output wire [7:0] AN,
    output wire DP,

    output wire LED16_R,
    output wire LED16_G,
    output wire LED16_B,

    output wire AUD_PWM,
    output wire AUD_SD
);

    wire submit_pulse;
    wire admin_pulse;
    wire reset_pulse;

    wire [3:0] display_mode;

    wire led_red;
    wire led_green;

    wire success_tone;
    wire failure_tone;

    // Button debouncing
    button_debounce submit_button (
        .clk(CLK100MHZ),
        .button(BTNC),
        .pulse(submit_pulse)
    );

    button_debounce admin_button (
        .clk(CLK100MHZ),
        .button(BTNU),
        .pulse(admin_pulse)
    );

    button_debounce reset_button (
        .clk(CLK100MHZ),
        .button(BTND),
        .pulse(reset_pulse)
    );

    // Password controller
    password_controller controller (
        .clk(CLK100MHZ),
        .reset(reset_pulse),
        .submit(submit_pulse),
        .admin_request(admin_pulse),
        .switches(SW),

        .display_mode(display_mode),
        .led_red(led_red),
        .led_green(led_green),
        .success_tone(success_tone),
        .failure_tone(failure_tone)
    );

    // Seven-segment display
    seven_segment display_unit (
        .clk(CLK100MHZ),
        .switches(SW),
        .display_mode(display_mode),
        .SEG(SEG),
        .AN(AN),
        .DP(DP)
    );

    // Audio controller
    audio_controller audio_unit (
        .clk(CLK100MHZ),
        .success(success_tone),
        .failure(failure_tone),
        .AUD_PWM(AUD_PWM),
        .AUD_SD(AUD_SD)
    );

    // RGB LED outputs
    assign LED16_R = led_red;
    assign LED16_G = led_green;
    assign LED16_B = 1'b0;

endmodule