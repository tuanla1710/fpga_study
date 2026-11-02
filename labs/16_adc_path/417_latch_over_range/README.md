# 417 — Latch over-range

## Description

This lab is in the ADC path group. Read the ADC0809 to watch the input level. The clock sent to the ADC is not the FPGA clock.

Task: Latch over-range. Habit to carry to the running company O-RU: High alarm.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. This lab uses LEDs, the 7-segment display, buttons, switches, the ADC, or UART. Copy the pin numbers from this board's silkscreen into the pin table before writing the QSF. Do not use another board's schematic.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: High alarm. Write which module in your RTL owns it.
3. Copy the ADC data, start, EOC, address, and clock pins from the silkscreen.
4. Confirm that the system clock is still pin 28.
5. Choose a start-convert period slower than the ADC conversion time.

## Implement

1. Required behavior: Latch over-range.
2. Generate the clock and start pulses for the ADC from the FPGA.
3. Capture the sample into a register only when the conversion is finished.
4. Add exactly this lab's statistic: min, max, average, or alarm.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Change the input voltage or signal. The code on the LCD moves in the right direction.
4. Hold the freeze button if the lab has one. The code must stay still even if the input changes.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- The ADC code is stable, the alarm matches the threshold you chose, and the FPGA clock still comes from pin 28.
- On the board or in the log, confirm only this: Latch over-range.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

A path that watches the input helps isolate a fault before you edit the datapath. On lab 417, that habit is: High alarm.
