# 472 — Check the FIFO full flag

## Description

Bài này thuộc nhóm Testbench. Kiểm tra bằng testbench trước khi nạp board.

Việc cần làm: Check the FIFO full flag. Thói quen mang sang FPGA O-RU đang chạy ở công ty: FIFO check.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Chưa dùng chân LED, 7 thanh, nút hoặc switch trong bài này thì chưa gán các chân đó.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: FIFO check. Viết nó nằm ở module nào trong RTL của bạn.
3. Viết danh sách assert: điều kiện đúng và điều kiện phải fail.
4. Chọn clock testbench nhanh hơn clock board nếu chỉ để đếm sự kiện, và ghi rõ hệ số.
5. Chỉ ra một sửa đổi vô tình mà testbench này phải bắt được.

## Implement

1. Hành vi cần có: Check the FIFO full flag.
2. Viết testbench tự in PASS chỉ khi mọi check đúng.
3. Thêm đúng check trong tên bài.
4. Không chờ LCD thật trong testbench. Kiểm tra byte hoặc thanh ghi.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Chạy testbench bằng trình mô phỏng đang có. Nếu máy chưa có iverilog, duyệt từng check trên giấy rồi mới nạp board.
4. Đổi cố ý một hằng số. Testbench phải hết PASS.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- Lần chạy đúng in PASS. Lần phá cố ý không in PASS.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Check the FIFO full flag.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Trước khi nạp image O-RU, một kiểm tra tự động phải còn đúng. Riêng bài 472, thói quen đó là: FIFO check.
