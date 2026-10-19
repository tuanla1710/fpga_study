# 463 — Alarm when timing is late

## Description

Bài này thuộc nhóm Alarm và fault. Chốt lỗi, xóa đúng điều kiện, và tắt carrier khi fault.

Việc cần làm: Alarm when timing is late. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Timing alarm.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Chưa dùng chân LED, 7 thanh, nút hoặc switch trong bài này thì chưa gán các chân đó.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Timing alarm. Viết nó nằm ở module nào trong RTL của bạn.
3. Viết mã alarm, mức nghiêm trọng, và cách xóa: ngay, hay chỉ khi nguyên nhân đã hết.
4. Quyết định carrier có bị tắt không.
5. Chỉ ra bit nào trong thanh ghi alarm.

## Implement

1. Hành vi cần có: Alarm when timing is late.
2. Latch đúng lỗi của bài.
3. Nút clear không xóa được nếu bài yêu cầu nguyên nhân phải hết trước.
4. FAULT tắt carrier nếu bài nói protect.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Gây lỗi. LCD hiện mã, LED báo, carrier tắt nếu bài yêu cầu.
4. Xóa. Lỗi chỉ biến mất theo đúng quy tắc đã viết.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- Một nguyên nhân tạo một mã ổn định. Xóa sai cách không được đưa máy về RUN khi lỗi còn.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Alarm when timing is late.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Sửa xử lý fault trên O-RU là sửa cả lúc vào lỗi và lúc được phép chạy lại. Riêng bài 463, thói quen đó là: Timing alarm.
