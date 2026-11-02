# 440 — Print one status line per frame

## Description

This lab is in the UART-for-debug group. The RS-232 port is a slow log channel in place of a trace on a real RU.

Task: Print one status line per frame. Habit to carry to the running company O-RU: Periodic log.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. This lab uses LEDs, the 7-segment display, buttons, switches, the ADC, or UART. Copy the pin numbers from this board's silkscreen into the pin table before writing the QSF. Do not use another board's schematic.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Periodic log. Write which module in your RTL owns it.
3. Copy the TX and RX pins from the silkscreen. Record the baud and the divider error from 50 MHz.
4. Fix the frame as 8N1.
5. Define the command or packet this lab sends and receives.

## Implement

1. Required behavior: Print one status line per frame.
2. Write the transmitter or receiver this lab asks for. Do not use a UART pin that is not in the table.
3. Count framing errors and overruns instead of ignoring them.
4. An unknown command must get an error reply and must not change the gain.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Connect the board UART to a PC COM port at the correct baud.
4. Send this lab's correct sentence and one wrong sentence. Only the correct sentence changes the state.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- The correct byte shows on the LCD or comes back to the PC. The error counter increments when you deliberately use the wrong baud or the wrong frame.
- On the board or in the log, confirm only this: Print one status line per frame.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

A slow log is still enough to read registers and count errors before a high-speed trace path exists. On lab 440, that habit is: Periodic log.
