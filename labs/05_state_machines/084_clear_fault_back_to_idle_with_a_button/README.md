# 084 — Clear FAULT back to IDLE with a button

## Description

This lab is in the state machine group. An IDLE, CONFIG, RUN, FAULT FSM, and how to add a state without breaking the old edges.

Task: Clear FAULT back to IDLE with a button. Habit to carry to the running company O-RU: Fault exit.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. This lab uses LEDs, the 7-segment display, buttons, switches, the ADC, or UART. Copy the pin numbers from this board's silkscreen into the pin table before writing the QSF. Do not use another board's schematic.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Fault exit. Write which module in your RTL owns it.
3. Write the state list and the edges that are allowed. An unknown state must return to IDLE.
4. Record the reset value of the state.
5. Point out which output is Moore and which output is a one-cycle pulse.

## Implement

1. Required behavior: Clear FAULT back to IDLE with a button.
2. Name the states with localparam, matching the list you wrote.
3. Add exactly this lab's state or condition. Do not renumber the old states.
4. The LCD shows the state name so you can see it while editing.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Walk every legal edge and see the LCD change to the right name.
4. Issue one command in the wrong state. The FSM must stay put or enter FAULT. It must not jump at random.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- Every state named in the lab title is visible on the LCD. An edge that is not on the list does not change the state.
- On the board or in the log, confirm only this: Clear FAULT back to IDLE with a button.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

Add an O-RU state by name, and leave the transitions that are already running unchanged. On lab 84, that habit is: Fault exit.
