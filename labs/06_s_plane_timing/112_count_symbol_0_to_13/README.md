# 112 — Count symbol 0 to 13

## Description

This lab is in the S-plane timing group. Counters for a 10 ms frame, a 1 ms subframe, and symbols 0 through 13.

Task: Count symbol 0 to 13. Habit to carry to the running company O-RU: OFDM symbol.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. If this lab does not use the LED, 7-segment, button, or switch pins, do not assign them yet.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: OFDM symbol. Write which module in your RTL owns it.
3. Write the count order: sample, symbol, subframe, frame. Record the wrap point.
4. The symbol stops at 13 and the subframe stops at 9. Check the off-by-one before writing code.
5. Choose where the value appears. The LCD is enough if the 7-segment pins are not known yet.

## Implement

1. Required behavior: Count symbol 0 to 13.
2. Count with an enable. Do not create a new clock.
3. Implement the one time mark named in the lab title and display it.
4. If this lab fixes an off-by-one, add a testbench check or a comment that states the correct boundary.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Look at the wrap point. The symbol must not display 14. The subframe must not display 10.
4. If there is a single-step button, each press advances exactly one unit of this lab.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- The number on the LCD stays inside this lab's range and wraps at the right point. Two related counters advance together, with no one-tick offset.
- On the board or in the log, confirm only this: Count symbol 0 to 13.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

Changing O-RU timing means changing the wrap point and the strobe delay, then checking symbol 0 and the last symbol again. On lab 112, that habit is: OFDM symbol.
