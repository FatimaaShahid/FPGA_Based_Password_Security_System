module audio_controller(
    input  wire clk,
    input  wire success,
    input  wire failure,
    output reg AUD_PWM,
    output reg AUD_SD
);

    reg success_previous = 0;
    reg failure_previous = 0;

    reg [24:0] duration_counter = 0;
    reg [16:0] tone_counter = 0;

    reg [16:0] tone_limit = 50000;
    reg active = 0;

    always @(posedge clk) begin

        success_previous <= success;
        failure_previous <= failure;

        // Start a new tone when a result state is entered
        if ((success && !success_previous) ||
            (failure && !failure_previous)) begin

            active <= 1;
            duration_counter <= 0;
            tone_counter <= 0;

            if (success)
                tone_limit <= 50000; // Approximately 1 kHz
            else
                tone_limit <= 25000; // Approximately 2 kHz
        end

        else if (active) begin

            if (duration_counter >= 25_000_000) begin
                active <= 0;
                AUD_PWM <= 0;
            end
            else begin
                duration_counter <= duration_counter + 1;

                if (tone_counter >= tone_limit) begin
                    tone_counter <= 0;
                    AUD_PWM <= ~AUD_PWM;
                end
                else begin
                    tone_counter <= tone_counter + 1;
                end
            end
        end

        else begin
            AUD_PWM <= 0;
        end
    end

    always @(*) begin
        AUD_SD = active;
    end

endmodule