# 440 — Print one status line per frame

## Description

Bài này thuộc nhóm UART để debug. Cổng RS-232 là kênh log chậm thay cho trace trên RU thật.

Việc cần làm: Print one status line per frame. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Periodic log.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Bài này dùng LED, 7 thanh, nút, switch, ADC hoặc UART. Chép số chân từ silk của board này vào bảng chân trước khi ghi QSF. Không lấy sơ đồ board khác.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Periodic log. Viết nó nằm ở module nào trong RTL của bạn.
3. Chép chân TX và RX từ silk. Ghi baud và sai số bộ chia từ 50 MHz.
4. Chốt khung 8N1.
5. Định nghĩa câu lệnh hoặc gói mà bài này gửi và nhận.

## Implement

1. Hành vi cần có: Print one status line per frame.
2. Viết bộ phát hoặc bộ nhận đúng bài. Không dùng chân UART chưa có trong bảng.
3. Đếm framing error và overrun thay vì bỏ qua.
4. Lệnh lạ phải có câu trả lời lỗi, không được đổi gain.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Nối UART của board với một cổng COM của PC, đúng baud.
4. Gửi đúng câu của bài và một câu sai. Chỉ câu đúng đổi trạng thái.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- Byte đúng hiện trên LCD hoặc quay lại PC. Bộ đếm lỗi tăng khi cố ý gửi sai baud hoặc sai khung.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Print one status line per frame.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Log chậm vẫn đủ để đọc thanh ghi và đếm lỗi khi chưa có đường trace tốc độ cao. Riêng bài 440, thói quen đó là: Periodic log.
