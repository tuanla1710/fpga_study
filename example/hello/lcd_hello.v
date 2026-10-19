// Problem
//   On the board character LCD, show "O-RAN Team" on the first line.
//   The controller is HD44780-compatible, 8-bit data, write only.
//
// Signals to assign in the Pin Planner (names used by DE1 / DE2 / DE2-115):
//   clk      50 MHz board clock
//   lcd_on   LCD power
//   lcd_blon backlight
//   lcd_rs   register select
//   lcd_rw   read/write, held low
//   lcd_en   enable
//   lcd_data data bus
//
// The FPGA device is still unknown (JTAG chain was broken), so this file
// has no pin location constraints.

module lcd_hello #(
    parameter integer CLK_HZ = 50_000_000
) (
    input  wire       clk,
    output wire       lcd_on,
    output wire       lcd_blon,
    output wire       lcd_rw,
    output reg        lcd_rs,
    output reg        lcd_en,
    output reg  [7:0] lcd_data
);

    localparam integer US = CLK_HZ / 1_000_000;

    localparam integer S_BOOT  = 0;
    localparam integer S_SETUP = 1;
    localparam integer S_PULSE = 2;
    localparam integer S_WAIT  = 3;
    localparam integer S_HOLD  = 4;

    // {rs, data[7:0], delay_us after the enable pulse}
    localparam integer N = 18;
    reg [24:0] rom [0:N-1];

    initial begin
        rom[ 0] = {1'b0, 8'h38, 16'd5000}; // function set, 8-bit
        rom[ 1] = {1'b0, 8'h38, 16'd200};
        rom[ 2] = {1'b0, 8'h38, 16'd200};
        rom[ 3] = {1'b0, 8'h38, 16'd50};   // 2 lines, 5x8 font
        rom[ 4] = {1'b0, 8'h0C, 16'd50};   // display on, cursor off
        rom[ 5] = {1'b0, 8'h01, 16'd2000}; // clear
        rom[ 6] = {1'b0, 8'h06, 16'd50};   // cursor moves right
        rom[ 7] = {1'b0, 8'h80, 16'd50};   // line 1, column 0
        rom[ 8] = {1'b1, 8'h4F, 16'd50};   // O
        rom[ 9] = {1'b1, 8'h2D, 16'd50};   // -
        rom[10] = {1'b1, 8'h52, 16'd50};   // R
        rom[11] = {1'b1, 8'h41, 16'd50};   // A
        rom[12] = {1'b1, 8'h4E, 16'd50};   // N
        rom[13] = {1'b1, 8'h20, 16'd50};   // space
        rom[14] = {1'b1, 8'h54, 16'd50};   // T
        rom[15] = {1'b1, 8'h65, 16'd50};   // e
        rom[16] = {1'b1, 8'h61, 16'd50};   // a
        rom[17] = {1'b1, 8'h6D, 16'd50};   // m
    end

    assign lcd_on   = 1'b1;
    assign lcd_blon = 1'b1;
    assign lcd_rw   = 1'b0;

    reg [2:0]  state = S_BOOT;
    reg [4:0]  step  = 5'd0;
    reg [31:0] wait_cycles = 32'd0;

    wire [24:0] cur = rom[step];
    wire        cur_rs   = cur[24];
    wire [7:0]  cur_data = cur[23:16];
    wire [15:0] cur_us   = cur[15:0];

    always @(posedge clk) begin
        case (state)
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

            S_SETUP: begin
                lcd_en   <= 1'b0;
                lcd_rs   <= cur_rs;
                lcd_data <= cur_data;
                if (wait_cycles >= US) begin
                    wait_cycles <= 32'd0;
                    state       <= S_PULSE;
                end else begin
                    wait_cycles <= wait_cycles + 32'd1;
                end
            end

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

            S_WAIT: begin
                lcd_en <= 1'b0;
                if (wait_cycles >= (US * cur_us)) begin
                    wait_cycles <= 32'd0;
                    if (step == N - 1) begin
                        state <= S_HOLD;
                    end else begin
                        step  <= step + 5'd1;
                        state <= S_SETUP;
                    end
                end else begin
                    wait_cycles <= wait_cycles + 32'd1;
                end
            end

            default: begin
                lcd_en <= 1'b0;
            end
        endcase
    end

endmodule
