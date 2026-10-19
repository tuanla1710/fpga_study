# 323 — Sum the last four samples

## Description

Bài này thuộc nhóm NCO và DSP đơn giản. Tích lũy pha và lọc bằng cộng hoặc dịch. Theo dõi bit mọc thêm.

Việc cần làm: Sum the last four samples. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Short average.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Chưa dùng chân LED, 7 thanh, nút hoặc switch trong bài này thì chưa gán các chân đó.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Short average. Viết nó nằm ở module nào trong RTL của bạn.
3. Viết độ rộng accumulator trước khi code.
4. Hệ số lọc phải là lũy thừa của 2 nếu bài nói power-of-two.
5. Quyết định bypass để còn đường mẫu cũ.

## Implement

1. Hành vi cần có: Sum the last four samples.
2. Làm đúng khối trong tên bài.
3. Reset pha chỉ khi bài yêu cầu. Không reset NCO trong mọi soft reset.
4. Thêm bit bypass nếu bài so sánh lọc với mẫu thô.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Đổi frequency word hoặc hệ số. LED MSB hoặc LCD đổi theo, không về 0 đột ngột trừ khi bài reset pha.
4. Bật bypass. Ngõ ra phải trùng mẫu vào.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- Khối DSP của bài chạy trong RUN, bypass trả lại mẫu gốc, và comment trong RTL ghi độ rộng bit sau cộng dồn.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Sum the last four samples.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Thêm một khối xử lý trên O-RU cần biết bit growth và còn đường vòng qua khối mới. Riêng bài 323, thói quen đó là: Short average.
