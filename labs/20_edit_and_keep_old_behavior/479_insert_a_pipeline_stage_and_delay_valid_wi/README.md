# 479 — Insert a pipeline stage and delay valid with it

## Description

This lab is in the edit-and-keep-old-behavior group. Change one place in a running block and show that the old part still works.

Task: Insert a pipeline stage and delay valid with it. Habit to carry to the running company O-RU: Pipe edit.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. If this lab does not use the LED, 7-segment, button, or switch pins, do not assign them yet.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Pipe edit. Write which module in your RTL owns it.
3. Write one sentence: which old behavior must not change.
4. Mark the exact file and the exact signal you will change.
5. Choose the version nibble that will increment after this lab.

## Implement

1. Required behavior: Insert a pipeline stage and delay valid with it.
2. Change exactly the one thing named in the lab title.
3. Do not touch unrelated pins. Do not change the map unless the lab says to change the map.
4. Increment the version if the lab asks you to recognize the new image.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Read the diff. Only this lab's lines changed.
4. Compile again, read the slack, and program over JTAG.
5. Check the new behavior and one old behavior you wrote down in the research step.
6. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
7. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- This lab's new behavior appears. The old behavior you chose still holds. The new image is recognizable by its version or by the text on the LCD.
- On the board or in the log, confirm only this: Insert a pipeline stage and delay valid with it.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

Maintaining an O-RU is a loop: change one place, rebuild, program again, and check both the new part and the part that was already running. On lab 479, that habit is: Pipe edit.
