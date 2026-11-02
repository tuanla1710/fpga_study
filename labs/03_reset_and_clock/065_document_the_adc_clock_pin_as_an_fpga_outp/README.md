# 065 — Document the ADC clock pin as an FPGA output

## Description

This lab is in the reset and clock group. Synchronous reset and time ticks. The system clock is OSC pin 28, not ADC CLK.

Task: Document the ADC clock pin as an FPGA output. Habit to carry to the running company O-RU: Pin role.

The EP1C6 board is only for practice. The low performance is intentional. This lab does not replace the company's O-RU solution.

## Prepare

1. Power the board. Set the RUN/PROG switch to RUN. Plug the USB-Blaster into the JTAG header, not the AS header.
2. Open Quartus II 11.0 Web Edition. Device EP1C6Q240C8. The system clock is PIN_28. The SDC file contains `create_clock -name clk -period 20.000 [get_ports clk]` when the oscillator is 50 MHz.
3. Work in this directory so this lab's .sof does not mix with another lab.
4. The LCD pins are known. Assign them only if this lab uses the LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. Tie RW to 0. Do not assign lcd_on or lcd_blon.
5. This lab uses LEDs, the 7-segment display, buttons, switches, the ADC, or UART. Copy the pin numbers from this board's silkscreen into the pin table before writing the QSF. Do not use another board's schematic.

## Research

1. Read the lab title and write one sentence: what you should see on the board when this lab is done.
2. Habit to carry to the company O-RU: Pin role. Write which module in your RTL owns it.
3. List which registers clear to a safe value and which registers must not be cleared.
4. Calculate the number of 50 MHz cycles for this lab's time mark (1 us, 1 ms, 10 ms, or 50 ms).
5. Confirm that the clock pin in the QSF is PIN_28 and the SDC period is 20 ns.

## Implement

1. Required behavior: Document the ADC clock pin as an FPGA output.
2. Create a one-cycle enable for this lab's time mark. Do not divide the clock out to another pin.
3. Use a synchronous reset. During reset, the carrier is off and the counter returns to 0 if the lab requires a known value.
4. Do not connect ADC CLK to the FPGA clock port.
5. Leave unused pins as input tri-stated.
6. Add a short comment at the edit: why it changed, and what the reset value is.

## Test

1. Compile with Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` in this lab's project directory.
2. Read the error count first, then read setup slack. Negative slack from a 1 ns period means the SDC is missing.
3. Press reset or program again. The displayed value must return to the right default.
4. Read setup slack. Negative slack because TimeQuest assumes 1 ns means the SDC is missing. It is not yet a 50 MHz failure.
5. Program the .sof over JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<path to the .sof file>"`. Use JTAG mode. Do not program a .pof in this lab.
6. Power the board off, then on. The .sof image is gone. That is the correct result for an SRAM configuration.

## Expected results

- Compilation finishes with 0 errors.
- After reset, the state returns to the value written in the RTL. The tick happens at this lab's boundary, measured on the LCD or an LED.
- On the board or in the log, confirm only this: Document the ADC clock pin as an FPGA output.
- Removing power clears the .sof image. If this lab has not programmed a .pof, that is the expected result.

## What you learned

Change a time counter and still know which value reset leaves behind. An O-RU needs the same habit for the frame and the symbol. On lab 65, that habit is: Pin role.
