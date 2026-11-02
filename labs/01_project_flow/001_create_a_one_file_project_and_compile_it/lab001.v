// Lab 001 top. One clock on pin 28. The LCD shows the lesson result and scrolls it left forever.
module lab001 (
    // System clock from pin 28. The SDC period is 20 ns, so this is 50 MHz.
    input  wire       clk,
    // HD44780 register select. 0 is a command, 1 is a character.
    output reg        lcd_rs,
    // Write only. Held at 0 so the display never drives the data bus.
    output wire       lcd_rw,
    // Enable pulse. The display latches RS and the data bus on its falling edge.
    output reg        lcd_en,
    // Data bus D0-D7, package pins 223-216.
    output reg  [7:0] lcd_data
);

    // Tie RW low in this one place. Power and backlight are not FPGA pins on this board.
    assign lcd_rw = 1'b0;

    localparam integer US = 50; // cycles in 1 us at 50 MHz
    localparam integer MSG_LEN = 56; // 16 blank columns, then the result, so text enters from the right
    localparam integer GAP_CYCLES = 15000000; // 300 ms between shifts

    localparam [1:0] S_BOOT  = 2'd0;
    localparam [1:0] S_SETUP = 2'd1;
    localparam [1:0] S_PULSE = 2'd2;
    localparam [1:0] S_WAIT  = 2'd3;

    // Init ROM entry is {rs, data, delay in microseconds after the enable pulse}.
    reg [24:0] init_rom [0:6];
    // Message bytes. The first 16 are spaces, so the result starts off the right edge.
    reg [7:0] msg [0:MSG_LEN-1];

    integer i;
    initial begin
        init_rom[0] = {1'b0, 8'h38, 16'd5000}; // function set, 8-bit
        init_rom[1] = {1'b0, 8'h38, 16'd200};
        init_rom[2] = {1'b0, 8'h38, 16'd200};
        init_rom[3] = {1'b0, 8'h38, 16'd50};   // 2 lines, 5x8 font
        init_rom[4] = {1'b0, 8'h0C, 16'd50};   // display on, cursor off
        init_rom[5] = {1'b0, 8'h01, 16'd2000}; // clear
        init_rom[6] = {1'b0, 8'h06, 16'd50};   // cursor moves right, no display shift
        for (i = 0; i < 16; i = i + 1)
            msg[i] = 8'h20;
        msg[16] = "E"; msg[17] = "R"; msg[18] = "R"; msg[19] = " ";
        msg[20] = "0"; msg[21] = " "; msg[22] = " ";
        msg[23] = "S"; msg[24] = "L"; msg[25] = "A"; msg[26] = "C"; msg[27] = "K"; msg[28] = " ";
        msg[29] = "1"; msg[30] = "5"; msg[31] = "."; msg[32] = "4"; msg[33] = "3"; msg[34] = "0";
        msg[35] = "n"; msg[36] = "s"; msg[37] = " "; msg[38] = " ";
        msg[39] = "S"; msg[40] = "O"; msg[41] = "F"; msg[42] = " ";
        msg[43] = "0"; msg[44] = "x"; msg[45] = "0"; msg[46] = "0"; msg[47] = "0";
        msg[48] = "9"; msg[49] = "0"; msg[50] = "3"; msg[51] = "2"; msg[52] = "A";
        msg[53] = " "; msg[54] = " "; msg[55] = " ";
    end

    reg [1:0]  state = S_BOOT;
    reg [31:0] wait_cycles = 32'd0;
    reg [2:0]  init_step = 3'd0;
    reg        scrolling = 1'b0;
    reg [4:0]  frame_pos = 5'd0; // 0 is set-address, 1..16 are the visible characters
    reg [5:0]  offset = 6'd0;    // first visible column. Increases to shift the text left.

    wire [24:0] init_cmd = init_rom[init_step];
    wire [6:0]  raw_index = offset + (frame_pos - 5'd1);
    wire [6:0]  msg_index = (raw_index >= MSG_LEN) ? (raw_index - MSG_LEN) : raw_index;

    // Command presented to the LCD for the current step.
    wire        cmd_rs   = scrolling ? (frame_pos != 5'd0) : init_cmd[24];
    wire [7:0]  cmd_data = scrolling ? ((frame_pos == 5'd0) ? 8'h80 : msg[msg_index]) : init_cmd[23:16];
    wire [15:0] cmd_us   = scrolling ? 16'd50 : init_cmd[15:0];

    // Drive one HD44780 write, then choose the next write. The scroll repeats with no end state.
    always @(posedge clk) begin
        case (state)
            // Power-on wait. The display ignores commands for about 40 ms.
            S_BOOT: begin
                lcd_en   <= 1'b0;
                lcd_rs   <= 1'b0;
                lcd_data <= 8'h00;
                if (wait_cycles >= (US * 32'd50000)) begin
                    wait_cycles <= 32'd0;
                    state       <= S_SETUP;
                end else begin
                    wait_cycles <= wait_cycles + 32'd1;
                end
            end

            // Place RS and the data bus, with enable still low.
            S_SETUP: begin
                lcd_en   <= 1'b0;
                lcd_rs   <= cmd_rs;
                lcd_data <= cmd_data;
                if (wait_cycles >= US) begin
                    wait_cycles <= 32'd0;
                    state       <= S_PULSE;
                end else begin
                    wait_cycles <= wait_cycles + 32'd1;
                end
            end

            // Raise enable for 1 us. The controller latches on the fall.
            S_PULSE: begin
                lcd_en <= 1'b1;
                if (wait_cycles >= US) begin
                    wait_cycles <= 32'd0;
                    lcd_en      <= 1'b0;
                    state       <= S_WAIT;
                end else begin
                    wait_cycles <= wait_cycles + 32'd1;
                end
            end

            // Hold the bus steady, then take the next step. A finished line pauses, then shifts left.
            S_WAIT: begin
                lcd_en <= 1'b0;
                if (scrolling && frame_pos == 5'd16) begin
                    if (wait_cycles >= GAP_CYCLES) begin
                        wait_cycles <= 32'd0;
                        frame_pos   <= 5'd0;
                        offset      <= (offset == MSG_LEN - 1) ? 6'd0 : offset + 6'd1;
                        state       <= S_SETUP;
                    end else begin
                        wait_cycles <= wait_cycles + 32'd1;
                    end
                end else if (wait_cycles >= (US * cmd_us)) begin
                    wait_cycles <= 32'd0;
                    if (!scrolling) begin
                        if (init_step == 3'd6) begin
                            scrolling <= 1'b1;
                            frame_pos <= 5'd0;
                        end else begin
                            init_step <= init_step + 3'd1;
                        end
                    end else begin
                        frame_pos <= frame_pos + 5'd1;
                    end
                    state <= S_SETUP;
                end else begin
                    wait_cycles <= wait_cycles + 32'd1;
                end
            end

            default: begin
                lcd_en <= 1'b0;
                state  <= S_BOOT;
            end
        endcase
    end

endmodule
