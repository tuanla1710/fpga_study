// Top for the EP1C6Q240 board. LCD power and backlight are not FPGA pins
// on this board, so they stay inside lcd_hello and are not assigned.

module lcd_hello_ep1c6 (
    input  wire       clk,
    output wire       lcd_rs,
    output wire       lcd_rw,
    output wire       lcd_en,
    output wire [7:0] lcd_data
);

    wire lcd_on_unused;
    wire lcd_blon_unused;

    lcd_hello dut (
        .clk(clk),
        .lcd_on(lcd_on_unused),
        .lcd_blon(lcd_blon_unused),
        .lcd_rw(lcd_rw),
        .lcd_rs(lcd_rs),
        .lcd_en(lcd_en),
        .lcd_data(lcd_data)
    );

endmodule
