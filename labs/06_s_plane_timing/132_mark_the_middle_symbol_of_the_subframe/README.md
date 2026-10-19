# 132 — Mark the middle symbol of the subframe

## Description

Bài này thuộc nhóm S-plane timing. Bộ đếm frame 10 ms, subframe 1 ms, symbol 0 đến 13.

Việc cần làm: Mark the middle symbol of the subframe. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Symbol phase.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Chưa dùng chân LED, 7 thanh, nút hoặc switch trong bài này thì chưa gán các chân đó.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Symbol phase. Viết nó nằm ở module nào trong RTL của bạn.
3. Viết thứ tự đếm: sample, symbol, subframe, frame. Ghi điểm wrap.
4. Symbol dừng ở 13, subframe dừng ở 9. Kiểm tra lỗi lệch một trước khi code.
5. Chọn chỗ hiện giá trị: LCD là đủ nếu chưa có chân 7 thanh.

## Implement

1. Hành vi cần có: Mark the middle symbol of the subframe.
2. Đếm bằng enable, không tạo clock mới.
3. Làm đúng một mốc trong tên bài và hiện nó ra.
4. Nếu bài là sửa off-by-one, thêm một kiểm tra trong testbench hoặc một dòng comment nêu mốc đúng.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Nhìn điểm wrap. Symbol không được hiện 14. Subframe không được hiện 10.
4. Nếu có nút single-step, mỗi lần nhấn chỉ tăng một đơn vị của bài.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- Số trên LCD đúng dải của bài và quay vòng đúng chỗ. Hai bộ đếm liên quan tăng cùng một lúc, không lệch một nhịp.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Mark the middle symbol of the subframe.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Sửa timing O-RU là sửa điểm wrap và độ trễ strobe, rồi nhìn lại symbol 0 và symbol cuối. Riêng bài 132, thói quen đó là: Symbol phase.
