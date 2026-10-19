# 292 — Ramp the gain over 16 samples

## Description

Bài này thuộc nhóm Gain và số học. Gain bằng dịch bit và bão hòa. EP1C6 không có nhân cứng.

Việc cần làm: Ramp the gain over 16 samples. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Gain ramp.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Chưa dùng chân LED, 7 thanh, nút hoặc switch trong bài này thì chưa gán các chân đó.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Gain ramp. Viết nó nằm ở module nào trong RTL của bạn.
3. Tính độ rộng ngõ ra sau phép dịch hoặc cộng.
4. Chọn quy tắc bão hòa cho mã dương lớn nhất và mã âm nhỏ nhất.
5. Quyết định gain đổi ngay hay đợi biên symbol.

## Implement

1. Hành vi cần có: Ramp the gain over 16 samples.
2. Viết đúng phép trong tên bài bằng dịch hoặc cộng, không gọi multiplier IP.
3. Cờ saturation bật khi kết quả bị kẹp.
4. Mute là gain 0 và ra đúng số 0.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Đưa mã lớn nhất. Kết quả nằm ở trần, cờ saturation bật.
4. Đưa mã nhỏ. Dịch phải không được thành số rác vì thiếu mở rộng dấu.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- LCD hiện gain và số mẫu bị bão hòa. Không có tràn vòng từ max về một số âm.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Ramp the gain over 16 samples.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Đổi độ rộng gain trên O-RU thì sửa cùng lúc phép bão hòa và test ở hai đầu dải. Riêng bài 292, thói quen đó là: Gain ramp.
