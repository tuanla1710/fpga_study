# 045 — Keep one clock and one reset port on every module

## Description

This lab is in the Verilog habits group. Write RTL so the next person can edit one module without creating a latch or a wrong width.

Task: Keep one clock and one reset port on every module. Habit to carry to the running company O-RU: Common ports.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. If this lab does not use the LED, 7-segment, button, or switch pins, do not assign them yet.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Common ports. Write which module in your RTL owns it.
3. Mark the module that will own this lab's behavior. Record its clock and reset ports.
4. List the constants that are still bare numbers. Choose a localparam name for each one.
5. Find a case or if branch that does not assign every signal. That is where a latch appears.

## Implement

1. Required behavior: Keep one clock and one reset port on every module.
2. Write exactly the one rule named in the lab title. Keep the rules that earlier labs already got right.
3. Use nonblocking assignments in clocked always blocks.
4. Add one line at the top of the file: what this module owns.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Compile and read warnings about latches, widths, or an unintended RAM inference.
4. Compare the RTL with the note at the top of the file. Both must use the same state names and the same widths.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- The RTL shows this lab's rule, compilation has 0 errors, and each remaining warning has one sentence explaining why it is accepted.
- On the board or in the log, confirm only this: Keep one clock and one reset port on every module.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

A small change leaves a diff that is easy to read. That is how to edit O-RU code so someone else can still follow it. On lab 45, that habit is: Common ports.
