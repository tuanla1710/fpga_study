# 475 — Compare the testbench result with the LCD before calling a lab done

## Description

This lab is in the testbench group. Check with a testbench before programming the board.

Task: Compare the testbench result with the LCD before calling a lab done. Habit to carry to the running company O-RU: Sim then board.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. If this lab does not use the LED, 7-segment, button, or switch pins, do not assign them yet.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Sim then board. Write which module in your RTL owns it.
3. Write the assert list: the condition that must pass and the condition that must fail.
4. Choose a testbench clock faster than the board clock if you only need to count events, and write down the ratio.
5. Name one accidental edit that this testbench must catch.

## Implement

1. Required behavior: Compare the testbench result with the LCD before calling a lab done.
2. Write a testbench that prints PASS only when every check passes.
3. Add exactly the check named in the lab title.
4. Do not wait for a real LCD in the testbench. Check the bytes or the registers.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Run the testbench with the simulator you have. If iverilog is not installed, walk each check on paper before programming the board.
4. Change one constant on purpose. The testbench must stop printing PASS.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- A correct run prints PASS. A run you break on purpose does not print PASS.
- On the board or in the log, confirm only this: Compare the testbench result with the LCD before calling a lab done.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

Before you program an O-RU image, an automatic check must still pass. On lab 475, that habit is: Sim then board.
