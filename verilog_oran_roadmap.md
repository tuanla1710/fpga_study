# Lộ trình Verilog từ cơ bản đến chuyên sâu O-RAN

Học trên board Cyclone EP1C6Q240C8 để sau này phát triển và sửa FPGA O-RU. Chip này không chạy eCPRI, JESD204, FFT hay DPD. Mỗi mức dưới đây luyện một lớp Verilog sẽ gặp lại trong solution O-RU đang chạy ở công ty. Kiến trúc khối LUT, clock, RAM và chân I/O nằm ở `fpga_roadmap.md`. Danh sách bài và thư mục làm việc nằm ở `docs/ru_board_projects.md` và `labs/`.

Ví dụ đã nạp được là `example/hello/`: LCD hiện `O-RAN Team`. Clock là chân 28. LCD D0–D7 = 223–216, RS 215, RW 214, E 213. LED, 7 thanh, nút, switch, ADC và UART chỉ gán sau khi chép số chân từ silk của board này.

Mỗi mức có một tiêu chí xong. Chưa xong thì chưa sang mức sau. Không cần làm hết 540 bài. Làm các bài ghi trong mức đó cho đến khi tiêu chí đạt.

## O-RU nhìn từ phía Verilog

FPGA O-RU giữ phần việc phải đúng từng micro giây. Phần mềm giữ cấu hình và giám sát.

| Mặt phẳng | Ai làm trên RU thật | Việc Verilog tương ứng | Mức luyện trên board |
| --- | --- | --- | --- |
| S-plane | Đồng bộ thời gian với O-DU | Bộ đếm frame, subframe, symbol, offset, holdover | 3 |
| M-plane | Phần mềm ghi thanh ghi | Map địa chỉ, bản nháp và bản đang chạy, default, range | 3 |
| C-plane | Lệnh section theo thời gian thực | Parser lệnh, kiểm tra, hàng đợi, lịch symbol | 4 |
| U-plane | Mẫu IQ theo symbol | Header, sequence, mute, độ trễ pipeline | 4 |
| Low-PHY và DFE | FFT, CP, NCO, lọc, gain, CFR, DPD | Dịch bit, bão hòa, bộ cộng pha, trung bình, decimate | 4, rồi đọc tiếp ở mức 6 |
| Fronthaul | eCPRI trên transceiver 10/25 GbE | Khung byte, cờ lỗi, loopback trên UART | 5 và 6 |

Split thường gặp là 7.2x: O-RU làm FFT/iFFT, gắn và bỏ cyclic prefix, đưa IQ miền tần số qua fronthaul. O-DU giữ phần PHY cao hơn và lịch. Category và chỗ đặt beamforming phụ thuộc solution công ty. Khi mở code, đối chiếu bảng này trước, chưa cần đoán category.

## Mức 1 — Verilog cơ bản

Mục tiêu là viết được một module, biên dịch bằng Quartus 11, nạp `.sof` qua JTAG, và biết image nào đang nằm trong chip.

Verilog cần nắm:

- `module`, port `input` và `output`, `wire` và `reg`.
- `assign` là mạch tổ hợp. `always @(posedge clk)` là flip-flop. Trong khối clock dùng `<=`.
- `parameter` đổi từ module cha. `localparam` chỉ dùng trong module.
- Module cha gọi module con. Top `lcd_hello_ep1c6` chỉ đưa ra chân có thật trên board.
- Một `if` trong khối clock là multiplexer trước flip-flop, không phải nhánh chương trình chạy tuần tự.

Việc trên board: bài 1–45 và ví dụ `example/hello`. Đổi một ký tự trên LCD, biên dịch lại, nạp lại, thấy checksum `.sof` đổi. Mở project bằng file `.qpf`. Thêm SDC chu kỳ 20 ns cho chân 28. Để chân không dùng ở input tri-stated.

O-RAN ở mức này chỉ là một câu: sản phẩm công ty cũng là một image nạp vào FPGA, có version và có thể mất khi chỉ nạp SRAM.

Xong khi tự làm được bốn việc mà không xem lại log cũ: mở đúng project, biên dịch 0 error, nạp JTAG thấy IDCODE `020820DD`, và giải thích vì sao tắt nguồn thì chữ trên LCD mất.

## Mức 2 — Mạch đồng bộ

Mục tiêu là mọi thanh ghi dùng một clock, reset về giá trị đã biết, và nút bấm không làm FSM nhảy hai lần.

Verilog cần nắm:

- Reset đồng bộ. Liệt kê thanh ghi nào bị xóa.
- Enable một chu kỳ cho mốc 1 us, 1 ms, 10 ms. Không tạo clock mới bằng cách chia ra một chân.
- Bộ đếm có độ rộng đúng giá trị lớn nhất.
- FSM có tên trạng thái, nhánh `default`, và danh sách cạnh được phép.
- Hai flip-flop đồng bộ cho switch. Debounce khoảng 20 ms. Bus nhiều bit không được đồng bộ từng bit rồi ghép lại.

Việc trên board: bài 46–105. LCD hiện `IDLE`, `CONFIG`, `RUN`, `FAULT`. Nút clear và switch fault đi qua khối đồng bộ. Clock vẫn là chân 28. ADC CLK không phải clock hệ thống.

O-RAN ở mức này: trạng thái vận hành của RU là một FSM. Carrier không được bật khi đang `FAULT` hoặc đang khóa.

Xong khi gây một lệnh sai trạng thái và chỉ ra trên LCD là máy không nhảy bừa. Setup slack dương với SDC 20 ns. Slack âm vì chu kỳ 1 ns nghĩa là thiếu SDC.

## Mức 3 — Thời gian và thanh ghi

Mục tiêu là đếm đúng lịch radio và tách cấu hình nháp khỏi cấu hình đang chạy. Đây là cửa vào S-plane và M-plane.

Verilog cần nắm:

- Nhiều bộ đếm lồng nhau bằng enable: sample, symbol, subframe, frame.
- Điểm wrap viết thành hằng số: symbol dừng ở 13, subframe dừng ở 9, frame đếm rộng hơn những gì LCD hiện được.
- Hai bản thanh ghi. Nút Apply mới copy bản edit sang bản active.
- Địa chỉ, bit reserved đọc về 0, giá trị reset, và từ chối ghi quá dải.

Việc trên board: bài 106–185. LCD hiện frame, subframe và symbol cùng lúc. Một switch nạp frame offset và LCD báo sớm, đúng, hoặc trễ. Gain và carrier chỉ đổi sau Apply. Reset trả default.

O-RAN ở mức này:

- 10 ms là một radio frame. 1 ms là một subframe. Trong subframe có các symbol OFDM. Symbol 0 có thể dài hơn nếu mô phỏng cyclic prefix mở rộng.
- Một xung ngoài, trên board là nút, đóng vai 1 pps. Khi nút ngừng, bộ đếm vẫn chạy. Đó là holdover ở dạng bài tập, chưa phải PTP.
- Thanh ghi active là thứ đường mẫu được phép đọc. Bản edit là thứ phần mềm còn đang ghi.

Xong khi nhìn LCD và nói được số đang hiện là frame nào, symbol nào, và một lần ghi gain chưa Apply thì đường mẫu chưa đổi.

## Mức 4 — Lệnh, mẫu IQ và số học

Mục tiêu là một lệnh hợp lệ làm đường mẫu đổi đúng symbol, một lệnh sai không phá lịch, và một phép gain không tràn vòng.

Verilog cần nắm:

- Một từ lệnh gồm các field: section id, symbol bắt đầu, số symbol, beam id, hướng UL hoặc DL, số PRB, RE mask.
- FIFO nông cho vài lệnh. Cờ full, empty, và bộ đếm lệnh bị từ chối.
- Mẫu có `valid`. Thêm một tầng pipeline thì `valid` trễ đúng số chu kỳ đó.
- Số có dấu, dịch trái và dịch phải, bão hòa hai đầu dải. EP1C6 không có nhân cứng, nên gain làm bằng dịch bit.
- Bộ cộng pha cho NCO. Ghi độ rộng bit sau khi cộng dồn. Có đường bypass để còn mẫu gốc.

Việc trên board: bài 186–335. LCD hoặc UART hiện section đang chạy và header của gói mẫu: frame, symbol, sequence. Tắt carrier thì payload về 0. Beam id và section id trong header khớp lệnh vừa nhận. Một mã lớn sau khi dịch phải kẹp ở trần và bật cờ saturation.

O-RAN ở mức này là bản thu nhỏ của C-plane và U-plane:

- C-plane nói vùng tài nguyên nào được dùng trong frame.
- U-plane mang IQ của vùng đó.
- `startSymbolId + numSymbol` không được vượt quá symbol cuối.
- Sequence giúp thấy mất gói hoặc gói lặp.
- Gain và NCO là hai khối DFE nhỏ nhất. Trên RU thật chúng đứng trước hoặc sau FFT, nhưng cách viết Verilog giống nhau: vào theo `valid`, ra cùng độ trễ, có bypass.

Xong khi làm một thử nghiệm liên hoàn trên board: nạp một section đúng, thấy mẫu chạy trong các symbol đó, gửi một section dài quá 14 symbol, thấy bị từ chối, và đường đang chạy không mất frame id.

## Mức 5 — Ghép board và sửa mà không làm hỏng phần cũ

Mục tiêu là một thiết kế nhiều khối vẫn có một nguồn sự thật, và một lần sửa chỉ đổi đúng việc cần đổi.

Verilog cần nắm:

- RAM và FIFO suy ra từ mảng có clock. Biết khi nào Quartus dùng M4K.
- Ping-pong: đổi con trỏ buffer ở biên symbol, người đọc chỉ thấy buffer đã ổn định.
- Testbench tự in `PASS`. Một sửa hằng số vô tình phải làm testbench hết `PASS`.
- Alarm dạng latch. Xóa chỉ khi nguyên nhân đã hết, nếu quy tắc của bài là như vậy. Fault thì tắt carrier.
- UART 8N1 là kênh log chậm: đếm framing error, không cho lệnh lạ đổi gain.

Việc trên board: bài 336–540, sau khi đã có bảng chân silk cho LED, 7 thanh, nút và switch. Một bitstream hiện cùng một số trên 7 thanh, cùng một bit trên LED, và cùng một chữ trên LCD. Bài 476–500 là các lần sửa thật: rộng thêm một bit gain, thêm một trạng thái, thêm một tầng pipeline, rồi chứng minh hành vi cũ còn đúng.

O-RAN ở mức này là kỷ luật phát triển. Solution công ty đã chạy. Một thay đổi register map, một thêm chu kỳ pipeline, hoặc một đổi độ rộng gain đều phải đi cùng kiểm tra phần đang on-air.

Xong khi có một diff nhỏ, biên dịch lại, nạp lại, và chỉ ra được hành vi mới cùng một hành vi cũ không đổi. Panel không được mâu thuẫn nhau.

## Mức 6 — Chuyên sâu để phát triển O-RAN

Mức này làm trên giấy, testbench và code công ty. EP1C6 không tổng hợp được các khối dưới đây. Với mỗi chủ đề, dùng lại module đã viết ở mức 3–5 như hình thu nhỏ, rồi đọc khối tương ứng trong solution đang chạy.

### Fronthaul và eCPRI

Trên RU thật, U-plane và C-plane đi trong Ethernet tốc độ cao qua transceiver. Bài UART 8 byte là cùng một việc ở tốc độ thấp: marker, độ dài, sequence, đếm lỗi khung.

Khi đọc code công ty, tìm ba thứ trước: khối bắt đầu và kết thúc gói, chỗ gắn `frameId` với `symbolId`, và FIFO nằm giữa clock transceiver và clock baseband. Chưa sửa địa chỉ MAC hay bảng PCS.

### S-plane thật

PTP và SyncE khóa thời gian RU vào O-DU. Bài nút 1 pps và holdover chỉ luyện phản ứng của bộ đếm khi nguồn đồng bộ mất. Trên code công ty, tìm thanh ghi offset, cờ loss of sync, và chỗ bộ đếm air-frame được nạp lại. Sửa bộ đếm mà chưa đọc các cờ đó sẽ làm lệch symbol.

### C-plane đủ field

Bản trên board có section id, symbol, beam, hướng, PRB và RE mask. Bản trong spec còn kiểu section, số symbol liên tiếp, và extension. Cách Verilog không đổi: một FSM nhận từ, một bảng kiểm tra, một FIFO, một lịch áp vào đúng symbol. Luyện thêm bằng cách rộng từng field trong testbench, chưa cần nạp board.

### U-plane và nén mẫu

IQ trên dây thường hẹp hơn IQ trong chip. Bài dịch bit và bão hòa là dạng đơn giản của block floating point và cắt bit. Khi vào code công ty, tìm độ rộng trước khi nén, độ rộng trên fronthaul, và chỗ báo tràn. Đổi một độ rộng thì sửa cả khối bão hòa và test hai đầu dải.

### Low-PHY

FFT, iFFT, gắn CP và PRACH cần bộ nhớ và nhân cứng mà EP1C6 không có. Cách đọc một FFT trong RTL vẫn là cách đã luyện: vào theo symbol, ra trễ một số chu kỳ cố định, `valid` đi cùng mẫu, symbol 0 có độ dài khác nếu CP khác. Vẽ latency của khối đó trước khi sửa hệ số hay thứ tự mẫu.

### DFE

NCO trên board là bộ cộng pha. Lọc trên board là cộng và dịch. Trên RU thật, mixer, CFR và DPD dùng khối DSP. Tìm cổng bypass và cổng gain trước khi sửa hệ số. Một khối mới phải có đường vòng qua nó, đúng như bài bypass ở mức 4.

### Nhiều anten

Bài hai anten và độ trễ lệch là mẫu của beamforming và của căn chỉnh. Trên code công ty, mỗi anten là một bản sao có chỉ số, dùng chung strobe symbol. Sửa một anten thì kiểm tra anten còn lại vẫn cùng biên symbol.

### Vào code công ty

Đọc một module theo thứ tự này:

1. Clock và reset. Reset xóa những gì.
2. FSM và các cạnh được phép.
3. Map thanh ghi: địa chỉ, default, bản active.
4. Parser C-plane và điều kiện từ chối.
5. Đường IQ: độ rộng, `valid`, số chu kỳ trễ, bypass.
6. FIFO nào nối hai clock.
7. File SDC khóa những clock nào.

Sửa một chỗ mỗi lần. Tăng version của image. Giữ một test của hành vi cũ. Đó là mức 5 áp vào cây RTL lớn.

## Việc board này không làm

Không dùng EP1C6 để phát triển eCPRI 10/25 GbE, JESD204, FFT low-PHY, CFR, DPD, PTP/SyncE thật, hay beamforming nhiều anten. Các việc đó ở mức 6, trên solution công ty. Board này để chứng minh Verilog của từng lớp đã đúng trước khi đụng vào image đang chạy.

## Thứ tự nên đi

| Mức | Xong thì làm được | Bài gợi ý |
| --- | --- | --- |
| 1 | Nạp và nhận ra image | 1–45, `example/hello` |
| 2 | FSM và ngõ vào sạch | 46–105 |
| 3 | Frame, symbol, thanh ghi Apply | 106–185 |
| 4 | Section điều khiển mẫu, gain không tràn | 186–335 |
| 5 | Sửa nhỏ, testbench, panel cùng một số | 336–540, ưu tiên 466–500 rồi 540 |
| 6 | Đọc và sửa có kiểm soát trên FPGA O-RU công ty | Không nạp các khối này lên EP1C6 |
