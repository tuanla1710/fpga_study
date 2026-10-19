# 018 — Store the SOF next to a one-line note of what it displays

## Description

Bài này thuộc nhóm Quy trình project. Quy trình biên dịch và nạp image, không phải thuật toán RU.

Việc cần làm: Store the SOF next to a one-line note of what it displays. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Build note.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Chưa dùng chân LED, 7 thanh, nút hoặc switch trong bài này thì chưa gán các chân đó.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Build note. Viết nó nằm ở module nào trong RTL của bạn.
3. Đọc log Quartus 11 và chỉ ra file .sof nằm ở thư mục project, không nằm trong output_files.
4. Phân biệt .sof nạp JTAG (mất khi tắt nguồn) và .pof nạp AS (chưa dùng trong bài này).
5. Ghi lại vì sao project phải mở từ file .qpf. Mở mỗi file .v thì Start Compilation vẫn tắt.

## Implement

1. Hành vi cần có: Store the SOF next to a one-line note of what it displays.
2. Tạo project Quartus II 11.0, family Cyclone, device EP1C6Q240C8.
3. Đặt top-level đúng module của bài này. Không để top trỏ vào file thử cũ.
4. Làm đúng một việc trong tên bài. Không sửa chân LCD nếu bài không đòi hỏi.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Chạy Compile Flow. Dừng ở error đầu tiên, sửa, biên dịch lại.
4. Tìm file .sof vừa sinh. Ghi checksum nếu Programmer hiện checksum.
5. Nếu bài yêu cầu nạp: Hardware là USB-Blaster [USB-0], mode JTAG, file là .sof, ô Program/Configure được chọn, rồi bấm Start.
6. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
7. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- Quartus báo 0 error, file .sof của đúng bài này xuất hiện, và Programmer nhận EP1C6 IDCODE 020820DD khi cáp nằm trên header JTAG.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Store the SOF next to a one-line note of what it displays.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Biết image nào đang nằm trong chip, mở đúng project, và nạp lại được sau một sửa đổi nhỏ. Riêng bài 018, thói quen đó là: Build note.
