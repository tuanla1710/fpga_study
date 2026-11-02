# 153 — Copy edit registers to active on Apply

## Description

This lab is in the M-plane registers group. Register map: the copy being edited and the copy that is running.

Task: Copy edit registers to active on Apply. Habit to carry to the running company O-RU: Candidate config.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. If this lab does not use the LED, 7-segment, button, or switch pins, do not assign them yet.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Candidate config. Write which module in your RTL owns it.
3. Draw the address, the bits, read or write permission, and the reset value.
4. Point out the reserved bits that must read as 0.
5. Decide which action copies the edit copy into the active copy.

## Implement

1. Required behavior: Copy edit registers to active on Apply.
2. Add exactly the one register or rule named in the lab title.
3. Do not change an old address unless the lab title says to change the address.
4. The LCD shows both the edit value and the active value when the lab is about the shadow copy.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Write a legal value, Apply, and see the active copy change.
4. Write an out-of-range value, or write a read-only entry. The active copy must stay intact.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- Exactly one map entry changes, as the lab title says. Reset returns the documented default. Reserved bits stay 0.
- On the board or in the log, confirm only this: Copy edit registers to active on Apply.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

Changing an O-RU register map means the address, the default, the range check, and the split between the draft configuration and the running configuration. On lab 153, that habit is: Candidate config.
