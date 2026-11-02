# 074 — Synchronize every switch bit on its own

## Description

This lab is in the synchronization and CDC group. Bring buttons and switches into one clock domain before the FSM uses them.

Task: Synchronize every switch bit on its own. Habit to carry to the running company O-RU: Bit sync.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. This lab uses LEDs, the 7-segment display, buttons, switches, the ADC, or UART. Copy the pin numbers from this board's silkscreen into the pin table before writing the QSF. Do not use another board's schematic.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Bit sync. Write which module in your RTL owns it.
3. Point out the asynchronous signal. Do not use the raw switch level in two always blocks.
4. Decide between 2 flip-flops and a req/ack handshake. Do not synchronize a multi-bit bus one bit at a time and then join the bits.
5. Estimate the bounce time if the lab has debounce.

## Implement

1. Required behavior: Synchronize every switch bit on its own.
2. Write a separate synchronizer block, and only then take the rising or falling edge.
3. Hold the multi-bit data until it is stable, as the lab title says.
4. The LED or LCD reads only the synchronized value.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Flip the switch quickly. The LCD must not show a code that sits between the two values.
4. Hold the button and release it. Each press counts as one event if the lab counts edges.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- A dirty input becomes one clean event in the 50 MHz clock. The LCD does not show a torn bus value.
- On the board or in the log, confirm only this: Synchronize every switch bit on its own.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

An input from outside the chip always passes through synchronization before it enters a control register. On lab 74, that habit is: Bit sync.
