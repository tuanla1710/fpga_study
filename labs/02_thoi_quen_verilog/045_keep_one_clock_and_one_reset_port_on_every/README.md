# 045 — Keep one clock and one reset port on every module

## Description

Bài này thuộc nhóm Thói quen Verilog. Cách viết RTL để người sau sửa một module mà không tạo latch hay sai độ rộng.

Việc cần làm: Keep one clock and one reset port on every module. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Common ports.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Chưa dùng chân LED, 7 thanh, nút hoặc switch trong bài này thì chưa gán các chân đó.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Common ports. Viết nó nằm ở module nào trong RTL của bạn.
3. Khoanh vùng module sẽ sở hữu hành vi của bài. Ghi port clock và reset.
4. Liệt kê hằng số đang viết thẳng số. Chọn tên localparam thay cho số đó.
5. Tìm nhánh case hoặc if chưa gán đủ. Đó là chỗ dễ thành latch.

## Implement

1. Hành vi cần có: Keep one clock and one reset port on every module.
2. Viết đúng một quy tắc trong tên bài. Giữ các quy tắc đã đúng của bài trước.
3. Dùng gán nonblocking trong khối luôn theo clock.
4. Thêm một dòng đầu file: module này sở hữu gì.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. Biên dịch và đọc warning liên quan tới latch, width, hoặc suy ra RAM ngoài ý muốn.
4. Đối chiếu RTL với ghi chú đầu file. Hai bên phải cùng tên trạng thái và cùng độ rộng.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- RTL thể hiện đúng quy tắc của bài, biên dịch 0 error, và warning còn lại có một câu giải thích vì sao chấp nhận.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Keep one clock and one reset port on every module.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Một thay đổi nhỏ để lại diff dễ đọc. Đó là cách sửa code O-RU mà người khác còn theo được. Riêng bài 045, thói quen đó là: Common ports.
