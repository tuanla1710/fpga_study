# 374 — Page 0 timing, page 1 registers, page 2 alarms

## Description

Bài này thuộc nhóm LCD dùng để debug. LCD 16x2 đang nối sẵn, dùng như màn hình trạng thái khi sửa.

Việc cần làm: Page 0 timing, page 1 registers, page 2 alarms. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Pages.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Chưa dùng chân LED, 7 thanh, nút hoặc switch trong bài này thì chưa gán các chân đó.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Pages. Viết nó nằm ở module nào trong RTL của bạn.
3. Nhắc lại chân đã biết: D0–D7 = 223–216, RS 215, RW 214, E 213. RW giữ 0.
4. Tra thời gian chờ sau lệnh clear và sau lệnh function set.
5. Chọn địa chỉ dòng: 0x80 cho dòng 1, 0xC0 cho dòng 2.

## Implement

1. Hành vi cần có: Page 0 timing, page 1 registers, page 2 alarms.
2. Giữ FSM khởi tạo LCD đã chạy với chuỗi O-RAN Team. Chỉ thêm hành vi của bài.
3. Viết đúng định dạng trong tên bài: hex, decimal, trang, hoặc một ký tự đổi.
4. Không gán lcd_on và lcd_blon ra chân FPGA.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Nạp .sof. Dòng chữ đọc được, không chỉ có đèn nền.
4. Nếu bài có nhiều trang, mỗi lần bấm nút chỉ đổi một trang và số trên hai dòng còn khớp nhau.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- LCD hiện đúng nội dung của bài sau khi khởi tạo xong. Chỉnh biến trở contrast nếu chỉ thấy nền sáng.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Page 0 timing, page 1 registers, page 2 alarms.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Khi sửa O-RU, trạng thái nội phải có chỗ nhìn. LCD trên board này đóng vai trò đó. Riêng bài 374, thói quen đó là: Pages.
