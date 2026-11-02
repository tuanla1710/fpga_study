# 305 — Add hysteresis around the threshold

## Description

This lab is in the gain and arithmetic group. Gain is a bit shift plus saturation. The EP1C6 has no hard multiplier.

Task: Add hysteresis around the threshold. Habit to carry to the running company O-RU: Hysteresis.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. If this lab does not use the LED, 7-segment, button, or switch pins, do not assign them yet.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Hysteresis. Write which module in your RTL owns it.
3. Calculate the output width after the shift or the add.
4. Choose the saturation rule for the largest positive code and the smallest negative code.
5. Decide whether gain changes immediately or waits for a symbol boundary.

## Implement

1. Required behavior: Add hysteresis around the threshold.
2. Write exactly the operation named in the lab title with a shift or an add. Do not call a multiplier IP.
3. The saturation flag turns on when the result is clamped.
4. Mute is gain 0 and drives a numeric 0.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Apply the largest code. The result sits at the ceiling and the saturation flag is on.
4. Apply a small code. A right shift must not become garbage because the sign extension is missing.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- The LCD shows the gain and the count of saturated samples. There is no wrap from the maximum back to a negative number.
- On the board or in the log, confirm only this: Add hysteresis around the threshold.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

When you change the gain width on an O-RU, change the saturation logic at the same time and test both ends of the range. On lab 305, that habit is: Hysteresis.
