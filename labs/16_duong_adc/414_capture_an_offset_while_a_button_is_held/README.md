# 414 — Capture an offset while a button is held

## Description

Bài này thuộc nhóm Đường ADC. Đọc ADC0809 để quan sát mức vào. Clock đưa ra ADC không phải clock FPGA.

Việc cần làm: Capture an offset while a button is held. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Zero cal.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Bài này dùng LED, 7 thanh, nút, switch, ADC hoặc UART. Chép số chân từ silk của board này vào bảng chân trước khi ghi QSF. Không lấy sơ đồ board khác.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Zero cal. Viết nó nằm ở module nào trong RTL của bạn.
3. Chép chân dữ liệu, start, EOC, address và clock ADC từ silk.
4. Xác nhận clock hệ thống vẫn là chân 28.
5. Chọn chu kỳ start-convert chậm hơn thời gian chuyển đổi của ADC.

## Implement

1. Hành vi cần có: Capture an offset while a button is held.
2. Phát xung clock và start cho ADC từ FPGA.
3. Lấy mẫu vào thanh ghi chỉ khi chuyển đổi xong.
4. Làm thêm đúng thống kê của bài: min, max, trung bình, hoặc alarm.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Đổi điện áp hoặc tín hiệu vào. Mã trên LCD đổi chiều đúng.
4. Giữ nút freeze nếu bài có. Mã phải đứng yên dù ngõ vào đổi.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- Mã ADC ổn định, alarm đúng ngưỡng đã chọn, và clock FPGA vẫn lấy từ chân 28.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Capture an offset while a button is held.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Đường quan sát ngõ vào giúp khoanh vùng lỗi trước khi sửa datapath. Riêng bài 414, thói quen đó là: Zero cal.
