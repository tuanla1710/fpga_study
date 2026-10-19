// Simulates lcd_hello with a 1 MHz clock so the microsecond delays are short.
// Checks that the ten character writes on the bus are "O-RAN Team".

`timescale 1ns / 1ps

module tb_lcd_hello;
    reg clk = 1'b0;
    wire lcd_on;
    wire lcd_blon;
    wire lcd_rw;
    wire lcd_rs;
    wire lcd_en;
    wire [7:0] lcd_data;

    lcd_hello #(.CLK_HZ(1_000_000)) dut (
        .clk(clk),
        .lcd_on(lcd_on),
        .lcd_blon(lcd_blon),
        .lcd_rw(lcd_rw),
        .lcd_rs(lcd_rs),
        .lcd_en(lcd_en),
        .lcd_data(lcd_data)
    );

    always #500 clk = ~clk;

    reg [7:0] got [0:9];
    integer n_chars;
    reg en_d;

    initial begin
        n_chars = 0;
        en_d = 1'b0;
        if (lcd_on !== 1'b1 || lcd_blon !== 1'b1 || lcd_rw !== 1'b0) begin
            $display("FAIL power/rw ties");
            $finish(1);
        end
    end

    always @(posedge clk) begin
        if (en_d && !lcd_en && lcd_rs) begin
            if (n_chars < 10) begin
                got[n_chars] = lcd_data;
            end
            n_chars = n_chars + 1;
        end
        en_d <= lcd_en;

        if (dut.state == 4) begin
            if (n_chars == 10 &&
                got[0] == 8'h4F &&
                got[1] == 8'h2D &&
                got[2] == 8'h52 &&
                got[3] == 8'h41 &&
                got[4] == 8'h4E &&
                got[5] == 8'h20 &&
                got[6] == 8'h54 &&
                got[7] == 8'h65 &&
                got[8] == 8'h61 &&
                got[9] == 8'h6D) begin
                $display("PASS O-RAN Team");
                $finish(0);
            end else begin
                $display("FAIL n=%0d", n_chars);
                $finish(1);
            end
        end
    end

    initial begin
        #200_000_000;
        $display("FAIL timeout");
        $finish(1);
    end
endmodule
