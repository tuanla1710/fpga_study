# 190 — Latch a 4-bit RE mask

## Description

Bài này thuộc nhóm C-plane section. Lệnh section: nhận, kiểm tra, xếp hàng, áp vào đúng symbol.

Việc cần làm: Latch a 4-bit RE mask. Thói quen mang sang FPGA O-RU đang chạy ở công ty: reMask.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Chưa dùng chân LED, 7 thanh, nút hoặc switch trong bài này thì chưa gán các chân đó.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: reMask. Viết nó nằm ở module nào trong RTL của bạn.
3. Liệt kê field: section id, start symbol, số symbol, beam id, hướng, PRB, RE mask.
4. Viết điều kiện từ chối. start + length không vượt quá symbol 13.
5. Quyết định FIFO đầy thì bỏ lệnh mới hay lệnh cũ.

## Implement

1. Hành vi cần có: Latch a 4-bit RE mask.
2. Làm đúng một kiểm tra hoặc một opcode trong tên bài.
3. Lệnh bị từ chối không được sửa section đang chạy.
4. LCD hiện lý do từ chối hoặc độ sâu hàng đợi.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Gửi một lệnh đúng. Section active đổi đúng field.
4. Gửi một lệnh sai theo tên bài. Bộ đếm reject tăng, lịch symbol cũ giữ nguyên.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- Lệnh hợp lệ được nhận. Lệnh sai bị đếm và không làm lệch symbol đang chạy.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Latch a 4-bit RE mask.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Sửa parser lệnh O-RU mà đường đang phát không bị vỡ lịch. Riêng bài 190, thói quen đó là: reMask.
