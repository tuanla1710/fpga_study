# 382 — Encode the FSM state on LEDs

## Description

Bài này thuộc nhóm LED, nút và 7-segment. Đèn, nút, switch và LED 7 thanh. Chân phải lấy từ silk của board này.

Việc cần làm: Encode the FSM state on LEDs. Thói quen mang sang FPGA O-RU đang chạy ở công ty: State lamps.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Bài này dùng LED, 7 thanh, nút, switch, ADC hoặc UART. Chép số chân từ silk của board này vào bảng chân trước khi ghi QSF. Không lấy sơ đồ board khác.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: State lamps. Viết nó nằm ở module nào trong RTL của bạn.
3. Chép số chân LED, 7 thanh, nút và switch từ silk vào một bảng trong thư mục bài này trước khi sửa QSF.
4. Ghi cực tính: tích cực cao hay thấp. Đo bằng cách bật một đèn trong bài self-test.
5. Không mở sơ đồ board khác để điền số chân.

## Implement

1. Hành vi cần có: Encode the FSM state on LEDs.
2. Gán đúng các chân đã chép. Chân chưa có trong bảng thì chưa được dùng.
3. Làm đúng một hành vi trong tên bài.
4. Quét 7 thanh có khoảng tắt giữa hai digit để khỏi bóng.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Đối chiếu từng LED và từng digit với bảng chân.
4. Nhấn một nút. Chỉ một chức năng của bài xảy ra.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- Đèn và 7 thanh hiện đúng giá trị của bài. Không có chân nào bị gán từ trí nhớ hoặc từ board khác.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Encode the FSM state on LEDs.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Gán I/O panel là một phần của việc sửa FPGA. Sai chân có thể đánh ra ngoài ý muốn. Riêng bài 382, thói quen đó là: State lamps.
