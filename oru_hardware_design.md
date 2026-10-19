# Thiết kế O-RU 4T4R, 24 dBm

Máy indoor, split 7.2 Category A. Mỗi cổng anten 24 dBm trung bình. Băng n77, n78, n48 trên nhánh 3,3–4,2 GHz. Băng n79 trên nhánh 4,4–5,0 GHz. Một sóng mang hoặc hai sóng mang, băng thông chọn 10, 20, 40, 50, 60, 80 hoặc 100 MHz, SCS 30 kHz. Phần số dùng gói Sail River trên Agilex 5 SoC. Agilex 7 cùng gói nhưng tốn nguồn hơn, không hợp vỏ 24 dBm.

Giá dưới đây là giá tham chiếu công khai hoặc mức ước lượng cho một bản mẫu, không phải báo giá mua hàng. License Sail River, Quartus và FPGA không có giá niêm yết.

## 1. Kiến trúc

```text
O-DU
  |  SFP28 25 GbE, SyncE + PTP
  v
Agilex 5 SoC
  F-Tile quad A: 25 GbE, refclk 156,25 MHz
  F-Tile quad B: JESD204C, refclk 122,88 MHz
  Fabric: lọc gói, eCPRI, O-RAN, FFT/iFFT, CP, PRACH, DUC/DDC
  HPS: Linux, ptp4l, API M-plane, SPI/I2C
  |  RJ45 MGMT: 1000BASE-T vào HPS, PoE Class 8 vào TPS2373-4
  |
  +-- DDR
  +-- SI5518
  +-- AFE7950  (4 TX, 4 RX, 2 FB)
         |
         +-- 4 lần khối anten
               chọn băng
               nhánh 3,5 GHz hoặc nhánh 4,7 GHz
               PA khoảng 28 dBm -> lọc -> chuyển TDD -> cổng 24 dBm
               coupler -> gom feedback
```

C-plane và U-plane ở fabric. M-plane và S-plane sang HPS. GPIO TDD xuất từ fabric, không từ HPS.

Sail River đã kiểm 20, 60 và 100 MHz, tối đa 2 sóng mang, băng chiếm 200 MHz, băng tức thời 280 MHz, một cổng 25 GbE, nén 9 bit. Các băng thông 10, 40, 50 và 80 MHz thêm trong DSP Builder. JESD giữ nguyên 8110,08 Mb/s.

## 2. Clock

Gốc thời gian radio là 122,88 MHz. Lane JESD 8110,08 Mb/s = 122,88 MHz × 66. Khung 10 ms = 1 228 800 chu kỳ. Symbol hữu ích SCS 30 kHz = 4096 mẫu.

| Clock | Tần số | Từ | Đến |
| --- | --- | --- | --- |
| OCXO | 10 MHz | Dao giữ tần | SI5518 |
| SyncE | clock hồi | F-Tile quad A | SI5518 DSPLL A |
| Ethernet | 156,25 MHz | SI5518 | F-Tile quad A |
| JESD FPGA | 122,88 MHz | SI5518 | F-Tile quad B |
| Radio | 122,88 MHz | SI5518 | Fabric |
| AFE REFCLK | 491,52 MHz | SI5518 | AFE7950 REFCLK+/- |
| SYSREF | theo log GUI AFE | SI5518 | AFE7950 và F-Tile, rồi tắt sau khi link lên |
| 1 PPS | 1 Hz | Để trống | Chỉ lắp khi có GNSS |

Hai refclk 156,25 MHz và 122,88 MHz không được vào cùng một quad transceiver. SYSREF chỉ bật lúc bring-up. Hai đường SYSREF cùng dài. HPS chỉnh DCO của SI5518 theo `ptp4l`. Mất quang thì holdover trên OCXO.

Đổi băng thông không đổi clock. Đổi n77 sang n79 chỉ đổi NCO của AFE.

## 3. Nguồn, dư 10% so với công suất max

24 dBm là mức tại cổng anten. PA bù suy hao lọc và chuyển mạch, nên ngõ ra PA khoảng 28 dBm. Nguồn không tính theo 24 dBm. Nguồn tính theo lúc bốn PA phát cùng lúc, AFE và FPGA ở mode nặng nhất.

Các số watt của FPGA là ngân sách thiết kế, chưa phải số đo. Sau khi có project Sail River phải chạy Power Analyzer rồi khóa lại. Số của AFE lấy từ các mode trong datasheet AFE7950, có mode gần 9 W.

| Tải | Max tại chân linh kiện | Cách tính |
| --- | --- | --- |
| Agilex 5, HPS, 25 GbE, JESD | 35 W | FFT 4T4R chạy liên tục, RAM và DSP đầy, cộng transceiver. 18 W chỉ đủ lúc fabric nghỉ |
| AFE7950 | 9,5 W | Datasheet, làm tròn lên từ mode khoảng 9 W |
| DDR | 2 W | |
| SI5518 | 1,2 W | |
| OCXO lúc khởi động | 2,5 W | |
| SFP28 | 1,5 W | |
| Bốn PA phát cùng lúc | 21 W | 28 dBm mỗi PA, hiệu suất 12% lúc OFDM backoff |
| LNA, chuyển TDD, logic | 2 W | |
| Cảm biến | 0,5 W | |
| Tổng tại tải | 75,2 W | |
| Tổn hao POL, hiệu suất 85% | 13,3 W | 75,2 / 0,85 − 75,2 |
| Công suất vào 12 V | 88,5 W | |
| Dư 10% | 8,8 W | |
| Ngưỡng nguồn phải chịu | 97,3 W | 8,1 A ở 12 V |

18 W bỏ. Con số đó không gồm FFT bốn anten chạy liên tục, cũng không gồm lane 25 GbE và tám lane JESD luôn bật. Trên Sail River, cấu hình 4T4R hai sóng mang dùng khoảng 61% logic, 95% RAM và 45% DSP của một Agilex 5 cỡ A5E065. Transceiver cộng fabric ở mức đó là khoảng 35 W cho đến khi Power Analyzer cho số thật. Agilex 7 còn cao hơn, nên máy này giữ Agilex 5.

Nguồn 12 V ghi trên nhãn phải còn ít nhất 97 W sau khi giảm công suất theo nhiệt. Ở +70 °C nhiều bộ nguồn chỉ còn khoảng 60% công suất nhãn. Nhãn cần khoảng 97 / 0,6 = 162 W. Chọn bộ 12 V, 15 A, 180 W, dải −40 °C đến +85 °C. Điện áp vào vẫn là 12 V.

Mỗi rail cũng dư 10% dòng so với dòng max của tải trên rail đó, không chỉ dư ở đầu 12 V.

| Rail | Việc | Nâng cấp so với bản trước |
| --- | --- | --- |
| 12 V vào | Cầu chì, chống ngược cực, TVS, lọc EMI, hạn dòng khởi động | Bản trước chỉ ghi 12 V |
| Core FPGA | POL đúng thứ tự bật của Agilex, có PG và đo dòng | Không dùng một POL chung |
| 0,9 V và 1,2 V AFE | POL riêng, tụ sát ball | |
| VDDA 1,8 V AFE | LDO sau POL, không chung với 1,8 V số | Tách analog |
| 5 V PA | Bốn cầu chì điện tử, mỗi anten một đường, cắt bằng GPIO TDD | Một rail 5 V chung không đủ để cô lập lỗi |
| 3,3 V clock và SFP | POL riêng | |

Nguồn đầy tải vẫn là bộ 12 V, 180 W. Cổng MGMT mang thêm PoE Class 8. PoE chỉ nuôi máy khi HPS đã giới hạn PA, vì chuẩn dừng ở 71,3 W.

Cảnh báo đi vào HPS khi dòng 12 V vượt 90% của 8,1 A, tức khoảng 7,3 A, hoặc khi một PA vượt dòng định mức. FPGA, AFE và bốn PA tản qua vỏ nhôm bằng pad nhiệt. Không dựa vào quạt, vì quạt là điểm hỏng và là lỗ xuyên nhiễu.

24 dBm là mức tại cổng anten. PA bù suy hao lọc và chuyển mạch.

| Điểm | Mức trung bình |
| --- | --- |
| Cổng anten | 24 dBm |
| Sau chuyển TDD | khoảng 25 dBm |
| Sau lọc gốm hoặc BAW | khoảng 27 dBm |
| Ngõ ra PA | khoảng 28 dBm |

Đỉnh OFDM cao hơn khoảng 8 dB nếu chưa CFR. PA và chuyển mạch phải chịu đỉnh đó. DPD chưa bắt buộc ở 24 dBm. Coupler khoảng 20 dB vẫn gắn để đo.

Rail 48 V chỉ nằm ở phía sơ cấp cách ly của bộ PoE. PA, FPGA và clock không có rail 48 V.

## 4. Cổng MGMT, nguồn PoE và cổng debug

Một RJ45 làm cả hai việc: Ethernet quản lý vào HPS, và nguồn PoE vào chip PD. Fronthaul vẫn là SFP28, không đi chung cáp này.

Chip nguồn là **TPS2373-4** của TI, PD IEEE 802.3bt Type 4, Class 8. Datasheet ghi mức nhận được khoảng 71,3 W. Bản đánh giá TPS2373-4EVM-758 là bộ 70 W. Không dùng TPS23734. Chip đó chỉ tới Class 4, khoảng 25,5 W.

PHY quản lý là **DP83867**, RGMII vào EMAC của HPS. PHY lấy 3,3 V và 2,5 V sau diode-OR, không lấy từ phía 48 V.

Sau bộ chuyển từ 48 V xuống 12 V, rail 12 V chỉ còn khoảng 60 W. Đủ cho FPGA, AFE, clock, PHY và các cổng debug, không đủ bốn PA phát hết công suất. Khi chỉ cắm PoE, HPS đọc chân BT và chỉ bật một hoặc hai PA. Bốn PA chỉ bật khi có nguồn 12 V, 180 W.

```text
RJ45 MGMT, magjack bốn cặp, chịu Class 8
  dữ liệu, sau biến áp
        -> DP83867 -> RGMII -> HPS
  điểm giữa bốn cặp
        cặp 1-2 và 3-6 -> cầu chỉnh lưu A
        cặp 4-5 và 7-8 -> cầu chỉnh lưu B
        hai cực dương nối VDD, hai cực âm nối VSS
TPS2373-4
  DEN: 24,9 kΩ lên VDD
  CLSA, CLSB xuống VSS qua điện trở Class 8 trong datasheet
  RTN -> mass sơ cấp của bộ chuyển cách ly 48 V sang 12 V
  PG, TPH, TPL, BT -> opto -> HPS
  APD -> phát hiện jack 12 V. Có 12 V thì ngắt MOSFET PoE
Bộ chuyển cách ly -> diode OR với jack 12 V -> lọc EMI -> POL
Cổng debug lấy 3,3 V từ LDO sau diode-OR, qua eFuse khoảng 0,5 A
```

Jack 12 V luôn thắng nếu cắm cả hai. PoE không đi thẳng vào rail 5 V của PA. Header debug không có chân 12 V. JTAG, UART, SPI và I2C vẫn sống khi chỉ cắm cáp MGMT, vì chúng nằm sau bộ chuyển 12 V. Mức logic của header theo bank HPS, không cắm adapter 5 V TTL.

## 5. Sơ đồ nối để đường cao tốc ngắn

Không gán số ball Agilex trong file này. Số ball phụ thuộc mã OPN và phải lấy từ Pin Planner sau khi mở project Sail River. Số ball AFE lấy từ datasheet AFE7950 Rev. E, gói 400 ball, 17 mm × 17 mm. Dưới đây là luật nối để đường 8 Gb/s và clock không bị kéo chéo.

Xếp trên mạch, từ cổng quang vào trong:

```text
SFP28 -- quad A của F-Tile -- HPS và DDR
                |
             SI5518 nằm giữa F-Tile và AFE
                |
             AFE7950 đối diện quad B
                |
             bốn cụm RF sát chân analog của AFE
```

Quad A chỉ nhận 156,25 MHz. Quad B chỉ nhận 122,88 MHz. Không đi chung refclk.

### JESD, 8 lane, 8110,08 Mb/s

AFE có 8 lane, tối đa 29,5 Gb/s. Thiết kế này không dùng 29,5 Gb/s. Giữ 8,11 Gb/s cho khớp IP Sail River và để mạch in dễ hơn. Lane xếp liền trong một quad, không đảo thứ tự, không bắc qua quad khác.

| Tín hiệu AFE | Chiều dữ liệu | Tín hiệu FPGA | Việc |
| --- | --- | --- | --- |
| SRX1+/- đến SRX4+/- | FPGA phát, AFE nhận | TX quad B, lane 0–3 | Mẫu DAC, bốn anten |
| STX1+/- đến STX4+/- | AFE phát, FPGA nhận | RX quad B, lane 0–3 | Mẫu ADC, bốn anten |
| STX5+/- đến STX6+/- | AFE phát, FPGA nhận | RX quad B, lane 4–5 | Hai feedback |
| SRX5+/- đến SRX8+/- | Không dùng ở bản này | Để trống, có termination theo datasheet | Dự phòng |
| REFCLK+/- | SI5518 vào AFE | 491,52 MHz, cặp vi sai | PLL lấy mẫu RF |
| SYSREF+/- | SI5518 vào AFE và vào quad B | Cùng nguồn, cùng dài | Căn subclass 1, rồi tắt |

STX của AFE là đầu ra. SRX của AFE là đầu vào. Nối ngược chiều này thì link không lên.

Mỗi cặp vi sai cùng chiều dài trong cặp, chênh giữa các lane dưới mức mà IP JESD cho phép ở 8,11 Gb/s. AC-couple trên lane nếu datasheet của cả hai đầu yêu cầu. Không đi lane dưới phần nguồn PA.

### Clock và điều khiển

| Tín hiệu | Nối | Tối ưu |
| --- | --- | --- |
| SI5518 ra 156,25 MHz | Refclk quad A | Ngắn, không đi gần PA |
| SI5518 ra 122,88 MHz | Refclk quad B và clock fabric | Cùng chip với SYSREF |
| SI5518 ra 491,52 MHz | AFE REFCLK+/- | Ngắn nhất trong các clock analog |
| SYSREF | AFE và quad B | Ghép độ dài, tắt sau bring-up |
| SPICLK, SPISEN, SPISDIO, SPISDO | HPS SPI | 1,8 V, chung RESETZ |
| RESETZ | HPS GPIO | Xung tối thiểu 1 ms theo datasheet AFE |
| GPIO TDD | Fabric bank 1,8 V | Tới enable PA và chuyển TDD, không qua HPS |
| Chọn băng n77 hoặc n79 | Fabric GPIO | Một bit cho bốn anten, vì cả máy cùng một băng tại một thời điểm |
| LOS, lock của SI5518 | HPS | Báo M-plane khi mất SyncE |

SPI của AFE không lấy từ bank transceiver. Bank đó để dành cho JESD và 25 GbE.

### Một anten

```text
AFE TXx -> driver -> PA 3,5 GHz hoặc PA 4,7 GHz
        -> coupler -> lọc -> chuyển TDD -> cổng anten
coupler -20 dB -> chuyển 4 chọn 2 -> AFE FB0 hoặc FB1
cổng anten -> chuyển TDD -> lọc -> LNA -> AFE RXx
```

Bốn coupler gom vào hai cổng FB. Hai anten một cặp, vì AFE7950 chỉ có hai feedback. Ở 24 dBm, feedback chỉ để đo. DPD gắn sau nếu ACLR chưa đạt.

Nhánh 3,5 GHz và nhánh 4,7 GHz không phát cùng lúc trên một anten. Một bit chọn băng cắt enable PA đang nghỉ.

## 6. Môi trường và chống nhiễu

Máy 24 dBm vẫn phải chịu điều kiện khắc nghiệt. Mục tiêu thiết kế, chưa phải giấy chứng nhận:

| Việc | Mốc |
| --- | --- |
| Nhiệt độ làm việc | −40 °C đến +70 °C ngoài vỏ |
| Nhiệt độ tồn trữ | −40 °C đến +85 °C |
| Rung, xóc | MIL-STD-810H, Method 514 và 516 |
| Ẩm, sương muối | MIL-STD-810H, Method 507 và 509. Vỏ kín, van Gore |
| Phát xạ và miễn nhiễm | MIL-STD-461G: CE102, CS101, CS114, CS115, CS116, RE102, RS103 |
| ESD cổng ngoài | IEC 61000-4-2, mức 4 |

Thành phần phải thêm:

- Vỏ nhôm liền, gioăng dẫn điện, nắp bắt vít đều. Mạch số, AFE và PA nằm trong ba khoang.
- Nắp chắn trên Agilex, trên AFE và trên cụm PA.
- Lọc nguồn đầu vào, không đưa 12 V thẳng vào POL.
- Cổng anten là cổng ra vỏ duy nhất của RF. Fronthaul chỉ dùng quang, không dùng đồng 25 GbE.
- Linh kiện nhiệt công nghiệp hoặc ô tô, không dùng grade thương mại 0–70 °C cho OCXO, DDR, POL và PA.
- Phủ conformal sau khi hết giai đoạn sửa lỗi.
- Vít tiếp địa vỏ ở một điểm sao, tách đất analog AFE và đất PA.

## 7. Cổng debug và phát triển

RJ45 MGMT nằm ở mép vỏ, cạnh cụm debug. Cáp MGMT vừa là Ethernet quản lý vừa là nguồn PoE. Các header còn lại nằm sau nắp, không để hở khi vận hành.

| Cổng | Việc | Nguồn |
| --- | --- | --- |
| RJ45 MGMT | 1000BASE-T vào HPS qua DP83867. PoE vào TPS2373-4 | Class 8 trên cáp, dữ liệu cách ly bằng biến áp |
| JTAG FPGA | Nạp và biên dịch lại khi sửa DSP Builder | 3,3 V sau diode-OR, eFuse 0,5 A |
| UART HPS | Console Linux | Cùng rail 3,3 V đó |
| Header SPI | Đọc trực tiếp AFE7950 và SI5518 khi phần mềm chưa lên | Cùng rail, mức theo bank HPS |
| I2C | Cảm biến nhiệt và EEPROM hiệu chuẩn | Cùng rail |
| U.FL 10 MHz | So clock với máy chuẩn | Không cấp nguồn ra đầu nối |
| U.FL 1 PPS | So pha PTP | Không cấp nguồn ra đầu nối |
| Hàng test point | Đo khi mất nguồn, mất clock, rớt JESD, chết một anten hoặc mất MGMT | Không cấp nguồn. Mỗi cụm có một pad đất cạnh đó |
| PMBus hoặc sense dòng | Đo từng rail, đối chiếu ngân sách 97 W | Sense, không lấy tải từ đầu đo |
| LED trong vỏ | Nguồn, lock PTP, lock JESD, lỗi PA, nguồn đang là PoE hay jack 12 V | Rail 3,3 V |

Chỉ cắm PoE thì JTAG và UART vẫn dùng được. Bốn PA không bật hết trong trạng thái đó.

Test point nằm sau nắp, in tên trên mặt mạch, để hở khi phủ conformal. Mỗi cụm có một pad đất ngay cạnh để kẹp mass của máy đo cho ngắn. Không khoét lỗ ra vỏ.

Không hàn que đo thẳng vào cặp JESD 8,11 Gb/s, vào REFCLK 491,52 MHz, hay vào refclk của F-Tile. Những đường đó chỉ xem qua bản sao đã đi qua buffer, hoặc qua điện trở nối tiếp khoảng 1 kΩ trên một bản copy. Lane dữ liệu không có test point.

Phía sơ cấp PoE có thể tới khoảng 57 V. Các điểm đó xếp riêng, cách hàng 1,8 V và 3,3 V.

| Triệu chứng | Điểm đo | Thấy gì thì kết luận |
| --- | --- | --- |
| Không lên nguồn | 12 V trước eFuse, 12 V sau eFuse, PG của từng POL | Mất trước eFuse là jack hoặc cầu chì. Mất sau eFuse là hạn dòng hoặc ngược cực. PG một rail xuống là POL đó chưa bật, xem thứ tự nhóm 1 rồi 2A rồi 2B của Agilex |
| Rail nào đó sụt khi phát | Sense dòng 12 V, sense từng PA, 0,9 V và 1,2 V AFE, core FPGA | Dòng 12 V trên khoảng 7,3 A là quá 90% ngân sách. Một PA cao hơn các anten kia là lỗi anten đó |
| Cắm PoE mà không chạy | VDD của TPS2373-4, PG, BT và TPH/TPL sau opto | Không có VDD là cáp hoặc cầu chỉnh lưu. Có VDD mà PG chưa lên là bộ chuyển 48 V sang 12 V. BT không báo Type 4 là switch không cấp Class 8 |
| Cắm cả hai nguồn mà vẫn yếu | APD, PG của jack 12 V | APD thấp thì MOSFET PoE chưa nhả, jack 12 V chưa thắng |
| Không khóa PTP hoặc SyncE | U.FL 10 MHz của OCXO, LOS và lock của SI5518, bản sao 122,88 MHz và 156,25 MHz | OCXO chết thì cả cây clock chết. LOS lên mà OCXO còn là mất SyncE trên quang. 122,88 MHz mất mà 10 MHz còn là SI5518 |
| JESD không lên | SYSREF qua buffer, RESETZ của AFE, lock JESD đưa ra GPIO | SYSREF phải có vài cạnh lúc bring-up rồi tắt. RESETZ phải xuống ít nhất 1 ms. Lock không lên sau đó thì xem SPI và thứ tự lane, không đo trực tiếp cặp vi sai |
| Một anten không phát | Enable PA anten đó, bit chọn băng, TDD, U.FL lấy từ coupler −20 dB | Enable thấp là GPIO hoặc eFuse PA đã cắt. Đúng enable mà U.FL không có sóng là PA hoặc lọc. U.FL có sóng mà cổng anten không có là chuyển TDD hoặc đầu nối |
| Phát nhầm băng | Bit chọn n77 hoặc n79, enable của PA đang phải tắt | Hai enable cùng cao là lỗi phần mềm. Chỉ một băng được bật |
| Thu ồn hoặc không thu | Nguồn LNA, đường TDD phía thu | LNA mất nguồn thì bốn anten thu cùng chết. Một anten thì xem chuyển TDD của anten đó |
| MGMT không link | Điện trở nối tiếp trên RX_CLK của RGMII, chân reset PHY, LED link của DP83867 | PHY không reset được thì HPS chưa cấp clock quản lý. LED link tắt mà PHY đã có nguồn là cáp hoặc biến áp |
| Cắt vì nóng | Cảm biến trên vỏ FPGA, trên AFE, trên từng PA, đọc qua I2C | Một PA nóng hơn ba PA kia là anten đó. Cả FPGA nóng là tải số, không phải PA |

U.FL của coupler chỉ để đo khi nắp mở. Khi vận hành, đường đo đó nối vào feedback của AFE, không để hở.

## 8. BOM và giá

Giá linh kiện bán lẻ là mốc tham chiếu, một chiếc, khoảng tháng 10/2026. Hàng FPGA, license và lọc khoang phải hỏi hãng. Cột giá để trống khi không có niêm yết đáng tin.

| Hạng mục | Mã | SL | Giá tham chiếu | Ghi chú |
| --- | --- | --- | --- | --- |
| FPGA SoC | Agilex 5 E-series hoặc D-series, mã nằm trong Sail River, ví dụ họ A5E | 1 | Báo giá Altera | Không mua Agilex 7 cho máy 24 dBm trừ khi đo nguồn còn dư |
| License công cụ | Quartus Prime cho Agilex, DSP Builder | 1 | Báo giá Altera | Bản free không tổng hợp được dòng này |
| Workload O-RU | Gói Sail River | 1 | Báo giá Altera | Có eCPRI, O-RAN, JESD, low-PHY, DUC/DDC |
| AFE | AFE7950IABJ, 400 ball | 1 | Khoảng 2 130 USD / chiếc trên [LCSC](https://www.lcsc.com/product-image/C3606796.html), mức 1 chiếc. Mức 1 000 chiếc khoảng 1 890 USD. Hết hàng tại thời điểm xem | Datasheet [Rev. E](https://www.ti.com/lit/ds/symlink/afe7950.pdf). Giá TI trực tiếp hỏi TI |
| Clock | SI5518 | 1 | Hỏi Skyworks | Một mã phân phối ghi khoảng 27 USD. Mức đó thấp bất thường với dòng NetSync, không dùng làm giá đặt hàng |
| OCXO | 10 MHz, loại giữ được holdover PTP | 1 | Khoảng 50 đến 200 USD | Thạch anh thường không đủ 30 phút holdover |
| Nhớ | DDR cho HPS, đúng loại mà board Agilex 5 hỗ trợ | 1 cụm | Khoảng 20 đến 60 USD | |
| Quang | SFP28 25 GbE SR và lồng SFP | 1 | Khoảng 30 đến 80 USD | |
| PA | Hai PA small cell mỗi anten, khoảng 28 dBm, một con 3,3–4,2 GHz và một con 4,4–5,0 GHz | 8 | Khoảng 15 đến 40 USD mỗi con | Không dùng PA GaN 8 W, 48 V |
| LNA và chuyển TDD | Module phủ 2,3–5 GHz, loại QPB9850 hoặc tương đương | 4 | Hỏi Qorvo | Một module rộng được cho cả hai băng ở chiều thu |
| Lọc | BAW hoặc gốm, một lọc 3,3–4,2 GHz và một lọc 4,4–5,0 GHz mỗi anten | 8 | Khoảng 5 đến 20 USD mỗi cái | Không dùng lọc khoang ở 24 dBm |
| Coupler | Khoảng 20 dB, dải 3–5 GHz | 4 | Khoảng 2 đến 8 USD | |
| Nguồn | Bộ 12 V, 15 A, 180 W, −40 °C đến +85 °C, cộng lọc EMI, cầu chì, TVS | 1 bộ | Khoảng 80 đến 200 USD | Chịu 97 W sau khi giảm công suất theo nhiệt |
| MGMT và PoE | RJ45 magjack bốn cặp, DP83867, TPS2373-4, hai cầu, bộ chuyển cách ly ra 12 V | 1 | Hỏi TI cho TPS2373-4. EVM TPS2373-4EVM-758 là mẫu 70 W | Class 8, khoảng 71,3 W tại chip. Cùng cổng với Ethernet quản lý. Không thay nguồn 180 W |
| POL và LDO | Rail FPGA, rail AFE, bốn đường PA có cầu chì | 1 bộ | Khoảng 40 đến 120 USD | Mỗi rail dư 10% dòng |
| Vỏ | Nhôm kín, gioăng dẫn, ba khoang, nắp chắn | 1 | Tùy cơ khí | MIL-STD-810 và MIL-STD-461 là mục tiêu đo, chưa phải chứng chỉ |
| Debug | JTAG, UART, SPI, I2C, U.FL clock, U.FL coupler mỗi anten, hàng test point nguồn và GPIO | 1 bộ | Khoảng 20 đến 40 USD | Nằm sau nắp. Không đặt test point trên lane JESD |
| M-plane, servo PSS, CFR, DPD | Chưa mua | 0 | | Mua khi đo thực tế yêu cầu |

Tổng linh kiện bán lẻ nhìn thấy, chưa gồm FPGA, license và mạch in, nằm khoảng vài nghìn USD cho một bản mẫu, trong đó AFE là món đắt nhất có giá công khai. Phần làm giá thật của dự án là báo giá Sail River và Agilex.

## 9. Chỗ được sửa sau khi mua gói

| Việc | Chỗ sửa |
| --- | --- |
| Đổi eAxC, bật tắt sóng mang, chọn 20, 60, 100 MHz | Thanh ghi, HPS, không tổng hợp lại |
| Thêm 10, 40, 50, 80 MHz | DSP Builder, FFT và hệ số lọc, rồi nạp bitstream mới |
| Section type mới hoặc kiểu nén khác | Trong IP O-RAN. Không có source thì không sửa được |
| Đổi băng RF | GPIO chọn PA, NCO của AFE. Không sửa gói C/U |

## 10. Việc chưa điền được trước khi có project Quartus

Số ball của Agilex, thứ tự lane mà project Sail River đã đặt, và tần số SYSREF tối đa. Ba thứ này lấy từ project sau khi Altera giao, rồi mới khóa sơ đồ mạch. Không chép ball từ board khác.
