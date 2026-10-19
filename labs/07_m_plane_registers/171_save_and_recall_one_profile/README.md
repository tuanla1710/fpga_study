# 171 — Save and recall one profile

## Description

Bài này thuộc nhóm M-plane registers. Map thanh ghi: bản đang sửa và bản đang chạy.

Việc cần làm: Save and recall one profile. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Profile.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Chưa dùng chân LED, 7 thanh, nút hoặc switch trong bài này thì chưa gán các chân đó.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Profile. Viết nó nằm ở module nào trong RTL của bạn.
3. Vẽ địa chỉ, bit, quyền đọc hoặc ghi, giá trị reset.
4. Chỉ ra bit reserved phải đọc về 0.
5. Quyết định thao tác nào mới copy bản edit sang bản active.

## Implement

1. Hành vi cần có: Save and recall one profile.
2. Thêm đúng một thanh ghi hoặc một quy tắc trong tên bài.
3. Không đổi địa chỉ cũ trừ khi tên bài bảo đổi địa chỉ.
4. LCD hiện cả giá trị edit và giá trị active khi bài nói về shadow.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Ghi giá trị hợp lệ, Apply, thấy active đổi.
4. Ghi giá trị quá dải hoặc ghi vào ô chỉ đọc. Active không được hỏng.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- Đúng một ô trong map đổi theo tên bài. Reset trả về default đã ghi. Bit reserved vẫn là 0.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Save and recall one profile.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Sửa register map của O-RU gồm địa chỉ, default, range check, và phân biệt cấu hình nháp với cấu hình đang chạy. Riêng bài 171, thói quen đó là: Profile.
