# 540 bài luyện FPGA để develop, sửa và bảo trì O-RU

Solution O-RU của công ty đã chạy ổn định. Các bài này không thay solution đó. Hiệu năng của EP1C6 thấp là cố ý. Mỗi bài luyện một thói quen sẽ dùng lại khi đọc, sửa và giữ nguyên hành vi của code FPGA lớn: một module, một clock, một thanh ghi, một bộ đếm, một lệnh, một đường mẫu.

Bài 1–500 luyện từng việc. Bài 501–540 gắn cùng lúc LED 7 thanh, LED đơn, nút nhấn, switch và ngõ ra (LCD cùng xung trạng thái). Một bitstream phải hiện số trên 7 thanh, hiện bit trên LED, nhận nút, nhận switch, và đẩy trạng thái ra LCD. Đó là cách quan sát khi sửa O-RU: nhiều ngõ ra cùng nói một sự thật.

Làm một bài mỗi lần. Sửa RTL, biên dịch bằng Quartus 11, nạp `.sof` qua JTAG, rồi đối chiếu 7 thanh, LED và LCD. Không cần làm hết trước khi mở code công ty.

Chân đã gán: clock 28, LCD D0–D7 = 223–216, RS 215, RW 214, E 213. Chân LED, 7 thanh, nút và switch chưa đọc từ silk nên chưa gán số. Không lấy sơ đồ board khác.

## Nhóm

| # | Nhóm | Bài | Việc tương ứng trên O-RU đang chạy |
| --- | --- | --- | --- |
| 1–20 | Quy trình project | 20 | Mở project, ràng buộc clock, đọc report, nạp image đúng |
| 21–45 | Thói quen Verilog | 25 | Module nhỏ, hằng số có tên, không latch, ghi chú khớp code |
| 46–65 | Reset và clock | 20 | Reset về giá trị an toàn, tick lồng nhau, đúng nguồn clock |
| 66–80 | Đồng bộ và CDC | 15 | Đưa nút và switch vào một clock, không xé bus |
| 81–105 | Máy trạng thái | 25 | Thêm trạng thái mà không làm hỏng chuyển trạng thái cũ |
| 106–145 | S-plane timing | 40 | Sửa frame, subframe, symbol mà không lệch một nhịp |
| 146–185 | M-plane registers | 40 | Sửa map, default, range, phân biệt edit và active |
| 186–220 | C-plane section | 35 | Sửa parser lệnh, từ chối lệnh sai, không vỡ lịch symbol |
| 221–255 | U-plane payload | 35 | Sửa header và IQ mà vẫn còn frame id và sequence |
| 256–285 | Đường IQ | 30 | Thêm pipeline thì delay valid cùng mẫu |
| 286–310 | Gain và số học | 25 | Đổi độ rộng gain thì sửa luôn bão hòa |
| 311–335 | NCO và DSP đơn giản | 25 | NCO, lọc đơn giản, biết bit lớn thêm bao nhiêu |
| 336–360 | Bộ nhớ | 25 | FIFO, RAM, ping-pong, xem cờ full và empty |
| 361–380 | LCD dùng để debug | 20 | Đưa trạng thái ra LCD để quan sát khi sửa |
| 381–400 | LED, nút và 7-segment | 20 | Gán đèn và nút theo silk, không lấy pin của board khác |
| 401–420 | Đường ADC | 20 | Xem mức ngõ vào, giữ số, ghi nhận quá ngưỡng |
| 421–445 | UART để debug | 25 | Log chậm, echo, đếm lỗi khung |
| 446–465 | Alarm và fault | 20 | Chốt lỗi, xóa đúng cách, tắt carrier khi fault |
| 466–475 | Testbench | 10 | Kiểm tra bằng testbench trước khi nạp board |
| 476–500 | Sửa và giữ hành vi cũ | 25 | Sửa một chỗ, giữ hành vi cũ, biên dịch lại, nạp lại |
| 501–540 | Panel kết hợp | 40 | Cùng lúc 7 thanh, LED, nút, switch và ngõ ra |

## Quy trình project (1–20)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 1 | Create a one-file project and compile it | Open, compile, find the SOF |
| 2 | Add a 20 ns SDC and remove the false 1 ns failure | Timing constraint |
| 3 | Set the top to the board wrapper | Top-level entity |
| 4 | Assign pin 28 as the only clock | Clock pin |
| 5 | Reserve unused pins as input tri-stated | Safe unused I/O |
| 6 | Read the fitter report and confirm the LCD pins | Pin check |
| 7 | Read LE, M4K, and PLL use | Resource report |
| 8 | Read setup slack and name the path if it is negative | Timing report |
| 9 | Change one constant and confirm the SOF checksum changes | Image identity |
| 10 | Program the SOF and confirm JTAG ID 020820DD | JTAG load |
| 11 | Power-cycle and confirm the SRAM image is gone | Volatile config |
| 12 | Show a version nibble on the LCD | Which image is loaded |
| 13 | Keep two revisions and switch the top between them | Revision control |
| 14 | Add a second Verilog file and instantiate it | Multi-file design |
| 15 | Leave an unused port unconnected so it is not fitted | No random pins |
| 16 | List warnings that are accepted and why | Warning review |
| 17 | Diff the fit log after a one-line change | What the edit touched |
| 18 | Store the SOF next to a one-line note of what it displays | Build note |
| 19 | Change only the LCD string and recompile | Small edit |
| 20 | Write the five steps: open qpf, compile, JTAG, check LCD | Repeatable flow |

## Thói quen Verilog (21–45)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 21 | Replace the clock frequency magic number with a localparam | Named constant |
| 22 | Use one ANSI-style port list | Readable ports |
| 23 | Keep the board wrapper separate from the LCD core | Module boundary |
| 24 | Tie RW low in one place only | Single driver |
| 25 | Parameterize CLK_HZ from the wrapper | Parameter override |
| 26 | Size a counter to its maximum count | Width matches range |
| 27 | Use nonblocking assignments in clocked logic | Clocked style |
| 28 | Name every state with a localparam | No magic state numbers |
| 29 | Separate the state register from the output logic | FSM split |
| 30 | Give every case a default safe value | No latch |
| 31 | Build the LCD ROM from a function of the string | Constant table |
| 32 | Assign a signal in every branch | Complete assignment |
| 33 | Generate two identical counters with a generate block | Repeated logic |
| 34 | Pass the display string in as a parameter | Reusable core |
| 35 | Name the header and payload fields of a packed bus | Field extract |
| 36 | Pack a section command into one bus | Command word |
| 37 | Write the reset value beside each register | Reset contract |
| 38 | Keep testbench time and RTL delays in the same unit | Time unit |
| 39 | Split a long FSM into init and run modules | Smaller modules |
| 40 | State in the header what this module owns | Ownership |
| 41 | Add a default arm so an unknown command is ignored | Safe decode |
| 42 | Compare a wire bus with a registered bus on the LCD | Wire versus reg |
| 43 | Override one parameter without editing the core | Hierarchy |
| 44 | Record the last edit in the file header | Change note |
| 45 | Keep one clock and one reset port on every module | Common ports |

## Reset và clock (46–65)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 46 | Hold a 50 ms synchronous boot reset | Power-on reset |
| 47 | Keep the LCD idle during reset | Safe outputs |
| 48 | Clear the frame counter on reset | Known time zero |
| 49 | Force the carrier off on reset | Safe radio default |
| 50 | Load the default gain on reset | Default parameter |
| 51 | Use a button as a synchronous reset | Operator reset |
| 52 | Make the reset release a one-cycle pulse | Clean release |
| 53 | Leave the NCO running through a soft reset and show the difference | What not to reset |
| 54 | Generate a 1 us enable for LCD delays | Fine tick |
| 55 | Generate a 1 ms enable | Subframe seed |
| 56 | Generate a 10 ms enable | Frame seed |
| 57 | Derive the symbol tick from the sample tick | Nested enable |
| 58 | Count clocks between two button presses | Interval measure |
| 59 | Flag a button that stays down | Stuck input |
| 60 | Use pin 28 directly and do not treat ADC CLK as the clock | Clock source |
| 61 | Note that LCD data is static between E pulses | Slow output |
| 62 | Change LCD data, then wait, then pulse E | Multicycle habit |
| 63 | Record slack before and after the SDC | Constraint effect |
| 64 | Divide 50 MHz to 1 Hz with an integer divider | Exact divide |
| 65 | Document the ADC clock pin as an FPGA output | Pin role |

## Đồng bộ và CDC (66–80)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 66 | Synchronize one switch with two flip-flops | 2FF sync |
| 67 | Compare a 3FF synchronizer with the 2FF version | Extra latency |
| 68 | Detect a rising edge after the synchronizer | Clean press |
| 69 | Detect a falling edge after the synchronizer | Clean release |
| 70 | Stretch a one-cycle pulse so an LED can show it | Visible event |
| 71 | Pass a slow event with a toggle synchronizer | Slow pulse |
| 72 | Handshake a key press into the FSM with req and ack | Request handshake |
| 73 | Read each switch in one domain only | No dual use |
| 74 | Synchronize every switch bit on its own | Bit sync |
| 75 | Debounce a switch for 20 ms | Bounce filter |
| 76 | Debounce for 1 ms and compare the feel | Filter length |
| 77 | Accept a multi-bit gain only after it is stable | Bus stability |
| 78 | Move a 2-bit mode as Gray code across a pretend boundary | Gray code |
| 79 | Show a torn multi-bit value when the handshake is skipped | CDC bug |
| 80 | Snapshot the synchronized switches once per second | Stable sample |

## Máy trạng thái (81–105)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 81 | Implement IDLE, CONFIG, RUN, and FAULT | RU state |
| 82 | Show the state name on the LCD | State observe |
| 83 | Force FAULT from a switch | Fault entry |
| 84 | Clear FAULT back to IDLE with a button | Fault exit |
| 85 | Ignore a jump that is not in the transition list | Illegal edge |
| 86 | Enter FAULT on a CONFIG timeout | Timeout |
| 87 | Stay in CONFIG for a minimum time | Min dwell |
| 88 | Enter RUN only when the carrier bit is on | Guarded run |
| 89 | Compare binary and one-hot encoding in the LE report | Encoding cost |
| 90 | Return to IDLE from an unknown state | Safe state |
| 91 | Drive LCD RS as a Moore output | Moore output |
| 92 | Drive LCD E as a one-cycle Mealy pulse | Mealy pulse |
| 93 | Nest an LCD-init FSM under the RU FSM | Hierarchy |
| 94 | Move LCD init into its own module | Factor |
| 95 | Add a state by name without renumbering the others | Extend |
| 96 | Hold the state while the enable is low | Enable |
| 97 | Store a fault code beside the state | Fault code |
| 98 | Remember the previous state | History |
| 99 | Clear a counter on entry to RUN | Entry action |
| 100 | Drop E when leaving the pulse state | Exit action |
| 101 | Connect two FSMs with a ready flag | Peer modules |
| 102 | Add a watchdog FSM that trips if it is not petted | Watchdog |
| 103 | Decode a switch as a state command | Command in |
| 104 | Reject a command in the wrong state | State guard |
| 105 | Keep the header state list identical to the RTL | Doc matches code |

## S-plane timing (106–145)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 106 | Count 10 ms frames | Radio frame |
| 107 | Wrap the frame number at 1024 | System frame |
| 108 | Show the frame number mod 256 on the LCD | Visible wrap |
| 109 | Count subframe 0 to 9 | 1 ms subframe |
| 110 | Increment the frame when the subframe wraps | Linked counters |
| 111 | Count two slots inside a subframe | NR slot |
| 112 | Count symbol 0 to 13 | OFDM symbol |
| 113 | Advance the subframe after symbol 13 | Symbol rollover |
| 114 | Count 32 toy samples inside a symbol | Sample count |
| 115 | Pulse on sample 0 | Symbol start |
| 116 | Show frame, subframe, and symbol together | Timing status |
| 117 | Pulse every 5 ms | Half frame |
| 118 | Wrap an 8-bit hyperframe | Long cycle |
| 119 | Pulse an LED once per frame | Frame strobe |
| 120 | Pulse an LED once per symbol | Symbol strobe |
| 121 | Add a switch-loaded frame offset | Timing offset |
| 122 | Show EARLY, LATE, or ON_TIME against that offset | Alignment |
| 123 | Select one of four symbol lengths | Numerology toy |
| 124 | Use a longer count on symbol 0 only | Extended CP |
| 125 | Use the shorter count on the other symbols | Normal CP |
| 126 | Restart the frame on a button acting as 1 pps | External sync |
| 127 | Keep counting if that 1 pps stops | Holdover |
| 128 | Count missing 1 pps events | Sync loss |
| 129 | Show the frame on two multiplexed 7-seg digits | Numeric out |
| 130 | Show the frame in decimal | BCD |
| 131 | Show the frame in hex | Hex status |
| 132 | Mark the middle symbol of the subframe | Symbol phase |
| 133 | Flag even and odd frames | Frame parity |
| 134 | Count the frame mod 8 | Pattern period |
| 135 | Count 20 slots in a 10 ms frame | Slot in frame |
| 136 | Show the sample index only while a switch is on | Gated display |
| 137 | Freeze the timing display | Hold for debug |
| 138 | Step one symbol per button press | Single step |
| 139 | Count alignment mismatches | Error counter |
| 140 | Confirm the maximum symbol index sticks at 13 | Range proof |
| 141 | Fix a bug where the symbol count stops at 14 | Off-by-one |
| 142 | Fix a bug where the subframe count stops at 10 | Off-by-one |
| 143 | Delay the strobe by one cycle and match the index | Pipeline align |
| 144 | Timestamp the first sample of symbol 0 | Symbol 0 time |
| 145 | Show local time minus air time | Two time bases |

## M-plane registers (146–185)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 146 | Carrier on and off bit | Carrier admin |
| 147 | Gain index 0 to 15 | Gain config |
| 148 | Tx or Rx mode bit | Direction |
| 149 | Frequency word from the switches | Center frequency |
| 150 | Bandwidth code 0 to 3 | Bandwidth |
| 151 | 4-bit antenna mask | Antenna enable |
| 152 | Show LOCK or UNLOCK | Admin state |
| 153 | Copy edit registers to active on Apply | Candidate config |
| 154 | Page through one register on the LCD | Readback |
| 155 | Restore defaults on reset | Factory default |
| 156 | Saturate a gain written above 15 | Range check |
| 157 | Increment a config version on Apply | Revision |
| 158 | Show edit and active values on two lines | Shadow registers |
| 159 | Add a read-only status register | Status |
| 160 | Clear an alarm by writing 1 | Write-1-to-clear |
| 161 | Read reserved bits as 0 | Reserved |
| 162 | Map addresses 0x00 to 0x0F | Address map |
| 163 | Ignore a write to a read-only address | Access type |
| 164 | Write only the low nibble | Byte enable |
| 165 | Keep the shadow copy until Apply | No partial apply |
| 166 | Ignore Apply while in FAULT | State policy |
| 167 | Ignore carrier-on while LOCKED | Admin policy |
| 168 | A bandwidth write updates the symbol length | Derived constant |
| 169 | Antenna bit 0 gates a pretend transmitter | Enable bit |
| 170 | Track two carrier ids and one active id | Multi-carrier toy |
| 171 | Save and recall one profile | Profile |
| 172 | Switch between profile A and B | Two profiles |
| 173 | Hold a config-changed flag until it is read | Sticky status |
| 174 | Range-check the frequency word | Limit |
| 175 | Show bandwidth as text | Enum decode |
| 176 | Dump the register map on UART | Remote read |
| 177 | Step the address with a button | Manual peek |
| 178 | Edit a nibble with up and down | Manual poke |
| 179 | Count commits | Apply count |
| 180 | Show the last address written | Write trace |
| 181 | Store defaults in a ROM | Default table |
| 182 | Show DIFF when active differs from default | Drift |
| 183 | Protect one register behind a key switch | Lock bit |
| 184 | Add a software-reset bit | Soft reset |
| 185 | Keep the comment map identical to the addresses | Map review |

## C-plane section (186–220)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 186 | Latch a section id from the switches | Section id |
| 187 | Latch a start symbol 0 to 13 | startSymbolId |
| 188 | Latch a symbol count | numSymbol |
| 189 | Latch a beam id 0 to 15 | beamId |
| 190 | Latch a 4-bit RE mask | reMask |
| 191 | Latch a small PRB count | numPrbc |
| 192 | Latch UL or DL | dataDirection |
| 193 | Commit the section on a key | Section command |
| 194 | Reject a length greater than 14 | Range reject |
| 195 | Queue four sections and show the depth | Section FIFO |
| 196 | Pop one section every frame | Schedule |
| 197 | Show NONE when the queue is empty | Idle section |
| 198 | Show the active section fields | Section status |
| 199 | Reject start plus length past symbol 13 | Span check |
| 200 | Flag two sections that overlap in time | Overlap |
| 201 | Reject a beam id above 15 | Beam check |
| 202 | Check that section ids increase | Sequence |
| 203 | Replace the active section | Update |
| 204 | Drop the oldest command when the FIFO is full | Overflow policy |
| 205 | Count dropped sections | Drop counter |
| 206 | Apply a section only on its start symbol | Timed start |
| 207 | End a section after its symbol count | Timed stop |
| 208 | Place a UL and a DL section in one frame | Two directions |
| 209 | Leave idle symbols between sections | Gap |
| 210 | Treat an RE mask of 0 as no data | Empty mask |
| 211 | Reject a PRB count of 0 | Empty section |
| 212 | Let the lower section id win a tie | Priority |
| 213 | Show the next queued section | Lookahead |
| 214 | Cancel the active section | Abort |
| 215 | Send a section once | One-shot |
| 216 | Repeat a section every frame until cleared | Persistent |
| 217 | Decode add, delete, and replace opcodes | Opcode |
| 218 | Delete an id that is not present | Missing id |
| 219 | Count accepted commands | Accept count |
| 220 | Count rejects and show the last reason | Reject cause |

## U-plane payload (221–255)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 221 | Send the constant sample I=1, Q=0 | Constant IQ |
| 222 | Ramp I each sample | Test ramp |
| 223 | Delay Q by one sample | IQ skew |
| 224 | Pack I and Q into 8 bits | Sample width |
| 225 | Store four IQ samples for one symbol | Symbol buffer |
| 226 | Overwrite that buffer every symbol | Symbol update |
| 227 | Put a header byte first | U-plane header |
| 228 | Increment a sequence number per symbol | Sequence id |
| 229 | Force zeros while the carrier is off | Mute |
| 230 | Put the frame number in the header | frameId |
| 231 | Put the symbol number in the header | symbolId |
| 232 | Select one of two IQ patterns | Test pattern |
| 233 | Send zeros while no section is active | Inactive RE |
| 234 | Show how many samples are stored | Buffer level |
| 235 | Compare two nibble orders | Endian |
| 236 | Put a length field in the header | Length |
| 237 | Check the length against the buffer | Length check |
| 238 | Flag a bad length | Header error |
| 239 | Detect a sequence gap | Lost packet |
| 240 | Detect a duplicate sequence | Replay |
| 241 | Copy the section id into the packet | Section bind |
| 242 | Copy the beam id into the packet | Beam bind |
| 243 | Put the direction bit in the packet | Direction bind |
| 244 | Pad to a fixed 8-byte packet | Fixed size |
| 245 | Mark the first sample | Start of burst |
| 246 | Mark the last sample | End of burst |
| 247 | Drop one packet on purpose and count it | Drop |
| 248 | Emit a packet only on active symbols | Gated TX |
| 249 | Mute one antenna bit | Per-antenna mute |
| 250 | Put a PRB index in the header | PRB id |
| 251 | Cycle an RE index inside the PRB | RE id |
| 252 | Compare two packets and show MATCH | Compare |
| 253 | Add a two-byte timestamp | Timestamp |
| 254 | Flash the LCD when a packet is sent | TX event |
| 255 | Hold the last header for inspection | Capture |

## Đường IQ (256–285)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 256 | Split one word into I and Q | Deinterleave |
| 257 | Clip I to signed 8 bits | I limit |
| 258 | Clip Q to signed 8 bits | Q limit |
| 259 | Delay the sample by one cycle | Pipeline |
| 260 | Delay the sample and the strobe by three cycles | Aligned pipe |
| 261 | Carry a valid bit with the sample | Valid |
| 262 | Hold the data when valid is low | Bubble |
| 263 | Stall when the buffer is full | Backpressure |
| 264 | Add a one-sample skid buffer | Skid |
| 265 | Swap the bytes of a sample word | Byte swap |
| 266 | Sign-extend a 4-bit switch value | Sign extend |
| 267 | Zero-extend the same value | Zero extend |
| 268 | Insert a marker sample on symbol 0 | Marker |
| 269 | Zero Q and keep I | I only |
| 270 | Make I and Q complementary counts | Paired samples |
| 271 | Mute one channel | Channel mute |
| 272 | Send even samples to antenna 0 | Interleave |
| 273 | Round-robin two antennas | Two antennas |
| 274 | Count samples per antenna | Per-antenna count |
| 275 | Share one strobe across both antennas | Alignment |
| 276 | Flag the antennas if their strobes differ | Misalignment |
| 277 | Delay antenna 1 by a switch-selected count | Delay line |
| 278 | Clear the misalignment flag when delays match | Realign |
| 279 | Add a DC offset with saturation | DC inject |
| 280 | Subtract that offset | DC remove |
| 281 | Select the top or low byte of a 12-bit word | Slice |
| 282 | Pack two 4-bit samples into one byte | Pack |
| 283 | Unpack that byte | Unpack |
| 284 | Count cycles spent stalled | Stall count |
| 285 | Show I and Q on two LCD fields | IQ observe |

## Gain và số học (286–310)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 286 | Shift a sample left by 0 to 3 | Coarse gain up |
| 287 | Shift a sample right by 0 to 3 | Coarse gain down |
| 288 | Saturate after the shift | Limiter |
| 289 | Round, then shift, and show the code | Round |
| 290 | Truncate, then shift, and compare | Truncate |
| 291 | Look up eight gains in a ROM | Gain table |
| 292 | Ramp the gain over 16 samples | Gain ramp |
| 293 | Change the gain only on a symbol boundary | Symbol update |
| 294 | Delay a mid-symbol gain change to the next symbol | Coherent update |
| 295 | Treat mute as gain 0 | Mute |
| 296 | Treat one extra left shift as +6 dB and flag overflow | +6 dB |
| 297 | Treat one right shift as -6 dB | -6 dB |
| 298 | Use different gains for I and Q | IQ imbalance toy |
| 299 | Use one common gain | Common gain |
| 300 | Convert offset binary to two's complement | Format |
| 301 | Convert two's complement to offset binary | Format back |
| 302 | Take the absolute value | Magnitude |
| 303 | Negate and saturate the most negative code | Negate |
| 304 | Compare against a threshold | Threshold |
| 305 | Add hysteresis around the threshold | Hysteresis |
| 306 | Hold the peak of abs(I) or abs(Q) | Peak |
| 307 | Clear the peak with a button | Peak reset |
| 308 | Count saturating samples | Sat count |
| 309 | Keep a sticky saturation flag | Sticky sat |
| 310 | Show the gain index and the saturation count | Gain status |

## NCO và DSP đơn giản (311–335)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 311 | Build a phase accumulator | NCO phase |
| 312 | Set the frequency word from switches | Frequency word |
| 313 | Drive an LED from the phase MSB | Square LO |
| 314 | Use the top two bits as a four-level wave | Coarse sine |
| 315 | Offset a second accumulator by a quarter turn | Quadrature |
| 316 | Reset the phase on symbol 0 | Phase sync |
| 317 | Let the phase free-run | Free run |
| 318 | Change the frequency word without clearing phase | Coherent tune |
| 319 | Sweep the frequency word slowly | Sweep |
| 320 | Stop the sweep on a button | Hold tune |
| 321 | Add dither in the low bits | Dither |
| 322 | Output the sample minus the previous sample | DC block |
| 323 | Sum the last four samples | Short average |
| 324 | Sum the last eight samples | Longer average |
| 325 | Keep one of every two samples | Decimate by 2 |
| 326 | Keep one of every four samples | Decimate by 4 |
| 327 | Integrate, then dump every eight samples | CIC toy |
| 328 | Output a first difference | Differentiator |
| 329 | Add a leaky integrator | Leaky average |
| 330 | Use a 4-tap FIR with power-of-two coefficients | FIR |
| 331 | Show the FIR output beside the raw sample | Compare filter |
| 332 | Fold identical taps to cut adds | Symmetry |
| 333 | Enable the DSP only in RUN | Clock gate by state |
| 334 | Bypass the filter with a bit | Bypass |
| 335 | Write down the accumulator bit growth | Bit growth |

## Bộ nhớ (336–360)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 336 | Store the LCD string in a ROM | ROM |
| 337 | Change one character and recompile | ROM edit |
| 338 | Store 16 IQ samples in RAM | Sample RAM |
| 339 | Use separate write and read addresses | RAM ports |
| 340 | Read the last two samples together | Dual read |
| 341 | Clear the RAM to zero | Init |
| 342 | Queue eight commands in a FIFO | Command FIFO |
| 343 | Drive full and empty flags | FIFO flags |
| 344 | Drive an almost-full flag | Threshold |
| 345 | Show the word count | Fill level |
| 346 | Allow read and write in the same cycle | Simultaneous |
| 347 | Block a read when empty | Underflow guard |
| 348 | Latch an overflow sticky bit | Overflow |
| 349 | Latch an underflow sticky bit | Underflow |
| 350 | Keep one frame of symbol ids in a circular buffer | Circular |
| 351 | Show RAM address 0 on the LCD | Peek |
| 352 | Walk the peek address with a button | Dump |
| 353 | Confirm M4K inference in the fit report | Memory type |
| 354 | Force a tiny ROM into logic and compare LE use | Infer versus logic |
| 355 | Write one byte of a 16-bit word | Byte write |
| 356 | Count the cycles a full clear takes | Clear cost |
| 357 | Leave RAM uncleared on a soft reset and show stale data | Reset scope |
| 358 | Ping-pong two symbol buffers | Double buffer |
| 359 | Let the reader see only the stable buffer | Buffer ownership |
| 360 | Swap pointers only on a symbol boundary | Atomic swap |

## LCD dùng để debug (361–380)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 361 | Draw a hex nibble | Hex font |
| 362 | Draw two hex bytes | Byte field |
| 363 | Draw a decimal value from 0 to 999 | Decimal |
| 364 | Wait long enough after the clear command | Controller time |
| 365 | Write line 0 at 0x80 and line 1 at 0xC0 | DDRAM |
| 366 | Rewrite only the character that changed | Partial update |
| 367 | Put the fault text on line 1 | Status line |
| 368 | Blink one character cell | Cursor |
| 369 | Load a small antenna glyph into CGRAM | Custom char |
| 370 | Draw an 8-character level bar | Bar graph |
| 371 | Refresh the text once per second | Readable rate |
| 372 | Hold the text during CONFIG | Quiet display |
| 373 | Show a splash, then live data | Boot then run |
| 374 | Page 0 timing, page 1 registers, page 2 alarms | Pages |
| 375 | Change page with a button | Page key |
| 376 | Show the image version nibble | Build id |
| 377 | Put state and symbol on one line | Dense status |
| 378 | Right-align a number | Format |
| 379 | Blank a field when it is invalid | Invalid mark |
| 380 | Keep contrast as a pot adjustment, not a pin | Analog control |

## LED, nút và 7-segment (381–400)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 381 | Light an LED from a switch | Direct I/O |
| 382 | Encode the FSM state on LEDs | State lamps |
| 383 | Use one LED for carrier and one for fault | Two alarms |
| 384 | Debounce a button for 20 ms | Clean key |
| 385 | Tell a long press from a short press | Press time |
| 386 | Use up and down buttons | Edit keys |
| 387 | Treat both buttons together as Apply | Chord |
| 388 | Show one hex digit on a 7-segment | Digit |
| 389 | Multiplex two digits | Scan |
| 390 | Blank the digits during reset | Dark reset |
| 391 | Dim an LED with a duty cycle | PWM |
| 392 | Show the subframe as a one-hot LED | Subframe lamp |
| 393 | Walk an LED once per symbol | Activity |
| 394 | Sample the dip switches once per frame | Frame sample |
| 395 | Pulse when any switch changes | Change event |
| 396 | Use the dip switches as a frequency word | Input word |
| 397 | Block Apply while a lock switch is on | Hardware lock |
| 398 | Run a lamp self-test at boot | Self-test |
| 399 | Comment every panel pin in the QSF | Pin list |
| 400 | Copy new LED pins from the silkscreen before using them | No guessed pins |

## Đường ADC (401–420)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 401 | Read the ADC once per second | Slow observe |
| 402 | Refresh the ADC value continuously | RX level |
| 403 | Track min and max since reset | Range |
| 404 | Show ALARM above a threshold | Level alarm |
| 405 | Map the ADC code to a gain index | Gain from level |
| 406 | Select an ADC0809 channel from a switch | Channel |
| 407 | Average 16 conversions | Smooth |
| 408 | Freeze the displayed code | Hold |
| 409 | Set the convert period | Sample rate |
| 410 | Convert on the symbol strobe | Symbol sample |
| 411 | Ignore conversions while in FAULT | Gated capture |
| 412 | Take a median of three codes | Spike reject |
| 413 | Count how often the code changes | Activity |
| 414 | Capture an offset while a button is held | Zero cal |
| 415 | Subtract that offset | Cal apply |
| 416 | Draw the code as an LCD bar | Level bar |
| 417 | Latch over-range | High alarm |
| 418 | Latch under-range | Low alarm |
| 419 | Timestamp the last over-range | Alarm time |
| 420 | Keep the ADC clock as an output pin | ADC clock role |

## UART để debug (421–445)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 421 | Transmit the text ORAN | TX path |
| 422 | Transmit the frame counter once per frame | Timing log |
| 423 | Echo each received byte | Loopback |
| 424 | Let a received byte set the gain | Remote config |
| 425 | Transmit an 8-byte toy packet | U-plane log |
| 426 | Count received bytes | Traffic count |
| 427 | Count framing errors | Link alarm |
| 428 | Show the last received byte | Capture |
| 429 | Divide 50 MHz down to 9600 baud | Baud divider |
| 430 | Compare the divider error at 115200 | Baud error |
| 431 | Send 8 data bits, no parity, one stop | 8N1 |
| 432 | Show a TX-busy flag | TX status |
| 433 | Count RX overruns | Overrun |
| 434 | Buffer 16 received characters | Line buffer |
| 435 | Treat CR or LF as end of command | Line end |
| 436 | Accept the command ON | Parser |
| 437 | Accept the command OFF | Parser |
| 438 | Accept GAIN followed by a number | Argument |
| 439 | Reply to an unknown command | Error reply |
| 440 | Print one status line per frame | Periodic log |
| 441 | Silence that status line with a bit | Log mask |
| 442 | Detect a binary start marker | Framing |
| 443 | Count markers that never arrive | Loss |
| 444 | Return the packet with the sequence plus one | Sequence reply |
| 445 | Read the RS-232 TX and RX pins from the silkscreen first | UART pins |

## Alarm và fault (446–465)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 446 | Latch an alarm | Latch |
| 447 | Clear the latch with a button | Operator clear |
| 448 | Clear only after the cause is gone | Condition clear |
| 449 | Rank a fault above a warning | Severity |
| 450 | Show the alarm code on the LCD | Code |
| 451 | Keep the first alarm and count the later ones | First cause |
| 452 | Store the last four codes in RAM | History |
| 453 | Blink an LED while a latch is set | Attention |
| 454 | Force the carrier off on a fault | Protect |
| 455 | Return to RUN automatically after a clear | Auto recover |
| 456 | Stay locked until an operator bit is set | Manual recover |
| 457 | Time out a watchdog | Watchdog |
| 458 | Pet the watchdog from the main FSM | Pet |
| 459 | Time out CONFIG | Boot timeout |
| 460 | Alarm when the section FIFO overflows | Queue alarm |
| 461 | Alarm on a UART framing error | Link alarm |
| 462 | Alarm on ADC over-range | Input alarm |
| 463 | Alarm when timing is late | Timing alarm |
| 464 | OR every alarm into one LED | Summary |
| 465 | Expose the alarms as bits in one register | Alarm word |

## Testbench (466–475)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 466 | Generate the clock in a testbench | TB clock |
| 467 | Check that the LCD bytes match the string | String check |
| 468 | Check that reset clears the frame counter | Reset check |
| 469 | Check that the symbol index wraps at 13 | Wrap check |
| 470 | Check that an illegal section is rejected | Reject check |
| 471 | Check that a shifted sample saturates | Sat check |
| 472 | Check the FIFO full flag | FIFO check |
| 473 | Print a PASS line only if all checks pass | Self-check |
| 474 | Add a check that fails if the string changes by mistake | Regression |
| 475 | Compare the testbench result with the LCD before calling a lab done | Sim then board |

## Sửa và giữ hành vi cũ (476–500)

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 476 | Change only the LCD string and do not touch pins | Isolated edit |
| 477 | Add a state and keep the old transitions | Extend FSM |
| 478 | Widen gain from 4 bits to 5 and update saturation | Width change |
| 479 | Insert a pipeline stage and delay valid with it | Pipe edit |
| 480 | Move one register address and update the dump | Map edit |
| 481 | Rename a signal and compile cleanly | Rename |
| 482 | Delete a dead assignment and confirm the LCD | Dead code |
| 483 | Fix the symbol off-by-one and add a testbench check | Bugfix |
| 484 | Change a default without changing the address map | Default edit |
| 485 | Add a bit at the top of a register | Compatible add |
| 486 | Keep reserved bits reading as zero | Reserved policy |
| 487 | Split one module and wire it back the same way | Refactor |
| 488 | Share one counter between two displays | Single source |
| 489 | Turn 10 ms into a parameter and check one frame | Parameterize |
| 490 | Guard a new write so RUN behavior stays the same | Protect run |
| 491 | Put a bypass around a new filter | Fallback |
| 492 | Increment the version field for this edit only | Traceability |
| 493 | Read the diff and say what timing changed | Review |
| 494 | Re-read setup slack after the edit | Timing recheck |
| 495 | Reprogram and confirm the old splash is gone | New image |
| 496 | Restore the previous behavior by reverting one constant | Revert |
| 497 | Comment why an accepted warning is safe | Warning note |
| 498 | Leave unused pins tri-stated after the edit | Pin safety |
| 499 | Write the symptom, the module, and the fix in three lines | Debug note |
| 500 | Repeat one small edit until compile, program, and check is routine | Maintenance loop |

## Panel kết hợp (501–540)

Mỗi bài dùng đủ năm thứ trong một thiết kế: LED 7 thanh hiện số, LED đơn hiện bit, nút nhấn ra lệnh, switch đưa dữ liệu, ngõ ra là LCD cộng một xung trạng thái. Chưa điền số chân cho đến khi đọc silk.

| # | Bài | Thói quen mang sang O-RU |
| --- | --- | --- |
| 501 | Self-test: every LED on, 7-seg shows 8, LCD shows EP1C6, buttons ignored | Boot lamps |
| 502 | IDLE: heartbeat LED, 7-seg 0, LCD IDLE, switches ignored until Apply | Quiet idle |
| 503 | Switch nibble on the 7-seg, LCD shows SW, LSB lights one LED | Input visible |
| 504 | Up and down buttons change the 7-seg, the LED marks the limit | Edit keys |
| 505 | Apply copies the switches into the active value on the 7-seg and LCD | Commit |
| 506 | Reset button clears the 7-seg, turns LEDs off, and shows IDLE | Operator reset |
| 507 | Short press steps the 7-seg by 1, long press by 16, LED shows which | Press time |
| 508 | 7-seg shows the frame, LEDs show the subframe, LCD shows the symbol, one button freezes all | Timing panel |
| 509 | 7-seg shows symbol 0–13, LED pulses each symbol, switch selects long symbol 0, LCD shows CP | CP select |
| 510 | Switch sets an offset, 7-seg shows the delta, LEDs show early or late, LCD shows the word | Alignment |
| 511 | 7-seg shows the state code, one LED per state, button advances, switch forces FAULT | State panel |
| 512 | Switch requests carrier on, Apply commits, LED shows carrier, 7-seg shows gain, LCD shows LOCK | Carrier |
| 513 | Buttons edit gain, 7-seg shows it, LED flags saturation, switch mutes, LCD shows GAIN | Gain panel |
| 514 | Switch selects bandwidth 0–3, 7-seg shows the code, LED echoes it, Apply updates the LCD | Bandwidth |
| 515 | Four switches drive four LEDs, 7-seg shows the mask, Apply stores it, LCD shows ANT | Antenna mask |
| 516 | Switches set the start symbol, 7-seg shows it, button latches, LED shows active, LCD shows the id | Section |
| 517 | A bad length puts the reason on the 7-seg, lights the fault LED, LCD shows REJ, button clears | Reject |
| 518 | 7-seg shows FIFO depth, LED shows full, one button pushes, one pops, LCD shows the depth | Queue |
| 519 | Switch selects an IQ pattern, 7-seg shows the id, LED toggles per sample, LCD shows I and Q | Pattern |
| 520 | Switch sets the shift, 7-seg shows the result, LED shows overflow, button bypasses, LCD shows SAT | Gain path |
| 521 | Switch sets the NCO word, 7-seg shows it, LED is the MSB, button clears phase, LCD shows RUN | NCO panel |
| 522 | Switch injects an alarm, 7-seg shows the code, LED blinks, button clears, LCD names it | Alarm panel |
| 523 | 7-seg counts down the watchdog, LED trips at zero, button pets it, LCD shows WD | Watchdog |
| 524 | Button changes the LCD page, 7-seg shows the page, LED shows which page, switch locks it | Pages |
| 525 | The same version nibble appears on the 7-seg, one LED pattern, and the LCD | Image id |
| 526 | Button steps the address, 7-seg shows it, LCD shows the data, LED is the LSB, switch writes | Peek and poke |
| 527 | 7-seg shows the ADC code, LED shows over threshold, button freezes, switch selects the channel | ADC panel |
| 528 | Button sends a byte, 7-seg shows the last received byte, LED shows TX busy, switch enables the log | UART panel |
| 529 | One scan: state on LEDs, number on the 7-seg, text on the LCD, inputs from switches and buttons | One status |
| 530 | Debounce every button, 7-seg shows which one, LED compares raw and clean, LCD counts edges | Clean inputs |
| 531 | A changed switch puts the bit number on the 7-seg, pulses an LED, LCD shows the bit, button acks | Change |
| 532 | Multiplex the 7-seg with blanking between digits, button sets brightness, LCD shows the digit index | Digit outputs |
| 533 | Switch tri-states a spare output, 7-seg shows OE, LED follows only when enabled, LCD shows OE | Output enable |
| 534 | Switch picks active-high or active-low, button runs a test pattern on LEDs and 7-seg | Polarity |
| 535 | Move only the fault LED and keep the 7-seg code and the LCD text | Isolated output edit |
| 536 | Write the silk pin table for every LED, digit, button, and switch before compiling | Pin capture |
| 537 | 7-seg shows the frame, LED shows fault, button clears, switches set gain, LCD shows both | Combined status |
| 538 | Button steps one symbol, 7-seg shows it, LED strobes, switch selects run or step, LCD shows state | Single step |
| 539 | Switch selects profile A or B, button copies it, 7-seg shows the id, LED shows which, LCD names it | Profile |
| 540 | After any edit, one test button walks LEDs, counts the 7-seg, and the LCD must show PASS | Panel regression |
