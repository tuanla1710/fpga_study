# 262 — Hold the data when valid is low

## Description

Bài này thuộc nhóm Đường IQ. Đường mẫu có valid, stall, và độ trễ pipeline.

Việc cần làm: Hold the data when valid is low. Thói quen mang sang FPGA O-RU đang chạy ở công ty: Bubble.

Board EP1C6 chỉ để luyện. Hiệu năng thấp là cố ý. Bài không thay solution O-RU của công ty.

## Prepare

1. Bật nguồn board. Công tắc RUN/PROG để RUN. Cáp USB-Blaster cắm header JTAG, không cắm header AS.
2. Mở Quartus II 11.0 Web Edition. Device EP1C6Q240C8. Clock hệ thống là PIN_28. File SDC có `create_clock -name clk -period 20.000 [get_ports clk]` khi oscillator là 50 MHz.
3. Làm việc trong thư mục này để file .sof của bài không lẫn với bài khác.
4. Chân LCD đã biết, chỉ gán khi bài dùng LCD: D0–D7 = 223–216, RS 215, RW 214, E 213. RW buộc 0. Không gán lcd_on và lcd_blon.
5. Chưa dùng chân LED, 7 thanh, nút hoặc switch trong bài này thì chưa gán các chân đó.

## Research

1. Đọc tên bài và viết một câu: xong bài này thì trên board nhìn thấy gì.
2. Thói quen cần mang sang O-RU của công ty: Bubble. Viết nó nằm ở module nào trong RTL của bạn.
3. Đếm số chu kỳ đường dữ liệu mới thêm.
4. Liệt kê tín hiệu phải trễ cùng mẫu: valid, strobe, last, antenna.
5. Chỉ ra lúc nào được giữ mẫu cũ khi valid thấp.

## Implement

1. Hành vi cần có: Hold the data when valid is low.
2. Sửa đúng biến đổi I hoặc Q trong tên bài.
3. Nếu thêm một tầng pipeline, delay valid đúng số chu kỳ đó.
4. Bão hòa khi cắt bit. Không để tràn im lặng.
5. Giữ unused pin ở dạng input tri-stated.
6. Comment ngắn ngay chỗ sửa: vì sao sửa, giá trị reset là gì.

## Test

1. Biên dịch bằng Quartus 11: `C:\altera\11.0\quartus\bin\quartus_sh.exe --flow compile` trong thư mục project của bài.
2. Đọc số error trước, rồi mới đọc setup slack. Slack âm do chu kỳ 1 ns là thiếu SDC.
3. So sánh mẫu vào và mẫu ra trên LCD ở cùng một strobe.
4. Tạo một bubble. Mẫu không được nhân đôi hoặc mất.
5. Nạp .sof bằng JTAG: `quartus_pgm.exe -c "USB-Blaster [USB-0]" -m JTAG -o "p;<đường dẫn file .sof>"`. Mode JTAG, không nạp .pof trong bài này.
6. Tắt nguồn rồi bật lại. Image .sof mất. Đó là kết quả đúng của cấu hình SRAM.

## Expected results

- Biên dịch xong với 0 error.
- I và Q ra đúng quy tắc của bài, và strobe vẫn chỉ vào đúng mẫu sau khi thêm độ trễ.
- Nhìn trên board hoặc trong log và chỉ được đúng việc này: Hold the data when valid is low.
- Tắt nguồn làm mất image .sof. Nếu bài chưa nạp .pof thì đó không phải lỗi.

## What you learned

Thêm pipeline trên datapath O-RU thì mọi tín hiệu đi kèm mẫu phải trễ bằng nhau. Riêng bài 262, thói quen đó là: Bubble.
