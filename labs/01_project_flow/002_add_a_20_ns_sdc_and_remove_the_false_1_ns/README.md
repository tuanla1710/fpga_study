# 002 — Add a 20 ns SDC and remove the false 1 ns failure

## Description

This lab is in the project flow group. The compile and program flow, not an RU algorithm.

Task: Add a 20 ns SDC and remove the false 1 ns failure. Habit to carry to the running company O-RU: Timing constraint.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. If this lab does not use the LED, 7-segment, button, or switch pins, do not assign them yet.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Timing constraint. Write which module in your RTL owns it.
3. Read the Quartus 11 log and point out that the .sof is in the project directory, not in output_files.
4. Distinguish a .sof programmed over JTAG (lost when power is removed) from a .pof programmed over AS (not used in this lab).
5. Write down why the project must be opened from the .qpf file. Opening only a .v file leaves Start Compilation disabled.

## Implement

1. Required behavior: Add a 20 ns SDC and remove the false 1 ns failure.
2. Create a Quartus II 11.0 project, family Cyclone, device EP1C6Q240C8.
3. Set the top level to this lab's module. Do not leave the top pointing at an old experiment.
4. Do exactly the one thing named in the lab title. Do not change LCD pins if the lab does not require it.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Run Compile Flow. Stop at the first error, fix it, and compile again.
4. Find the .sof that was just produced. Record the checksum if the Programmer shows one.
5. If the lab asks you to program: Hardware is USB-Blaster [USB-0], mode is JTAG, the file is the .sof, Program/Configure is checked, then press Start.
6. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
7. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- Quartus reports 0 errors, this lab's .sof appears, and the Programmer reads EP1C6 IDCODE 020820DD while the cable is on the JTAG header.
- On the board or in the log, confirm only this: Add a 20 ns SDC and remove the false 1 ns failure.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

Know which image is in the chip, open the right project, and program again after a small edit. On lab 2, that habit is: Timing constraint.
