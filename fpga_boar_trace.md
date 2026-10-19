# FPGA board trace

Date: 2026-10-16

## Connection

No COM port is present. The board enumerates as an Altera USB-Blaster (JTAG), not as a UART.

| Item | Value |
| --- | --- |
| Friendly name | Altera USB-Blaster |
| Hardware ID | `USB\VID_09FB&PID_6001` |
| Revision | `REV_0600` |
| Serial | `8A0K7PIR` |
| Location | Port_#0006, Hub_#0001 |
| Class | USB |
| Status | OK |

`VID_09FB` / `PID_6001` is the classic Altera FPGA Download Cable (USB-Blaster). USB-Blaster II uses a different product ID (`6010` / `6810`). This VID/PID does not identify the FPGA or the board name.

## Driver

Quartus Prime Programmer 24.1std is installed at `C:\altera\24.1std\qprogrammer`.

The matching package is `drivers\usb-blaster\usbblstr.inf` (driver version `08/16/2017, 2.12.28`). It was published as `oem82.inf` and installed on `USB\VID_09FB&PID_6001\8A0K7PIR`.

Before that install, Windows reported problem code 28 (`CM_PROB_FAILED_INSTALL`): no driver was bound.

## Compiler

Quartus II Web Edition 11.0 is installed at `C:\altera\11.0`. The compiler is `C:\altera\11.0\quartus\bin\quartus_map.exe`. The installer used was `11.0_quartus_free_windows.exe` (11.0, not 11.0 SP1). This edition can compile Cyclone EP1C6. Quartus 24.1 Programmer cannot.

Set the Quartus project device to `EP1C6Q240C8`. The `N` suffix on the chip marking is the lead-free finish and is not a separate device name.

## JTAG scan

Earlier scans, while the cable was on the wrong header, reported:

```
jtagconfig.exe
1) USB-Blaster [USB-0]
  Unable to read device chain - JTAG chain broken
```

After the ribbon was seated on the JTAG header, with the board powered and the RUN switch set, the chain read:

```
jtagconfig.exe
1) USB-Blaster [USB-0]
  020820DD   EP1C6
```

| Item | Value |
| --- | --- |
| Cable | USB-Blaster [USB-0] |
| IDCODE | `020820DD` |
| Device | Altera Cyclone EP1C6 |
| Ordering code | `EP1C6Q240C8N` |
| Package | 240-pin PQFP (`Q240`) |
| Speed grade | C8 |
| Finish | lead-free (`N`) |

The 10-pin plug is keyed. It latches in one orientation only, so pin 1 is fixed by the housing. The board has two 10-pin sockets. The JTAG socket is the one that returns this IDCODE. The other socket is the usual AS header and does not expose the FPGA. User slide switches do not affect the scan. The RUN/PROG switch stays on RUN.

## LCD pins from the board silkscreen

Read on 2026-10-19. These are EP1C6Q240 package pin numbers, not the 16-pin LCD connector numbers. Assignments are in `lcd_hello.qsf`.

| Signal | Q240 pin |
| --- | --- |
| D0 | 223 |
| D1 | 222 |
| D2 | 221 |
| D3 | 220 |
| D4 | 219 |
| D5 | 218 |
| D6 | 217 |
| D7 | 216 |
| RS | 215 |
| RW | 214 |
| E | 213 |

Pins 213–223 are user I/O on bank 2. `lcd_on` and `lcd_blon` are not printed on this connector, so they are not FPGA pins.

The system oscillator is marked OSC and connects to Q240 pin 28, which is dedicated CLK0. It is assigned to `clk` in `lcd_hello.qsf`. This is not the ADC clock output.

## Manual compile and program

Confirmed by hand in Quartus II 11.0 Web Edition on 2026-10-19. Use this install, not Quartus 24.1. The board must be powered, the cable seated on the JTAG header, and the RUN/PROG switch set to RUN.

Compile:

1. Start Quartus II 11.0 Web Edition.
2. Choose **File → Open Project** and open `D:\DATA_LAB\fpga\lcd_hello.qpf`. **File → Open** on `lcd_hello.v` does not open the project, and **Processing → Start Compilation** stays disabled.
3. The title bar must read `lcd_hello - Quartus II`.
4. Choose **Processing → Start Compilation** (Ctrl+L).
5. Wait until Messages reports that full compilation succeeded. The programming file is `D:\DATA_LAB\fpga\lcd_hello.sof`.

Program, in **Tools → Programmer**:

1. Click **Hardware Setup**. Set **Currently selected hardware** to `USB-Blaster [USB-0]`, then click **Close**. If that line still says `No Hardware`, **Start** stays disabled.
2. Set **Mode** to **JTAG**.
3. If the chain has no file, click **Add File** and choose `lcd_hello.sof`. Do not add `lcd_hello.pof` in JTAG mode; a `.pof` leaves **Start** disabled.
4. Check **Program/Configure** on the `EP1C6Q240` row. The check mark has to remain. **Start** stays gray until this box is checked.
5. **Start** is the small button at the top left of the Programmer window, before **Stop** and **Hardware Setup**. It is not at the bottom of the window.
6. Click **Start**. Success is `100% (Successful)`.

The loaded image displays `O-RAN Team` on the first LCD line. It is stored in FPGA SRAM and is lost when board power is removed. Loading a `.pof` through the AS header is a separate step and is not part of this procedure.

## Still open

- A `.pof` has been generated but has not been written to the configuration memory, so the design does not survive power-off.
