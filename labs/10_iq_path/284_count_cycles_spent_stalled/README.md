# 284 — Count cycles spent stalled

## Description

This lab is in the IQ path group. The sample path has valid, stall, and pipeline delay.

Task: Count cycles spent stalled. Habit to carry to the running company O-RU: Stall count.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. This lab uses LEDs, the 7-segment display, buttons, switches, the ADC, or UART. Copy the pin numbers from this board's silkscreen into the pin table before writing the QSF. Do not use another board's schematic.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Stall count. Write which module in your RTL owns it.
3. Count the cycles the new data path adds.
4. List the signals that must be delayed with the sample: valid, strobe, last, antenna.
5. State when the old sample may be held while valid is low.

## Implement

1. Required behavior: Count cycles spent stalled.
2. Change exactly the I or Q transform named in the lab title.
3. If you add one pipeline stage, delay valid by that same number of cycles.
4. Saturate when you cut bits. Do not let an overflow pass silently.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Compare the input sample and the output sample on the LCD at the same strobe.
4. Create one bubble. A sample must not be duplicated or dropped.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- I and Q follow this lab's rule, and the strobe still marks the right sample after the added delay.
- On the board or in the log, confirm only this: Count cycles spent stalled.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

When you add a pipeline stage on an O-RU datapath, every signal that travels with the sample must be delayed by the same amount. On lab 284, that habit is: Stall count.
