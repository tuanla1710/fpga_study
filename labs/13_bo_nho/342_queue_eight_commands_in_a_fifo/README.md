# 342 — Queue eight commands in a FIFO

## Description

Bài này thuộc nhóm Bộ nhớ. ROM, RAM, FIFO và hai buffer. EP1C6 có 20 khối M4K.

Việc cần làm: Queue eight commands in a FIFO. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Command FIFO.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Chưa dùng chân LED, 7 thanh, nút hoặc switch trong bài này thì chưa gán các chân đó.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Command FIFO. Viết nó nằm ở module nào trong RTL của bạn.
3. Chọn độ sâu và độ rộng. Ước lượng có vừa M4K hay rơi vào logic.
4. Định nghĩa empty, full, và việc đọc khi empty.
5. Quyết định reset có xóa RAM hay chỉ xóa con trỏ.

## Implement

1. Hành vi cần có: Queue eight commands in a FIFO.
2. Suy ra bộ nhớ bằng mảng có clock, đúng hình trong tên bài.
3. Cờ full và empty không được đúng cùng một lúc khi còn dữ liệu.
4. Đổi buffer ở biên symbol nếu bài là ping-pong.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Đọc report fitter và ghi RAM được map vào M4K hay LE.
4. Đầy FIFO rồi ghi thêm. Sticky overflow bật, dữ liệu cũ không bị xé.
5. Đọc khi empty. Không được lấy một từ rác rồi tăng con trỏ.
6. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
7. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- Cờ đầy, rỗng và số phần tử khớp với số lần ghi và đọc. Report bộ nhớ khớp kiểu đã chọn.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Queue eight commands in a FIFO.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Buffer trên O-RU có chủ sở hữu rõ: ai ghi, ai đọc, và đổi con trỏ ở biên nào. Riêng bài 342, thói quen đó là: Command FIFO.
