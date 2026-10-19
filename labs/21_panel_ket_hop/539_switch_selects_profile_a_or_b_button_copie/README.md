# 539 — Switch selects profile A or B, button copies it, 7-seg shows the id, LED shows which, LCD names it

## Description

Bài này thuộc nhóm Panel kết hợp. Một bitstream dùng cùng lúc 7 thanh, LED, nút, switch và LCD.

Việc cần làm: Switch selects profile A or B, button copies it, 7-seg shows the id, LED shows which, LCD names it. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Profile.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Bài này dùng LED, 7 thanh, nút, switch, ADC hoặc UART. Chép số chân từ silk của board này vào bảng chân trước khi ghi QSF. Không lấy sơ đồ board khác.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Profile. Viết nó nằm ở module nào trong RTL của bạn.
3. Chép silk của LED, 7 thanh, nút và switch vào bảng chân của bài trước khi gán.
4. Phân vai: 7 thanh hiện số, LED hiện bit, nút ra lệnh, switch đưa dữ liệu, LCD hiện chữ.
5. Viết một câu sự thật mà cả năm ngõ phải nói giống nhau.

## Implement

1. Hành vi cần có: Switch selects profile A or B, button copies it, 7-seg shows the id, LED shows which, LCD names it.
2. Một module trạng thái, nhiều ngõ ra. Không để mỗi đèn chạy một bộ đếm riêng.
3. Làm đúng tình huống trong tên bài.
4. Nút và switch đi qua debounce và đồng bộ trước khi đổi trạng thái.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Sau khi nạp, đọc số trên 7 thanh, bit trên LED và chữ trên LCD trong cùng một trạng thái.
4. Bấm nút và gạt switch của bài. Cả ba nơi hiển thị đổi cùng một sự kiện.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- 7 thanh, LED và LCD không mâu thuẫn nhau. Một nút test hoặc một thao tác của bài làm cả panel đổi đúng hướng.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Switch selects profile A or B, button copies it, 7-seg shows the id, LED shows which, LCD names it.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Khi sửa O-RU, các cửa sổ trạng thái phải cùng một nguồn sự thật. Panel board này luyện điều đó. Riêng bài 539, thói quen đó là: Profile.
