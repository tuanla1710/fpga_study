# Lộ trình học FPGA

Mục tiêu là đọc, sửa và bảo trì FPGA O-RU đang chạy ở công ty. Board đang có là Cyclone EP1C6Q240C8. Chip này nhỏ, không có nhân cứng và không có transceiver, nên chỉ dùng để luyện. Cùng các khối LUT, flip-flop, clock, bộ nhớ và chân I/O vẫn là các khối sẽ gặp lại trong FPGA O-RU lớn.

Bài tập nằm trong `docs/ru_board_projects.md` và thư mục `labs/`. Ví dụ đã chạy trên LCD là `example/hello/`: hiện `O-RAN Team`.

## FPGA khác phần mềm ở đâu

CPU lấy một dòng lệnh, làm xong, rồi lấy dòng tiếp theo. FPGA không chạy theo kiểu đó. File Verilog mô tả các mạch tồn tại cùng một lúc. Sau khi biên dịch, cấu hình được nạp vào SRAM của chip. Mỗi LUT, mỗi flip-flop và mỗi dây nối nhận một cấu hình. Tắt nguồn là SRAM mất cấu hình, nên file `.sof` nạp bằng JTAG sẽ mất khi rút điện.

Vòng làm việc lúc sửa O-RU cũng là vòng này: sửa mô tả mạch, biên dịch, nạp image, kiểm tra hành vi cũ còn đúng.

## Các khối trong FPGA

Một FPGA là một lưới. Khối logic nằm thành hàng và cột. Dây nối programmable routing đi giữa chúng. Mạng clock đi riêng để đồng hồ tới nhiều flip-flop cùng một lúc. Chân I/O nằm quanh viền. Bộ nhớ khối và PLL nằm ở những cột riêng.

Trên EP1C6Q240C8, các con số cần nhớ:

| Khối | Có trên EP1C6 | Việc của khối |
| --- | --- | --- |
| Logic element (LE) | Khoảng 5980 | Một LUT 4 ngõ vào cộng một flip-flop |
| Logic array block (LAB) | 10 LE trong một LAB | Nhóm LE dùng chung dây cục bộ và đường carry |
| Routing | Hàng và cột | Nối LE, RAM và chân theo kết quả fitter |
| Clock | Chân chuyên dụng, mạng clock toàn chip | Đưa một clock tới nhiều flip-flop |
| PLL | 2 | Nhân, chia, dịch pha clock |
| M4K | 20 khối, khoảng 92 Kbit | RAM, ROM, FIFO |
| I/O element | Gói Q240, khoảng 185 chân user | Vào, ra, hoặc hi-Z |
| Cấu hình | SRAM trong chip | Giữ thiết kế sau khi nạp JTAG |

EP1C6 không có khối nhân cứng, không có transceiver, không có CPU cứng. Phép nhân do LE ghép lại. Đường 10 GbE hoặc 25 GbE của O-RU không nằm trên chip này.

### Logic element

LUT 4 ngõ vào làm một hàm logic bất kỳ của bốn tín hiệu: AND, OR, XOR, bộ chọn, hoặc một phần của bộ giải mã. Flip-flop đứng sau LUT để giữ kết quả theo cạnh clock. Đường carry nối các LE để cộng và so sánh nhanh hơn là xếp nhiều LUT rời.

Ứng dụng: bộ đếm frame, máy trạng thái, thanh ghi gain, bộ so sánh ngưỡng alarm. Trên O-RU, phần điều khiển và phần gộp bit cũng nằm trong LUT và flip-flop, dù LUT của chip mới thường có sáu ngõ vào.

### LAB và routing

LAB gom mười LE để các tín hiệu gần nhau không phải chạy ra dây dài. Fitter của Quartus chọn LE nào và dây nào. Người viết RTL không đặt từng LUT, nhưng vẫn phải biết một `always` theo clock sẽ thành flip-flop, và một `assign` tổ hợp sẽ thành LUT.

Routing quá dài làm đường tới chậm. Đó là lý do một thiết kế đúng chức năng vẫn có thể fail timing.

### Clock

Các flip-flop trong một module phải dùng chung một clock. Trên board này, clock hệ thống là OSC chân 28, coi là 50 MHz khi file SDC ghi chu kỳ 20 ns. ADC CLK là xung FPGA phát ra cho ADC, không phải clock của chip.

Mạng clock toàn chip có độ lệch thấp giữa các flip-flop. Không nên lấy một tín hiệu logic thường làm clock. Muốn nhịp 1 ms hoặc 10 ms thì tạo một xung enable rộng một chu kỳ, rồi các thanh ghi vẫn clock bằng 50 MHz.

PLL lấy clock vào và tạo clock nhanh hơn, chậm hơn, hoặc lệch pha. EP1C6 có hai PLL. Bài đầu chưa cần PLL. Trên O-RU, PLL và khối clock sạch hơn dùng để tạo clock mẫu, clock bus, và clock giao tiếp.

### Bộ nhớ M4K

Mỗi khối M4K là RAM đồng bộ khoảng 4 Kbit dữ liệu, kèm bit parity. Hai mươi khối là trần bộ nhớ của chip này. ROM chuỗi LCD, hàng đợi lệnh, và buffer vài mẫu IQ phải nằm trong số đó hoặc trong LE nếu bảng quá nhỏ.

Ứng dụng trên O-RU cùng nguyên tắc, chỉ sâu hơn: buffer symbol, FIFO giữa hai miền clock, hệ số lọc, bảng gain. Việc cần luyện là cờ full, cờ empty, và thời điểm được đổi buffer.

### Chân I/O

Mỗi chân user có chiều vào, ra, hoặc ngõ ra tắt (tri-state), có thể có flip-flop riêng. Chuẩn đang dùng cho LCD là 3.3 V LVTTL. Chân chưa dùng để ở input tri-stated, không kéo xuống đất hàng loạt.

Chân đã đọc từ silk của board này:

| Tín hiệu | Chân |
| --- | --- |
| Clock | 28 |
| LCD D0–D7 | 223–216 |
| LCD RS, RW, E | 215, 214, 213 |

LED, LED 7 thanh, nút, switch, ADC và RS-232 vẫn phải chép từ silk trước khi gán. Không lấy số chân của board khác.

### Cấu hình

Thiết kế nằm trong SRAM. JTAG nạp file `.sof` và mất khi tắt nguồn. Header AS dùng file `.pof` nếu muốn giữ sau khi mất điện. Hai header 10 chân trên board không thay thế cho nhau. Cáp USB-Blaster phải ở header JTAG, công tắc RUN/PROG ở RUN.

### Những khối chỉ có trên FPGA O-RU lớn

Khi mở code công ty, các tên sau là phần EP1C6 không làm được, nhưng cách đọc RTL vẫn giống:

| Khối | Chức năng | Ứng dụng trên RU |
| --- | --- | --- |
| DSP / MAC | Nhân rồi cộng trong một khối cứng | Gain, lọc, FFT, DPD |
| Transceiver | SerDes nhiều Gb/s | eCPRI, CPRI, JESD204 |
| RAM lớn | Hàng megabit | Buffer symbol, hệ số |
| Nhiều miền clock | Clock data, clock bus, clock CPU | Đường mẫu và đường điều khiển |
| Khối cấu hình và debug | JTAG, Signal Tap, thanh ghi | Nạp image và đọc trạng thái |

LUT, flip-flop, FSM, thanh ghi, FIFO và ràng buộc clock vẫn ở dưới các khối đó. Luyện trên EP1C6 là luyện lớp này.

## Ngôn ngữ

FPGA không lập trình bằng một ngôn ngữ chạy từng dòng. Ngôn ngữ mô tả mạch, công cụ tổng hợp thành LUT và flip-flop.

| Ngôn ngữ | Dùng để | Ghi chú cho lộ trình này |
| --- | --- | --- |
| Verilog | Mô tả mạch và testbench | Ngôn ngữ của `example/hello` và của các bài trong `labs/` |
| VHDL | Cùng việc với Verilog, cú pháp khác | Code O-RU của công ty có thể là VHDL. Cách đọc khối thì giống nhau |
| SystemVerilog | Interface, `logic`, assert trong testbench | Quartus 11 hỗ trợ hẹp. Chưa dùng làm ngôn ngữ chính trên board này |
| SDC | Ràng buộc clock và đường trễ | Không mô tả chức năng. Thiếu SDC thì TimeQuest giả định chu kỳ 1 ns và báo slack âm giả |
| Tcl | Điều khiển Quartus bằng lệnh | `quartus_sh --flow compile`, gán project, chạy script |
| C / Python | CPU, script, test bên ngoài | Không trở thành LUT. Phần mềm O-RU điều khiển thanh ghi, còn FPGA là mạch |

Một `if` trong khối `always` theo clock là một multiplexer đứng trước một flip-flop, không phải một nhánh chương trình chỉ chạy khi tới dòng đó. Hai `always` cùng clock chạy song song.

## Cấu trúc một thiết kế

Ví dụ đang chạy tách làm hai tầng. `lcd_hello_ep1c6` là vỏ gắn chân board. `lcd_hello` là mạch LCD, có tham số `CLK_HZ`.

```text
lcd_hello_ep1c6          top, chỉ có chân thật của board
  lcd_hello              FSM khởi tạo HD44780 và ROM ký tự
    clk                  một clock
    lcd_rs, lcd_en, lcd_data
    lcd_rw               buộc 0
```

Các mảnh trong một file Verilog:

| Mảnh | Vai trò |
| --- | --- |
| `module` / `endmodule` | Một khối có tên, giống một linh kiện |
| Port `input` / `output` | Chân của khối. `wire` nối thẳng, `reg` được gán trong `always` |
| `parameter` | Hằng số đổi được từ module cha, ví dụ `CLK_HZ` |
| `localparam` | Hằng số nội bộ, ví dụ mã trạng thái `S_BOOT` |
| `assign` | Mạch tổ hợp, không có bộ nhớ |
| `always @(posedge clk)` | Flip-flop. Gán bằng `<=` |
| `case` có nhánh default | Máy trạng thái. Thiếu nhánh dễ thành latch |
| ROM hoặc mảng | Bảng lệnh LCD, sau này là bảng gain hoặc hàng đợi |
| Module cha gọi module con | Phân chỗ sở hữu: ai giữ timing, ai giữ LCD, ai giữ thanh ghi |

Thứ tự dòng trong `always` không phải thứ tự thời gian. Các flip-flop lấy giá trị mới ở cùng một cạnh clock.

Tệp quanh RTL:

| Tệp | Việc |
| --- | --- |
| `.v` | Mô tả mạch |
| `_tb.v` | Testbench, phát clock giả và kiểm tra |
| `.qpf` | Project Quartus. Phải mở file này thì mới biên dịch được |
| `.qsf` | Chip, top-level, file nguồn, số chân |
| `.sdc` | Ràng buộc clock |
| `.sof` | Image nạp JTAG, do Quartus 11 ghi ở thư mục project |

Công cụ là Quartus II 11.0 Web Edition, device `EP1C6Q240C8`. Quartus 24.1 trên máy này chỉ để nạp, không tổng hợp được Cyclone đời đầu.

## Lộ trình

Đi theo thứ tự. Mỗi bài trong `labs/` có `README.md`: chuẩn bị, nghiên cứu, thực hiện, kiểm tra, kết quả, và bài học. Không cần làm hết 540 bài trước khi mở code công ty.

| Giai đoạn | Việc | Bài |
| --- | --- | --- |
| 0. Board sống | Nạp lại ví dụ LCD, thấy `O-RAN Team`, biết image mất khi tắt nguồn | `example/hello` |
| 1. Khối và công cụ | Chỉ ra LE, clock, I/O, SRAM cấu hình trên chính bài vừa nạp. Tập mở `.qpf`, đọc report, tìm `.sof` | 1–20 |
| 2. Cấu trúc Verilog | Tách module, đặt tên hằng, tránh latch, một clock một reset | 21–45 |
| 3. Clock, reset, đồng bộ, FSM | Enable 1 ms và 10 ms. Nút đi qua hai flip-flop. Trạng thái IDLE, CONFIG, RUN, FAULT | 46–105 |
| 4. Thời gian và thanh ghi | Frame, subframe, symbol 0–13. Bản thanh ghi đang sửa và bản đang chạy | 106–185 |
| 5. Lệnh và mẫu | Section, header IQ, gain bằng dịch bit, bão hòa, NCO bằng bộ cộng pha | 186–335 |
| 6. Nhìn trạng thái | RAM, FIFO, LCD, rồi LED, 7 thanh, nút và switch sau khi đã chép silk | 336–540 |
| 7. Code công ty | Tìm trong RTL O-RU đúng các khối đã luyện: clock, FSM, map thanh ghi, FIFO, pipeline | Solution đang chạy |

Khi sang giai đoạn 7, đọc một module theo cùng một danh sách:

1. Port nào là clock, port nào là reset, reset xóa những thanh ghi nào.
2. Trạng thái nào tồn tại, cạnh nào được phép.
3. Thanh ghi nào là cấu hình, bit nào là reserved.
4. Mẫu và `valid` trễ bao nhiêu chu kỳ.
5. FIFO nào nối hai miền clock.
6. File SDC khóa clock nào.

Sửa một chỗ, biên dịch lại, nạp lại, rồi kiểm tra cả hành vi mới và một hành vi cũ. Đó là việc các bài 476–500 và 540 luyện trên panel của board này.
