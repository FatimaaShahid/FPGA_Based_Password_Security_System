module seven_segment(
    input  wire clk,
    input  wire [15:0] switches,
    input  wire [3:0] display_mode,
    output reg [6:0] SEG,
    output reg [7:0] AN,
    output wire DP
);

    reg [18:0] refresh_counter = 0;
    wire [2:0] digit_select;

    reg [4:0] digit_code;
    reg [6:0] segment_pattern;

    assign digit_select = refresh_counter[18:16];
    assign DP = 1'b1; // Decimal point off

    always @(posedge clk)
        refresh_counter <= refresh_counter + 1;

    // Select the character for the currently active digit
    always @(*) begin

        digit_code = 5'd16; // Blank by default

        case (display_mode)

            // Four-digit hexadecimal switch value
            4'd0: begin
                case (digit_select)
                    0: digit_code = {1'b0, switches[3:0]};
                    1: digit_code = {1'b0, switches[7:4]};
                    2: digit_code = {1'b0, switches[11:8]};
                    3: digit_code = {1'b0, switches[15:12]};
                    default: digit_code = 5'd16;
                endcase
            end

            // ENTER
            4'd1: begin
                case (digit_select)
                    4: digit_code = 5'd21; // E
                    3: digit_code = 5'd22; // n
                    2: digit_code = 5'd23; // t
                    1: digit_code = 5'd21; // E
                    0: digit_code = 5'd24; // r
                    default: digit_code = 5'd16;
                endcase
            end

            // AdPASS
            4'd2: begin
                case (digit_select)
                    5: digit_code = 5'd10; // A
                    4: digit_code = 5'd18; // d
                    3: digit_code = 5'd19; // P
                    2: digit_code = 5'd10; // A
                    1: digit_code = 5'd20; // S
                    0: digit_code = 5'd20; // S
                    default: digit_code = 5'd16;
                endcase
            end

            // SETPASS
            4'd3: begin
                case (digit_select)
                    6: digit_code = 5'd20; // S
                    5: digit_code = 5'd21; // E
                    4: digit_code = 5'd23; // t
                    3: digit_code = 5'd19; // P
                    2: digit_code = 5'd10; // A
                    1: digit_code = 5'd20; // S
                    0: digit_code = 5'd20; // S
                    default: digit_code = 5'd16;
                endcase
            end

            // PASS
            4'd4: begin
                case (digit_select)
                    3: digit_code = 5'd19;
                    2: digit_code = 5'd10;
                    1: digit_code = 5'd20;
                    0: digit_code = 5'd20;
                    default: digit_code = 5'd16;
                endcase
            end

            // FAIL
            4'd5: begin
                case (digit_select)
                    3: digit_code = 5'd15; // F
                    2: digit_code = 5'd10; // A
                    1: digit_code = 5'd26; // I
                    0: digit_code = 5'd27; // L
                    default: digit_code = 5'd16;
                endcase
            end

            // DENIED
            4'd6: begin
                case (digit_select)
                    5: digit_code = 5'd13; // D
                    4: digit_code = 5'd21; // E
                    3: digit_code = 5'd22; // n
                    2: digit_code = 5'd26; // I
                    1: digit_code = 5'd21; // E
                    0: digit_code = 5'd13; // D
                    default: digit_code = 5'd16;
                endcase
            end

            // SAVED
            4'd7: begin
                case (digit_select)
                    4: digit_code = 5'd20; // S
                    3: digit_code = 5'd10; // A
                    2: digit_code = 5'd28; // U (approximation for V)
                    1: digit_code = 5'd21; // E
                    0: digit_code = 5'd13; // D
                    default: digit_code = 5'd16;
                endcase
            end

            default: digit_code = 5'd16;

        endcase
    end

    // Seven-segment decoder: active-low outputs
    always @(*) begin

        case (digit_code)

            0:  segment_pattern = 7'b1000000;
            1:  segment_pattern = 7'b1111001;
            2:  segment_pattern = 7'b0100100;
            3:  segment_pattern = 7'b0110000;
            4:  segment_pattern = 7'b0011001;
            5:  segment_pattern = 7'b0010010;
            6:  segment_pattern = 7'b0000010;
            7:  segment_pattern = 7'b1111000;
            8:  segment_pattern = 7'b0000000;
            9:  segment_pattern = 7'b0010000;
            10: segment_pattern = 7'b0001000; // A
            11: segment_pattern = 7'b0000011; // b
            12: segment_pattern = 7'b1000110; // C
            13: segment_pattern = 7'b0100001; // d
            14: segment_pattern = 7'b0000110; // E
            15: segment_pattern = 7'b0001110; // F

            16: segment_pattern = 7'b1111111; // Blank
            18: segment_pattern = 7'b0100001; // d
            19: segment_pattern = 7'b0001100; // P
            20: segment_pattern = 7'b0010010; // S
            21: segment_pattern = 7'b0000110; // E
            22: segment_pattern = 7'b0101011; // n
            23: segment_pattern = 7'b0000111; // t
            24: segment_pattern = 7'b0101111; // r
            26: segment_pattern = 7'b1111001; // I
            27: segment_pattern = 7'b1000111; // L
            28: segment_pattern = 7'b1000001; // U

            default: segment_pattern = 7'b1111111;

        endcase
    end

    // Multiplex the eight display digits
    always @(*) begin
        AN = 8'b11111111;
        AN[digit_select] = 1'b0;
        SEG = segment_pattern;
    end

endmodule