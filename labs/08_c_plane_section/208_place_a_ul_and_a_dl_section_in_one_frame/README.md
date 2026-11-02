# 208 — Place a UL and a DL section in one frame

## Description

This lab is in the C-plane section group. Section commands: accept, check, queue, and apply on the right symbol.

Task: Place a UL and a DL section in one frame. Habit to carry to the running company O-RU: Two directions.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. If this lab does not use the LED, 7-segment, button, or switch pins, do not assign them yet.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Two directions. Write which module in your RTL owns it.
3. List the fields: section id, start symbol, symbol count, beam id, direction, PRB, RE mask.
4. Write the reject condition. start + length must not pass symbol 13.
5. Decide whether a full FIFO drops the new command or the old one.

## Implement

1. Required behavior: Place a UL and a DL section in one frame.
2. Implement exactly the one check or opcode named in the lab title.
3. A rejected command must not modify the section that is running.
4. The LCD shows the reject reason or the queue depth.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Send one legal command. The active section changes the right field.
4. Send one illegal command, as the lab title describes. The reject counter increments, and the old symbol schedule stays put.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- A legal command is accepted. An illegal command is counted and does not shift the symbol that is already running.
- On the board or in the log, confirm only this: Place a UL and a DL section in one frame.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

Change the O-RU command parser without breaking the schedule of the path that is already transmitting. On lab 208, that habit is: Two directions.
