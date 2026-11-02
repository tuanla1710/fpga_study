# Test checklist for the board on hand

Board: Cyclone **EP1C6Q240C8N** (240-pin PQFP, speed grade C8, lead-free).  
JTAG IDCODE: `020820DD`.  
Cable: Altera USB-Blaster `USB\VID_09FB&PID_6001`, serial `8A0K7PIR`, port `USB-Blaster [USB-0]`.

This chip has about 5,980 logic elements, 20 M4K RAM blocks (92,160 bits), 2 PLLs, and about 185 I/O pins. It has no hard multiplier and no transceiver. Use it to learn digital circuits and the habit of programming an FPGA. It cannot run a real O-RAN RU (eCPRI, JESD204, low-PHY).

Mark `[x]` when an item is done.

## Already checked

- [x] Windows sees the USB-Blaster, the `usbblstr.inf` driver is bound, and the status is OK
- [x] There is no COM port. This board talks over JTAG, not a virtual UART
- [x] Board power is on, and the RUN/PROG switch is set to RUN
- [x] The 10-pin plug is keyed and fits in only one direction
- [x] On the correct JTAG row, `jtagconfig` reads `020820DD EP1C6`
- [x] The marking on the chip is `EP1C6Q240C8N`. In Quartus, select `EP1C6Q240C8`
- [x] LCD source exists: `lcd_hello.v`, testbench `tb_lcd_hello.v`
- [ ] Quartus II Web Edition 11.0 SP1 is not installed yet, so a `.sof` has not been compiled
- [ ] There is no LCD pin diagram yet, pins are not assigned, and nothing has been programmed

Command to check the cable again:

```text
C:\altera\24.1std\qprogrammer\bin64\jtagconfig.exe
```

Expected result:

```text
1) USB-Blaster [USB-0]
  020820DD   EP1C6
```

## Required before a test on the board

- [ ] Download and install [Quartus II Web Edition 11.0 SP1](https://www.altera.com/downloads/fpga-development-tools/quartus-ii-web-edition-design-software-version-11-0-b123-windows), file `11.0sp1_quartus_free_windows.exe`, into `C:\altera\11.0sp1`
- [ ] Open Quartus 11.0, create a project, device = `EP1C6Q240C8`
- [ ] Identify the clock pin on the board (usually a 50 MHz oscillator) and write the pin number into the project
- [ ] Photograph or copy the pin diagrams of the blocks you can see on the board: LCD, LEDs, buttons, switches

Quartus 24.1 at `C:\altera\24.1std\qprogrammer` is only for programming and for `jtagconfig`. That edition does not compile for the EP1C6.

## Look at the board and mark what is really there

Tick an item only when you can see the part or the printing on the board. If you have not seen it, leave it blank. Do not guess pins.

- [ ] Character LCD (1602 or an HD44780 equivalent)
- [ ] Single LEDs
- [ ] Slide switches
- [ ] Push buttons
- [ ] 7-segment LEDs
- [ ] Buzzer
- [ ] UART pins (TX/RX)
- [ ] VGA
- [ ] External RAM (SRAM/SDRAM)
- [ ] Expansion header

## What this board can do

Easiest first. A lab is done when the `.sof` is programmed, power is cycled, and the behavior matches the description.

### 1. Program one design

- [ ] Compile in Quartus 11.0 and produce `output_files\*.sof`
- [ ] Program with the Programmer, hardware = `USB-Blaster [USB-0]`, mode = JTAG
- [ ] Power off, then on: the design is gone. A `.sof` stays in the FPGA only while power is present
- [ ] Write this down: the `.sof` is the file used for the test, and a `.pof` is what gets programmed into configuration memory so the design survives power loss

### 2. Clock and an output pin

- [ ] An LED blinks at about 1 Hz from the board clock. That proves the clock and one output pin
- [ ] Change the blink rate by changing the counter, program again, and see the LED change speed

### 3. Switches and buttons

Do this only if the board has switches or buttons.

- [ ] The LED is on when the switch is on, and off when the switch is off
- [ ] The push button is debounced. One press counts as one

### 4. LCD shows `hello`

The code is already in `lcd_hello.v`. It cannot run until the pin numbers exist.

- [ ] Assign `clk`, `lcd_rs`, `lcd_rw`, `lcd_en`, `lcd_data[7:0]`, and `lcd_on` and `lcd_blon` if the board has them
- [ ] Compile and program
- [ ] Line 1 of the LCD shows `hello`
- [ ] Power cycle, program again, and the text is still there

### 5. State machine

- [ ] A few buttons or switches change the state: off, on, blinking
- [ ] The state appears on an LED or on the LCD

This is the same kind of control as a later configuration register, only smaller.

### 6. Count and display a number

Do this only if there is a 7-segment LED or an LCD.

- [ ] Count seconds and display the number
- [ ] A reset button returns the counter to 0

### 7. UART

Do this only if the board has TX/RX pins and a separate USB-UART. The current USB-Blaster does not create a COM port.

- [ ] The FPGA sends one line of text out of TX
- [ ] The computer receives it correctly on a different COM port, not the USB-Blaster

### 8. Simulate before programming

- [ ] Run `tb_lcd_hello.v` and see `PASS hello`
- [ ] Each new lab has a testbench that checks pass and fail before pins are attached

## O-RAN RU ideas these labs teach

Work on the EP1C6 to understand the job. It is not for transmitting.

| Lab on the board | Matching job in a later RU |
| --- | --- |
| Clock, 1 Hz counter | Frame, symbol, and slot ticks |
| Switch / button written into a register | M-plane writes gain, frequency, and carrier on or off |
| State machine | JESD, fronthaul, and low-PHY bring-up sequence |
| LCD / LED showing status | Watch status during bring-up |
| Text over UART | Debug log before eCPRI exists |
| Testbench | IQ vectors and datapath checks |

## Not done on the EP1C6

- [x] Excluded: eCPRI 10/25 GbE, and a 7.2x U-plane/C-plane split on the wire
- [x] Excluded: JESD204B/C to an RF transceiver
- [x] Excluded: low-PHY FFT/IFFT, DUC/DDC, CFR, wideband DPD
- [x] Excluded: PTP/SyncE

Those items need an FPGA with transceivers and DSP. Keep them off this board's checklist.
