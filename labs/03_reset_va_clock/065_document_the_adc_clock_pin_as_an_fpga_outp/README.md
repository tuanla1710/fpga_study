# 065 — Document the ADC clock pin as an FPGA output

## Description

Bài này thuộc nhóm Reset và clock. Reset đồng bộ và tick thời gian. Clock hệ thống là OSC chân 28, không phải ADC CLK.

Việc cần làm: Document the ADC clock pin as an FPGA output. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Pin role.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Bài này dùng LED, 7 thanh, nút, switch, ADC hoặc UART. Chép số chân từ silk của board này vào bảng chân trước khi ghi QSF. Không lấy sơ đồ board khác.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Pin role. Viết nó nằm ở module nào trong RTL của bạn.
3. Liệt kê thanh ghi nào xóa về giá trị an toàn, thanh ghi nào không được xóa.
4. Tính số chu kỳ 50 MHz cho mốc thời gian của bài (1 us, 1 ms, 10 ms hoặc 50 ms).
5. Xác nhận chân clock trong QSF là PIN_28 và SDC là chu kỳ 20 ns.

## Implement

1. Hành vi cần có: Document the ADC clock pin as an FPGA output.
2. Tạo enable một chu kỳ cho đúng mốc thời gian của bài, không chia clock ra chân khác.
3. Reset đồng bộ. Trong reset, carrier tắt và bộ đếm về 0 nếu bài yêu cầu giá trị đã biết.
4. Không nối ADC CLK vào cổng clock của FPGA.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Bấm reset hoặc nạp lại. Giá trị hiển thị phải về đúng mặc định.
4. Đọc setup slack. Slack âm vì TimeQuest giả định 1 ns nghĩa là thiếu SDC, chưa phải lỗi 50 MHz.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- Sau reset, trạng thái về giá trị đã ghi trong RTL. Tick xảy ra đúng mốc của bài, đo bằng LCD hoặc LED.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Document the ADC clock pin as an FPGA output.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Sửa bộ đếm thời gian mà vẫn biết reset để lại giá trị nào. O-RU cần cùng thói quen đó cho frame và symbol. Riêng bài 065, thói quen đó là: Pin role.
