# 074 — Synchronize every switch bit on its own

## Description

Bài này thuộc nhóm Đồng bộ và CDC. Đưa nút và switch vào một miền clock trước khi FSM dùng chúng.

Việc cần làm: Synchronize every switch bit on its own. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Bit sync.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Bài này dùng LED, 7 thanh, nút, switch, ADC hoặc UART. Chép số chân từ silk của board này vào bảng chân trước khi ghi QSF. Không lấy sơ đồ board khác.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Bit sync. Viết nó nằm ở module nào trong RTL của bạn.
3. Chỉ ra tín hiệu bất đồng bộ. Không dùng mức switch thô trong hai always block.
4. Quyết định 2 FF hay bắt tay req/ack. Bus nhiều bit không đồng bộ từng bit rồi ghép lại.
5. Ước lượng thời gian dội phím nếu bài có debounce.

## Implement

1. Hành vi cần có: Synchronize every switch bit on its own.
2. Viết khối đồng bộ riêng, rồi mới lấy cạnh lên hoặc cạnh xuống.
3. Giữ dữ liệu nhiều bit cho đến khi nó ổn định, đúng như tên bài.
4. LED hoặc LCD chỉ đọc giá trị đã đồng bộ.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Gạt switch nhanh. LCD không được hiện mã nằm giữa hai giá trị.
4. Giữ nút và nhả nút. Mỗi lần nhấn chỉ tính một sự kiện nếu bài đếm cạnh.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- Ngõ vào bẩn trở thành một sự kiện sạch trong clock 50 MHz. Không có giá trị bus bị xé trên LCD.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Synchronize every switch bit on its own.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Input ngoài chip luôn đi qua đồng bộ trước khi vào thanh ghi điều khiển. Riêng bài 074, thói quen đó là: Bit sync.
