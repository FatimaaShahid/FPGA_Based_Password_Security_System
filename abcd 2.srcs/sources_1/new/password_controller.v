
module password_controller(
    input  wire clk,
    input  wire reset,
    input  wire submit,
    input  wire admin_request,
    input  wire [15:0] switches,

    output reg [3:0] display_mode,
    output reg led_red,
    output reg led_green,
    output reg success_tone,
    output reg failure_tone
);

    // FSM states
    localparam IDLE         = 4'd0;
    localparam ADMIN_ENTRY  = 4'd1;
    localparam SET_NOTICE   = 4'd2;
    localparam NEW_ENTRY    = 4'd3;
    localparam PASS_STATE   = 4'd4;
    localparam FAIL_STATE   = 4'd5;
    localparam DENIED       = 4'd6;
    localparam SAVED        = 4'd7;

    // Passwords
    localparam [15:0] ADMIN_PASSWORD = 16'h1234;

    reg [3:0] state = IDLE;

    // User password
    reg [15:0] normal_password = 16'hB5A7;

    // Switch-change detection
    reg [15:0] previous_switches = 16'h0000;
    reg input_started = 1'b0;

    // Sequential FSM
    always @(posedge clk) begin

        if (reset) begin
            state <= IDLE;
            input_started <= 1'b0;
            previous_switches <= switches;

            // Do NOT reset normal_password.
            // Saved password remains after BTND.
        end

        else begin
            
            // Detect switch changes during password entry
            if (switches != previous_switches)
                input_started <= 1'b1;

            previous_switches <= switches;

            case (state)

                // NORMAL PASSWORD MODE
                IDLE: begin

                    if (admin_request) begin
                        state <= ADMIN_ENTRY;
                        input_started <= 1'b0;
                        previous_switches <= switches;
                    end

                    else if (submit && input_started) begin

                        if (switches == normal_password)
                            state <= PASS_STATE;
                        else
                            state <= FAIL_STATE;

                        input_started <= 1'b0;
                    end
                end

                // ADMIN PASSWORD VERIFICATION
                ADMIN_ENTRY: begin

                    if (submit && input_started) begin

                        if (switches == ADMIN_PASSWORD) begin
                            state <= SET_NOTICE;
                        end
                        else begin
                            state <= DENIED;
                        end

                        input_started <= 1'b0;
                        previous_switches <= switches;
                    end
                end

                // ADMIN ACCEPTED: SHOW SET PASSWORD
                SET_NOTICE: begin

                    if (submit) begin
                        state <= NEW_ENTRY;
                        input_started <= 1'b0;
                        previous_switches <= switches;
                    end
                end

                // ENTER NEW NORMAL PASSWORD
                NEW_ENTRY: begin

                    if (submit && input_started) begin

                        normal_password <= switches;

                        state <= SAVED;
                        input_started <= 1'b0;
                    end
                end

                // WRONG ADMIN PASSWORD
                DENIED: begin

                    // Press BTNC to retry admin verification
                    if (submit) begin
                        state <= ADMIN_ENTRY;
                        input_started <= 1'b0;
                        previous_switches <= switches;
                    end
                end

                // SUCCESSFUL NORMAL PASSWORD
                PASS_STATE: begin
                    // Remain until BTND reset
                end

                // INCORRECT NORMAL PASSWORD
                FAIL_STATE: begin
                    // Remain until BTND reset
                end

                // PASSWORD SAVED
                SAVED: begin
                    // Remain until BTND reset
                end

                default: begin
                    state <= IDLE;
                    input_started <= 1'b0;
                end

            endcase
        end
    end

    // DISPLAY AND OUTPUT CONTROL
    always @(*) begin

        display_mode = 4'd1; // ENTER

        led_red = 1'b0;
        led_green = 1'b0;

        success_tone = 1'b0;
        failure_tone = 1'b0;

        case (state)

            // Normal entry
            IDLE: begin
                if (input_started)
                    display_mode = 4'd0;
                else
                    display_mode = 4'd1;
            end

            // Admin password entry
            ADMIN_ENTRY: begin
                if (input_started)
                    display_mode = 4'd0;
                else
                    display_mode = 4'd2; // AdPASS
            end

            // Admin accepted
            SET_NOTICE: begin
                display_mode = 4'd3; // SETPASS
            end
            
            NEW_ENTRY: begin
                display_mode = 4'd0; // Display new hexadecimal password
            end

            // Normal password correct
            PASS_STATE: begin
                display_mode = 4'd4; // PASS
                led_green = 1'b1;
                success_tone = 1'b1;
            end

            // Normal password incorrect
            FAIL_STATE: begin
                display_mode = 4'd5; // FAIL
                led_red = 1'b1;
                failure_tone = 1'b1;
            end

            // Admin password incorrect
            DENIED: begin
                display_mode = 4'd6; // DENIED
                led_red = 1'b1;
                failure_tone = 1'b1;
            end

            // New password saved
            SAVED: begin
                display_mode = 4'd7; // SAVED
                led_green = 1'b1;
            end

            default: begin
                display_mode = 4'd1;
            end

        endcase
    end

endmodule
