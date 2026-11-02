# 465 — Expose the alarms as bits in one register

## Description

This lab is in the alarm and fault group. Latch a fault, clear it only under the right condition, and turn the carrier off on a fault.

Task: Expose the alarms as bits in one register. Habit to carry to the running company O-RU: Alarm word.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. If this lab does not use the LED, 7-segment, button, or switch pins, do not assign them yet.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Alarm word. Write which module in your RTL owns it.
3. Write the alarm code, the severity, and how it clears: immediately, or only after the cause is gone.
4. Decide whether the carrier is turned off.
5. Point out which bits are in the alarm register.

## Implement

1. Required behavior: Expose the alarms as bits in one register.
2. Latch exactly the fault this lab names.
3. The clear button must not clear the fault if the lab requires the cause to be gone first.
4. FAULT turns the carrier off if the lab says protect.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Cause the fault. The LCD shows the code, an LED reports it, and the carrier turns off if the lab requires that.
4. Clear it. The fault disappears only by the rule you wrote.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- One cause produces one stable code. Clearing it the wrong way must not return the machine to RUN while the fault remains.
- On the board or in the log, confirm only this: Expose the alarms as bits in one register.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

Changing O-RU fault handling means changing both the entry into the fault and the moment it is allowed to run again. On lab 465, that habit is: Alarm word.
