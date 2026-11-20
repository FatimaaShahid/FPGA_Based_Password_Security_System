module button_debounce #(
    parameter COUNT_MAX = 1_000_000
)(
    input  wire clk,
    input  wire button,
    output reg  pulse
);

    reg button_sync0 = 0;
    reg button_sync1 = 0;
    reg button_stable = 0;

    reg [20:0] counter = 0;

    always @(posedge clk) begin
        button_sync0 <= button;
        button_sync1 <= button_sync0;
        pulse <= 0;

        if (button_sync1 == button_stable) begin
            counter <= 0;
        end
        else begin
            if (counter < COUNT_MAX - 1) begin
                counter <= counter + 1;
            end
            else begin
                counter <= 0;
                button_stable <= button_sync1;

                if (button_sync1)
                    pulse <= 1;
            end
        end
    end

endmodule