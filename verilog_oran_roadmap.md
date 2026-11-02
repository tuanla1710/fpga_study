# Verilog path from the basics to O-RAN depth

Study on the Cyclone EP1C6Q240C8 board so you can later develop and fix an O-RU FPGA. This chip does not run eCPRI, JESD204, an FFT, or DPD. Each level below practices one Verilog layer you will meet again in the O-RU solution that is running at the company. The LUT, clock, RAM, and I/O architecture is in `fpga_roadmap.md`. The lab list and working directories are in `docs/ru_board_projects.md` and `labs/`.

The example that has already been programmed is `example/hello/`: the LCD shows `O-RAN Team`. The clock is pin 28. LCD D0–D7 = 223–216, RS 215, RW 214, E 213. Assign LEDs, the 7-segment display, buttons, switches, the ADC, and UART only after copying the pin numbers from this board's silkscreen.

Each level has a done criterion. Do not move to the next level until that criterion is met. You do not need to finish all 540 labs. Do the labs listed for that level until the criterion is met.

## An O-RU seen from the Verilog side

The O-RU FPGA holds the work that has to be right to the microsecond. Software holds the configuration and the supervision.

| Plane | Who does it on a real RU | Matching Verilog work | Practice level on this board |
| --- | --- | --- | --- |
| S-plane | Time sync with the O-DU | Frame, subframe, symbol, offset, and holdover counters | 3 |
| M-plane | Software writes registers | Address map, draft copy and running copy, defaults, range | 3 |
| C-plane | Section commands in real time | Command parser, checks, queue, symbol schedule | 4 |
| U-plane | IQ samples per symbol | Header, sequence, mute, pipeline delay | 4 |
| Low-PHY and DFE | FFT, CP, NCO, filter, gain, CFR, DPD | Bit shifts, saturation, phase accumulator, average, decimate | 4, then keep reading at level 6 |
| Fronthaul | eCPRI on a 10/25 GbE transceiver | Byte frame, error flags, UART loopback | 5 and 6 |

The split you usually meet is 7.2x: the O-RU does the FFT/iFFT, adds and removes the cyclic prefix, and sends frequency-domain IQ over the fronthaul. The O-DU keeps the higher PHY and the scheduler. The category, and where beamforming sits, depend on the company solution. When you open the code, match it to this table first. Do not guess the category yet.

## Level 1 — Basic Verilog

The goal is to write one module, compile it with Quartus 11, program a `.sof` over JTAG, and know which image is in the chip.

Verilog to know:

- `module`, `input` and `output` ports, `wire` and `reg`.
- `assign` is combinational logic. `always @(posedge clk)` is a flip-flop. Inside a clocked block, use `<=`.
- A `parameter` is overridden by the parent module. A `localparam` is used only inside the module.
- A parent module calls a child module. The top `lcd_hello_ep1c6` exposes only pins that really exist on the board.
- An `if` inside a clocked block is a multiplexer in front of a flip-flop. It is not a program branch that runs in sequence.

Work on the board: labs 1–45 and the `example/hello` example. Change one character on the LCD, compile again, program again, and see the `.sof` checksum change. Open the project from the `.qpf` file. Add a 20 ns SDC period for pin 28. Leave unused pins as input tri-stated.

O-RAN at this level is one sentence: the company product is also an image programmed into an FPGA. It has a version, and it can be lost if you only program SRAM.

Done when you can do four things without looking back at an old log: open the right project, compile with 0 errors, program over JTAG and see IDCODE `020820DD`, and explain why the text on the LCD disappears when power is removed.

## Level 2 — Synchronous circuits

The goal is that every register uses one clock, reset returns a known value, and a button press does not make the FSM jump twice.

Verilog to know:

- Synchronous reset. List which registers are cleared.
- A one-cycle enable for the 1 us, 1 ms, and 10 ms marks. Do not make a new clock by dividing one out to a pin.
- A counter whose width matches its maximum count.
- An FSM with named states, a `default` branch, and a list of allowed edges.
- Two flip-flops to synchronize a switch. Debounce for about 20 ms. Do not synchronize a multi-bit bus one bit at a time and then join the bits.

Work on the board: labs 46–105. The LCD shows `IDLE`, `CONFIG`, `RUN`, `FAULT`. The clear button and the fault switch pass through the synchronizer. The clock is still pin 28. ADC CLK is not the system clock.

O-RAN at this level: the RU operating state is an FSM. The carrier must not turn on while the machine is in `FAULT` or while it is locked.

Done when you issue one command in the wrong state and the LCD shows that the machine did not jump at random. Setup slack is positive with a 20 ns SDC. Negative slack from a 1 ns period means the SDC is missing.

## Level 3 — Time and registers

The goal is to count the radio schedule correctly and to keep the draft configuration separate from the configuration that is running. This is the entrance to the S-plane and the M-plane.

Verilog to know:

- Several nested counters driven by enables: sample, symbol, subframe, frame.
- Wrap points written as constants: the symbol stops at 13, the subframe stops at 9, and the frame counter is wider than what the LCD can show.
- Two register copies. An Apply button is what copies the edit copy into the active copy.
- Address, reserved bits that read as 0, the reset value, and a rejected write that is out of range.

Work on the board: labs 106–185. The LCD shows the frame, subframe, and symbol at the same time. One switch loads a frame offset, and the LCD reports early, on time, or late. Gain and carrier change only after Apply. Reset restores the defaults.

O-RAN at this level:

- 10 ms is one radio frame. 1 ms is one subframe. A subframe contains OFDM symbols. Symbol 0 can be longer if you are imitating an extended cyclic prefix.
- An external pulse, a button on this board, plays the role of 1 pps. When the button stops, the counter keeps running. That is holdover as an exercise. It is not PTP.
- The active registers are what the sample path is allowed to read. The edit copy is what software is still writing.

Done when you can look at the LCD and say which frame and which symbol are displayed, and one gain write that has not been Applied has not changed the sample path.

## Level 4 — Commands, IQ samples, and arithmetic

The goal is that one legal command changes the sample path on the right symbol, one illegal command does not break the schedule, and one gain operation does not wrap around.

Verilog to know:

- One command word made of fields: section id, start symbol, symbol count, beam id, UL or DL direction, PRB count, RE mask.
- A shallow FIFO for a few commands. Full flag, empty flag, and a counter of rejected commands.
- Samples have `valid`. If you add one pipeline stage, `valid` is delayed by that same number of cycles.
- Signed numbers, left and right shifts, saturation at both ends of the range. The EP1C6 has no hard multiplier, so gain is a bit shift.
- A phase accumulator for an NCO. Record the bit width after accumulation. Keep a bypass path so the original sample remains.

Work on the board: labs 186–335. The LCD or UART shows the section that is running and the sample-packet header: frame, symbol, sequence. When the carrier is off, the payload goes to 0. The beam id and section id in the header match the command that was just accepted. A large code, after a right shift, clamps at the ceiling and turns the saturation flag on.

O-RAN at this level is a small copy of the C-plane and the U-plane:

- The C-plane says which resource region is used in the frame.
- The U-plane carries the IQ of that region.
- `startSymbolId + numSymbol` must not pass the last symbol.
- The sequence makes a lost packet or a repeated packet visible.
- Gain and the NCO are the two smallest DFE blocks. On a real RU they stand before or after the FFT, but the Verilog is written the same way: enter on `valid`, leave with a fixed delay, and keep a bypass.

Done when you run one continuous experiment on the board: load one legal section and see samples run in those symbols, send one section longer than 14 symbols and see it rejected, and the path that is running does not lose its frame id.

## Level 5 — Join the board, and edit without breaking the old part

The goal is that a design of many blocks still has one source of truth, and one edit changes only the thing that needed to change.

Verilog to know:

- RAM and FIFOs inferred from a clocked array. Know when Quartus uses an M4K.
- Ping-pong: swap the buffer pointer on a symbol boundary. The reader sees only the buffer that has settled.
- A testbench that prints `PASS` by itself. An accidental constant edit must make the testbench stop printing `PASS`.
- An alarm as a latch. Clear it only after the cause is gone, if that is the lab's rule. A fault turns the carrier off.
- UART 8N1 is the slow log channel: count framing errors, and do not let an unknown command change the gain.

Work on the board: labs 336–540, after the silkscreen pin table exists for the LEDs, the 7-segment display, buttons, and switches. One bitstream shows the same number on the 7-segment display, the same bit on an LED, and the same text on the LCD. Labs 476–500 are real edits: widen gain by one bit, add one state, add one pipeline stage, then show that the old behavior is still correct.

O-RAN at this level is development discipline. The company solution is already running. A register-map change, an extra pipeline cycle, or a gain-width change must travel with a check of the part that is on the air.

Done when you have a small diff, compile again, program again, and can point out the new behavior together with one old behavior that did not change. The panel must not contradict itself.

## Level 6 — Depth for developing O-RAN

This level is done on paper, in a testbench, and in the company code. The EP1C6 cannot synthesize the blocks below. For each topic, reuse a module you wrote at levels 3–5 as the small picture, then read the matching block in the solution that is running.

### Fronthaul and eCPRI

On a real RU, the U-plane and C-plane travel in high-speed Ethernet through a transceiver. The 8-byte UART lab is the same job at low speed: marker, length, sequence, and a count of frame errors.

When you read the company code, find three things first: the block that starts and ends a packet, the place that attaches `frameId` to `symbolId`, and the FIFO between the transceiver clock and the baseband clock. Do not edit the MAC address or the PCS table yet.

### A real S-plane

PTP and SyncE lock the RU's time to the O-DU. The 1 pps button lab and the holdover lab only practice how the counter reacts when the sync source is gone. In the company code, find the offset register, the loss-of-sync flag, and the place where the air-frame counter is reloaded. Editing the counter before you have read those flags will shift the symbols.

### A C-plane with the full field set

The board copy has section id, symbol, beam, direction, PRB, and RE mask. The spec copy also has the section type, the number of consecutive symbols, and extensions. The Verilog does not change: one FSM that receives words, one check table, one FIFO, one schedule that applies the command on the right symbol. Practice further by widening each field in the testbench. You do not need to program the board for that.

### U-plane and sample compression

IQ on the wire is usually narrower than IQ inside the chip. The bit-shift and saturation labs are the simple form of block floating point and bit cutting. When you enter the company code, find the width before compression, the width on the fronthaul, and the place that reports overflow. If you change one width, change the saturation block as well and test both ends of the range.

### Low-PHY

FFT, iFFT, CP insertion, and PRACH need memory and hard multipliers that the EP1C6 does not have. Reading an FFT in RTL is still the habit you practiced: enter on a symbol, leave after a fixed number of cycles, `valid` travels with the sample, and symbol 0 has a different length if the CP is different. Draw that block's latency before you change a coefficient or the sample order.

### DFE

The NCO on the board is a phase accumulator. The filter on the board is an add and a shift. On a real RU, the mixer, CFR, and DPD use DSP blocks. Find the bypass port and the gain port before you change a coefficient. A new block must have a path around it, as in the bypass lab at level 4.

### Several antennas

The two-antenna lab and the delay-skew lab are the pattern for beamforming and for alignment. In the company code, each antenna is a copy with an index, sharing one symbol strobe. If you change one antenna, check that the others still share the same symbol boundary.

### Entering the company code

Read one module in this order:

1. Clock and reset. What the reset clears.
2. The FSM and the edges that are allowed.
3. The register map: address, default, active copy.
4. The C-plane parser and the reject conditions.
5. The IQ path: width, `valid`, delay in cycles, bypass.
6. Which FIFO joins two clocks.
7. Which clocks the SDC file constrains.

Change one place at a time. Increment the image version. Keep one test of the old behavior. That is level 5 applied to a large RTL tree.

## What this board does not do

Do not use the EP1C6 to develop 10/25 GbE eCPRI, JESD204, a low-PHY FFT, CFR, DPD, real PTP/SyncE, or multi-antenna beamforming. Those jobs are level 6, on the company solution. This board is there to show that the Verilog of each layer is correct before you touch the image that is running.

## Order to follow

| Level | When you are done, you can | Suggested labs |
| --- | --- | --- |
| 1 | Program an image and recognize it | 1–45, `example/hello` |
| 2 | An FSM and clean inputs | 46–105 |
| 3 | Frame, symbol, and Apply registers | 106–185 |
| 4 | A section that controls samples, and gain that does not overflow | 186–335 |
| 5 | A small edit, a testbench, and a panel that shows one number | 336–540, prefer 466–500 and then 540 |
| 6 | Read and change the company O-RU FPGA under control | Do not program these blocks onto the EP1C6 |
