# Checklist test trên board đang có

Board: Cyclone **EP1C6Q240C8N** (vỏ PQFP 240 chân, speed grade C8, không chì).  
JTAG IDCODE: `020820DD`.  
Cáp: Altera USB-Blaster `USB\VID_09FB&PID_6001`, serial `8A0K7PIR`, cổng `USB-Blaster [USB-0]`.

Chip này có khoảng 5 980 logic element, 20 khối RAM M4K (92 160 bit), 2 PLL, khoảng 185 chân I/O. Không có bộ nhân cứng, không có transceiver. Dùng để học mạch số và thói quen nạp FPGA. Không chạy được O-RAN RU thật (eCPRI, JESD204, low-PHY).

Đánh dấu `[x]` khi làm xong một mục.

## Đã kiểm tra

- [x] Windows thấy USB-Blaster, driver `usbblstr.inf` đã gắn, trạng thái OK
- [x] Không có cổng COM. Board này nói chuyện bằng JTAG, không phải UART ảo
- [x] Nguồn board sáng, công tắc RUN/PROG để RUN
- [x] Đầu cáp 10 chân có nẫy, chỉ cắm được một chiều
- [x] Cắm đúng hàng JTAG thì `jtagconfig` đọc được `020820DD EP1C6`
- [x] Mã in trên chip là `EP1C6Q240C8N`. Trong Quartus chọn `EP1C6Q240C8`
- [x] Có mã nguồn LCD: `lcd_hello.v`, testbench `tb_lcd_hello.v`
- [ ] Chưa cài Quartus II Web Edition 11.0 SP1, nên chưa biên dịch ra `.sof`
- [ ] Chưa có sơ đồ chân LCD, chưa gán chân, chưa nạp

Lệnh kiểm tra lại cáp:

```text
C:\altera\24.1std\qprogrammer\bin64\jtagconfig.exe
```

Kết quả đúng:

```text
1) USB-Blaster [USB-0]
  020820DD   EP1C6
```

## Phải có trước khi test trên board

- [ ] Tải và cài [Quartus II Web Edition 11.0 SP1](https://www.altera.com/downloads/fpga-development-tools/quartus-ii-web-edition-design-software-version-11-0-b123-windows), file `11.0sp1_quartus_free_windows.exe`, vào `C:\altera\11.0sp1`
- [ ] Mở Quartus 11.0, tạo project, device = `EP1C6Q240C8`
- [ ] Xác định chân clock trên board (thường là dao động 50 MHz) và ghi số chân vào project
- [ ] Chụp hoặc chép sơ đồ chân các khối nhìn thấy trên board: LCD, LED, nút, switch

Quartus 24.1 ở `C:\altera\24.1std\qprogrammer` chỉ dùng để nạp và chạy `jtagconfig`. Bản đó không biên dịch cho EP1C6.

## Nhìn board và đánh dấu những gì thực sự có

Chỉ tick khi mắt thấy linh kiện hoặc chữ in trên board. Chưa thấy thì để trống, không đoán chân.

- [ ] LCD ký tự (1602 hoặc tương đương HD44780)
- [ ] LED đơn
- [ ] Công tắc gạt (switch)
- [ ] Nút nhấn
- [ ] LED 7 đoạn
- [ ] Còi
- [ ] Chân UART (TX/RX)
- [ ] VGA
- [ ] RAM rời (SRAM/SDRAM)
- [ ] Header mở rộng

## Làm được trên board này

Thứ tự từ dễ đến khó. Mỗi bài xong khi nạp `.sof`, tắt nguồn, bật lại, và hành vi đúng như mô tả.

### 1. Nạp được một thiết kế

- [ ] Compile trong Quartus 11.0 ra `output_files\*.sof`
- [ ] Nạp bằng Programmer, hardware = `USB-Blaster [USB-0]`, mode = JTAG
- [ ] Tắt nguồn rồi bật lại: thiết kế mất. `.sof` chỉ nằm trong FPGA khi còn điện
- [ ] Ghi lại: file `.sof` dùng để test, file `.pof` mới là nạp vào bộ nhớ cấu hình để giữ sau khi mất điện

### 2. Clock và chân ra

- [ ] Led nhấp nháy khoảng 1 Hz từ clock board. Chứng minh clock và một chân ra đúng
- [ ] Đổi tần số nháy bằng cách đổi bộ đếm, nạp lại, thấy LED đổi tốc độ

### 3. Công tắc và nút

Chỉ làm nếu board có switch hoặc nút.

- [ ] Switch bật thì LED sáng, tắt thì LED tắt
- [ ] Nút nhấn có chống dội. Một lần nhấn chỉ đếm một

### 4. LCD hiện `hello`

Mã đã có trong `lcd_hello.v`. Chưa chạy được cho đến khi có số chân.

- [ ] Gán `clk`, `lcd_rs`, `lcd_rw`, `lcd_en`, `lcd_data[7:0]`, và nếu board có thì `lcd_on`, `lcd_blon`
- [ ] Compile và nạp
- [ ] Dòng 1 của LCD hiện `hello`
- [ ] Tắt/bật nguồn, nạp lại, chữ vẫn hiện

### 5. Máy trạng thái

- [ ] Vài nút hoặc switch đổi trạng thái: tắt, sáng, nháy
- [ ] Trạng thái hiện trên LED hoặc LCD

Đây là kiểu điều khiển giống thanh ghi cấu hình sau này, chỉ là bản nhỏ.

### 6. Đếm và hiển thị số

Chỉ làm nếu có LED 7 đoạn hoặc LCD.

- [ ] Đếm giây và hiện số
- [ ] Nút reset đưa bộ đếm về 0

### 7. UART

Chỉ làm nếu board có chân TX/RX và có USB-UART riêng. USB-Blaster hiện tại không tạo cổng COM.

- [ ] FPGA gửi một dòng chữ ra TX
- [ ] Máy tính nhận đúng bằng một cổng COM khác, không phải USB-Blaster

### 8. Mô phỏng trước khi nạp

- [ ] Chạy `tb_lcd_hello.v` và thấy `PASS hello`
- [ ] Mỗi bài mới có một testbench kiểm tra đúng/sai trước khi gắn chân

## Khái niệm O-RAN RU học được từ các bài trên

Làm trên EP1C6 để hiểu việc, không phải để phát sóng.

| Bài trên board | Việc tương ứng trong RU sau này |
| --- | --- |
| Clock, bộ đếm 1 Hz | Tick khung, symbol, slot |
| Switch / nút vào thanh ghi | M-plane ghi gain, tần số, bật tắt carrier |
| Máy trạng thái | Trình tự khởi tạo JESD, fronthaul, low-PHY |
| LCD / LED hiện trạng thái | Quan sát trạng thái khi bring-up |
| UART chữ | Log debug trước khi có eCPRI |
| Testbench | Vector IQ và kiểm tra datapath |

## Không làm trên EP1C6

- [x] Đã loại trừ: eCPRI 10/25 GbE, split 7.2x U-plane/C-plane trên dây
- [x] Đã loại trừ: JESD204B/C tới transceiver RF
- [x] Đã loại trừ: FFT/IFFT low-PHY, DUC/DDC, CFR, DPD băng rộng
- [x] Đã loại trừ: PTP/SyncE

Những mục đó cần FPGA có transceiver và DSP. Giữ chúng ngoài checklist của board này.
