# FPGA learning path

The goal is to read, change, and maintain the O-RU FPGA that is already running at the company. The board on hand is a Cyclone EP1C6Q240C8. This chip is small. It has no hard processor and no transceiver, so it is only for practice. The same LUT, flip-flop, clock, memory, and I/O blocks are the blocks you will meet again in a large O-RU FPGA.

The exercises are in `docs/ru_board_projects.md` and the `labs/` directory. The example that already runs on the LCD is `example/hello/`: it displays `O-RAN Team`.

## Where an FPGA differs from software

A CPU fetches one instruction, finishes it, then fetches the next. An FPGA does not run that way. A Verilog file describes circuits that exist at the same time. After compilation, the configuration is loaded into the chip's SRAM. Each LUT, each flip-flop, and each route receives a configuration. Removing power clears that SRAM, so a `.sof` programmed over JTAG is lost when power is removed.

The loop used when changing an O-RU is the same loop: edit the circuit description, compile, program the image, and check that the old behavior is still correct.

## Blocks inside an FPGA

An FPGA is a grid. Logic blocks sit in rows and columns. Programmable routing runs between them. The clock network is separate, so one clock reaches many flip-flops at the same time. I/O pins sit around the edge. Block memory and PLLs sit in their own columns.

On the EP1C6Q240C8, the numbers to remember are:

| Block | On the EP1C6 | What the block does |
| --- | --- | --- |
| Logic element (LE) | About 5980 | One 4-input LUT plus one flip-flop |
| Logic array block (LAB) | 10 LEs in one LAB | A group of LEs that share local wires and a carry chain |
| Routing | Rows and columns | Connects LEs, RAM, and pins according to the fitter |
| Clock | Dedicated pins, chip-wide clock network | Brings one clock to many flip-flops |
| PLL | 2 | Multiplies, divides, and phase-shifts a clock |
| M4K | 20 blocks, about 92 Kbit | RAM, ROM, FIFO |
| I/O element | Q240 package, about 185 user pins | Input, output, or hi-Z |
| Configuration | SRAM inside the chip | Holds the design after a JTAG program |

The EP1C6 has no hard multiplier, no transceiver, and no hard CPU. Multiplication is built from LEs. A 10 GbE or 25 GbE O-RU path does not fit on this chip.

### Logic element

A 4-input LUT implements any logic function of four signals: AND, OR, XOR, a mux, or part of a decoder. The flip-flop after the LUT holds the result on a clock edge. The carry chain connects LEs so addition and comparison are faster than a pile of separate LUTs.

Uses: a frame counter, a state machine, a gain register, an alarm-threshold comparator. On an O-RU, the control logic and the bit packing also live in LUTs and flip-flops, even though a newer chip's LUT usually has six inputs.

### LAB and routing

A LAB groups ten LEs so nearby signals do not have to travel on long wires. Quartus's fitter chooses which LE and which wire. The person writing RTL does not place each LUT, but still has to know that a clocked `always` becomes a flip-flop and a combinational `assign` becomes a LUT.

A route that is too long makes a path late. That is why a design that is functionally correct can still fail timing.

### Clock

The flip-flops in one module must share one clock. On this board the system clock is OSC pin 28, treated as 50 MHz when the SDC file states a 20 ns period. ADC CLK is a pulse the FPGA sends to the ADC. It is not the chip clock.

The chip-wide clock network has low skew between flip-flops. Do not use an ordinary logic signal as a clock. For a 1 ms or 10 ms beat, make a one-cycle enable pulse. The registers still clock at 50 MHz.

A PLL takes a clock in and makes a faster clock, a slower clock, or a phase-shifted clock. The EP1C6 has two PLLs. The early labs do not need a PLL. On an O-RU, PLLs and cleaner clock blocks make the sample clock, the bus clock, and the interface clock.

### M4K memory

Each M4K block is about 4 Kbit of synchronous RAM, plus parity bits. Twenty blocks are this chip's memory ceiling. The LCD string ROM, a command queue, and a buffer of a few IQ samples must live in those blocks, or in LEs if the table is very small.

The O-RU use is the same idea, only deeper: a symbol buffer, a FIFO between two clock domains, filter coefficients, a gain table. The habits to practice are the full flag, the empty flag, and the moment a buffer may be swapped.

### I/O pins

Each user pin has an input direction, an output direction, or a disabled output (tri-state), and it can have its own flip-flop. The standard in use for the LCD is 3.3 V LVTTL. Leave unused pins as input tri-stated. Do not tie them to ground in a row.

Pins already read from this board's silkscreen:

| Signal | Pin |
| --- | --- |
| Clock | 28 |
| LCD D0–D7 | 223–216 |
| LCD RS, RW, E | 215, 214, 213 |

LEDs, the 7-segment display, buttons, switches, the ADC, and RS-232 still have to be copied from the silkscreen before they are assigned. Do not take pin numbers from another board.

### Configuration

The design lives in SRAM. JTAG loads a `.sof`, and that image is lost when power is removed. The AS header uses a `.pof` when the design must survive power loss. The two 10-pin headers do not stand in for each other. For JTAG, the USB-Blaster cable must be on the JTAG header and the RUN/PROG switch must be on RUN.

### Blocks that exist only on a large O-RU FPGA

When you open the company code, the names below are parts the EP1C6 cannot implement. The way you read the RTL is still the same:

| Block | Function | Use on the RU |
| --- | --- | --- |
| DSP / MAC | Multiply, then add, in one hard block | Gain, filtering, FFT, DPD |
| Transceiver | Multi-gigabit SerDes | eCPRI, CPRI, JESD204 |
| Large RAM | Megabits | Symbol buffer, coefficients |
| Several clock domains | Data clock, bus clock, CPU clock | Sample path and control path |
| Configuration and debug blocks | JTAG, Signal Tap, registers | Program an image and read status |

LUTs, flip-flops, FSMs, registers, FIFOs, and clock constraints still sit underneath those blocks. Practice on the EP1C6 is practice at that layer.

## Languages

An FPGA is not programmed in a language that runs line by line. The language describes a circuit, and the tool synthesizes it into LUTs and flip-flops.

| Language | Used for | Note for this path |
| --- | --- | --- |
| Verilog | Circuit description and testbenches | The language of `example/hello` and of the labs in `labs/` |
| VHDL | The same job as Verilog, with different syntax | The company's O-RU code may be VHDL. The way you read a block is the same |
| SystemVerilog | Interfaces, `logic`, assertions in a testbench | Quartus 11 support is narrow. Do not use it as the main language on this board yet |
| SDC | Clock and path-delay constraints | It does not describe function. Without an SDC, TimeQuest assumes a 1 ns period and reports a false negative slack |
| Tcl | Drive Quartus from the command line | `quartus_sh --flow compile`, project assignments, scripts |
| C / Python | CPU, scripts, tests outside the chip | They do not become LUTs. O-RU software drives registers. The FPGA is the circuit |

An `if` inside a clocked `always` block is a multiplexer in front of a flip-flop. It is not a program branch that runs only when execution reaches that line. Two `always` blocks on the same clock run in parallel.

## Structure of one design

The example that is running is split into two layers. `lcd_hello_ep1c6` is the shell that attaches board pins. `lcd_hello` is the LCD circuit, with a `CLK_HZ` parameter.

```text
lcd_hello_ep1c6          top, only real board pins
  lcd_hello              HD44780 init FSM and character ROM
    clk                  one clock
    lcd_rs, lcd_en, lcd_data
    lcd_rw               tied to 0
```

The pieces inside a Verilog file:

| Piece | Role |
| --- | --- |
| `module` / `endmodule` | One named block, like one component |
| `input` / `output` ports | Pins of the block. A `wire` connects through. A `reg` is assigned inside `always` |
| `parameter` | A constant the parent module can override, for example `CLK_HZ` |
| `localparam` | An internal constant, for example the state code `S_BOOT` |
| `assign` | Combinational logic, with no memory |
| `always @(posedge clk)` | A flip-flop. Assign with `<=` |
| `case` with a default branch | A state machine. A missing branch easily becomes a latch |
| ROM or an array | The LCD command table. Later, a gain table or a queue |
| A parent module calls a child module | Split ownership: who holds timing, who holds the LCD, who holds the registers |

The order of lines inside `always` is not the order of time. The flip-flops take their new values on the same clock edge.

Files around the RTL:

| File | Job |
| --- | --- |
| `.v` | Circuit description |
| `_tb.v` | Testbench. It generates a fake clock and checks results |
| `.qpf` | Quartus project. Compilation works only after this file is opened |
| `.qsf` | Chip, top level, source files, pin numbers |
| `.sdc` | Clock constraints |
| `.sof` | JTAG image. Quartus 11 writes it in the project directory |

The tool is Quartus II 11.0 Web Edition, device `EP1C6Q240C8`. Quartus 24.1 on this machine is only for programming. It cannot synthesize the original Cyclone family.

## Path

Follow the order. Each lab in `labs/` has a `README.md`: prepare, research, implement, test, expected results, and what you learned. You do not need to finish all 540 labs before opening the company code.

| Stage | Work | Labs |
| --- | --- | --- |
| 0. Board is alive | Program the LCD example again, see `O-RAN Team`, and know the image is lost when power is removed | `example/hello` |
| 1. Blocks and tools | Point out the LE, clock, I/O, and configuration SRAM on the design you just programmed. Practice opening the `.qpf`, reading the report, and finding the `.sof` | 1–20 |
| 2. Verilog structure | Split modules, name constants, avoid latches, one clock and one reset | 21–45 |
| 3. Clock, reset, synchronization, FSM | 1 ms and 10 ms enables. A button passes through two flip-flops. States IDLE, CONFIG, RUN, FAULT | 46–105 |
| 4. Time and registers | Frame, subframe, symbols 0–13. A register copy being edited and a copy that is running | 106–185 |
| 5. Commands and samples | Sections, IQ header, gain by bit shift, saturation, an NCO built from a phase accumulator | 186–335 |
| 6. Watch the state | RAM, FIFO, LCD, then LEDs, the 7-segment display, buttons, and switches after the silkscreen has been copied | 336–540 |
| 7. Company code | Find, in the O-RU RTL, the same blocks you practiced: clock, FSM, register map, FIFO, pipeline | The solution that is running |

When you reach stage 7, read one module against the same list:

1. Which port is the clock, which port is the reset, and which registers the reset clears.
2. Which states exist, and which edges are allowed.
3. Which registers are configuration, and which bits are reserved.
4. How many cycles the samples and `valid` are delayed.
5. Which FIFO joins two clock domains.
6. Which clocks the SDC file constrains.

Change one place, compile again, program again, then check both the new behavior and one old behavior. That is what labs 476–500 and 540 practice on this board's panel.
