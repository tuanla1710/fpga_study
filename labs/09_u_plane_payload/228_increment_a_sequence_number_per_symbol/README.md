# 228 — Increment a sequence number per symbol

## Description

This lab is in the U-plane payload group. IQ sample packets with a header: frame, symbol, sequence.

Task: Increment a sequence number per symbol. Habit to carry to the running company O-RU: Sequence id.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. If this lab does not use the LED, 7-segment, button, or switch pins, do not assign them yet.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Sequence id. Write which module in your RTL owns it.
3. Draw the byte order: header, then payload, and whether the length is fixed or variable.
4. State which event advances the sequence.
5. Decide that the payload must be 0 when the carrier is off or when there is no section.

## Implement

1. Required behavior: Increment a sequence number per symbol.
2. Add exactly the field or flag named in the lab title.
3. Keep the frame id and symbol id that already exist. Do not overwrite them when you add a new byte.
4. Show the last header on the LCD so you can inspect it.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Capture one packet. Compare length, sequence, and id with the timing counters.
4. Turn the carrier off. The payload must become 0 while the header still reports the correct frame.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- The packet has the fields this lab requires, the sequence does not jump when there is no new symbol, and mute really drives a numeric 0.
- On the board or in the log, confirm only this: Increment a sequence number per symbol.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

Change the U-plane header and still keep the frame id and sequence so the receiver can reassemble the data. On lab 228, that habit is: Sequence id.
