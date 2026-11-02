# 390 — Blank the digits during reset

## Description

This lab is in the LED, button, and 7-segment group. Lamps, buttons, switches, and the 7-segment LEDs. Pins must come from this board's silkscreen.

Task: Blank the digits during reset. Habit to carry to the running company O-RU: Dark reset.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. This lab uses LEDs, the 7-segment display, buttons, switches, the ADC, or UART. Copy the pin numbers from this board's silkscreen into the pin table before writing the QSF. Do not use another board's schematic.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Dark reset. Write which module in your RTL owns it.
3. Copy the LED, 7-segment, button, and switch pin numbers from the silkscreen into a table in this lab's directory before editing the QSF.
4. Record the polarity: active high or active low. Measure it by turning one lamp on in the self-test lab.
5. Do not open another board's schematic to fill in pin numbers.

## Implement

1. Required behavior: Blank the digits during reset.
2. Assign only the pins you copied. A pin that is not in the table must not be used yet.
3. Implement exactly the one behavior named in the lab title.
4. Scan the 7-segment display with a blank interval between digits so ghosts do not appear.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Match each LED and each digit against the pin table.
4. Press one button. Only this lab's one function happens.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- The lamps and the 7-segment display show this lab's value. No pin was assigned from memory or from another board.
- On the board or in the log, confirm only this: Blank the digits during reset.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

Assigning panel I/O is part of editing an FPGA. A wrong pin can drive something you did not intend. On lab 390, that habit is: Dark reset.
