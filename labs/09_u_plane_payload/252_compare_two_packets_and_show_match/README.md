# 252 — Compare two packets and show MATCH

## Description

Bài này thuộc nhóm U-plane payload. Gói mẫu IQ kèm header: frame, symbol, sequence.

Việc cần làm: Compare two packets and show MATCH. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Compare.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Chưa dùng chân LED, 7 thanh, nút hoặc switch trong bài này thì chưa gán các chân đó.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Compare. Viết nó nằm ở module nào trong RTL của bạn.
3. Vẽ thứ tự byte: header rồi payload, độ dài cố định hay thay đổi.
4. Chỉ ra sequence tăng theo sự kiện nào.
5. Quyết định carrier tắt hoặc không có section thì payload phải là 0.

## Implement

1. Hành vi cần có: Compare two packets and show MATCH.
2. Thêm đúng field hoặc cờ trong tên bài.
3. Giữ frame id và symbol id đã có. Không ghi đè chúng khi thêm byte mới.
4. Hiện header cuối lên LCD để soi.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Bắt một gói. Đối chiếu length, sequence và id với bộ đếm timing.
4. Tắt carrier. Payload phải về 0 trong khi header vẫn nói đúng frame.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- Gói của bài có đúng field được yêu cầu, sequence không nhảy khi không có symbol mới, và mute thật sự ra số 0.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Compare two packets and show MATCH.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Sửa header U-plane mà vẫn giữ frame id và sequence để phía nhận còn ghép được. Riêng bài 252, thói quen đó là: Compare.
