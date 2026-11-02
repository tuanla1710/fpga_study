# O-RU design, 4T4R, 24 dBm

An indoor unit, split 7.2 Category A. Each antenna port is 24 dBm average. Bands n77, n78, and n48 are on the 3.3–4.2 GHz branch. Band n79 is on the 4.4–5.0 GHz branch. One carrier or two carriers, with a selectable bandwidth of 10, 20, 40, 50, 60, 80, or 100 MHz, and SCS of 30 kHz. The digital section uses the Sail River package on an Agilex 5 SoC. Agilex 7 uses the same package but draws more power, so it does not fit a 24 dBm enclosure.

The prices below are public reference prices or an estimate for one prototype. They are not a purchase quote. Sail River, Quartus, and the FPGA have no list price.

## 1. Architecture

```text
O-DU
  |  SFP28 25 GbE, SyncE + PTP
  v
Agilex 5 SoC
  F-Tile quad A: 25 GbE, refclk 156.25 MHz
  F-Tile quad B: JESD204C, refclk 122.88 MHz
  Fabric: packet filter, eCPRI, O-RAN, FFT/iFFT, CP, PRACH, DUC/DDC
  HPS: Linux, ptp4l, M-plane API, SPI/I2C
  |  RJ45 MGMT: 1000BASE-T into the HPS, PoE Class 8 into the TPS2373-4
  |
  +-- DDR
  +-- SI5518
  +-- AFE7950  (4 TX, 4 RX, 2 FB)
         |
         +-- 4 copies of the antenna block
               band select
               3.5 GHz branch or 4.7 GHz branch
               PA about 28 dBm -> filter -> TDD switch -> 24 dBm port
               coupler -> combined feedback
```

The C-plane and U-plane stay in the fabric. The M-plane and S-plane go to the HPS. The TDD GPIO comes out of the fabric, not out of the HPS.

Sail River has been checked at 20, 60, and 100 MHz, up to 2 carriers, 200 MHz occupied bandwidth, 280 MHz instantaneous bandwidth, one 25 GbE port, and 9-bit compression. The 10, 40, 50, and 80 MHz bandwidths are added in DSP Builder. JESD stays at 8110.08 Mb/s.

## 2. Clock

The radio time base is 122.88 MHz. A JESD lane at 8110.08 Mb/s is 122.88 MHz × 66. A 10 ms frame is 1,228,800 cycles. A useful SCS 30 kHz symbol is 4096 samples.

| Clock | Frequency | From | To |
| --- | --- | --- | --- |
| OCXO | 10 MHz | Frequency reference | SI5518 |
| SyncE | recovered clock | F-Tile quad A | SI5518 DSPLL A |
| Ethernet | 156.25 MHz | SI5518 | F-Tile quad A |
| JESD FPGA | 122.88 MHz | SI5518 | F-Tile quad B |
| Radio | 122.88 MHz | SI5518 | Fabric |
| AFE REFCLK | 491.52 MHz | SI5518 | AFE7950 REFCLK+/- |
| SYSREF | from the AFE GUI log | SI5518 | AFE7950 and F-Tile, then turned off after the link is up |
| 1 PPS | 1 Hz | Left unconnected | Fit only when GNSS is present |

The 156.25 MHz and 122.88 MHz refclks must not enter the same transceiver quad. SYSREF is on only during bring-up. The two SYSREF routes are the same length. The HPS trims the SI5518 DCO from `ptp4l`. If the optical link is lost, holdover stays on the OCXO.

Changing bandwidth does not change the clock. Changing n77 to n79 only changes the AFE NCO.

## 3. Power, with 10% margin over maximum power

24 dBm is the level at the antenna port. The PA makes up the filter and switch loss, so the PA output is about 28 dBm. The power budget is not calculated from 24 dBm. It is calculated for the moment when all four PAs transmit together and the AFE and FPGA are in their heaviest mode.

The FPGA watt numbers are a design budget, not a measurement. After the Sail River project exists, run the Power Analyzer and then lock the number. The AFE numbers come from the modes in the AFE7950 datasheet. One mode is near 9 W.

| Load | Max at the device pins | How it is calculated |
| --- | --- | --- |
| Agilex 5, HPS, 25 GbE, JESD | 35 W | 4T4R FFT running continuously, RAM and DSP full, plus the transceivers. 18 W is only enough while the fabric is idle |
| AFE7950 | 9.5 W | Datasheet, rounded up from a mode of about 9 W |
| DDR | 2 W | |
| SI5518 | 1.2 W | |
| OCXO at startup | 2.5 W | |
| SFP28 | 1.5 W | |
| Four PAs transmitting together | 21 W | 28 dBm each PA, 12% efficiency at OFDM backoff |
| LNA, TDD switch, logic | 2 W | |
| Sensors | 0.5 W | |
| Total at the load | 75.2 W | |
| POL loss, 85% efficiency | 13.3 W | 75.2 / 0.85 − 75.2 |
| Power in at 12 V | 88.5 W | |
| 10% margin | 8.8 W | |
| Supply must support | 97.3 W | 8.1 A at 12 V |

Drop the 18 W figure. That number does not include a four-antenna FFT running continuously, and it does not include the 25 GbE lane and eight JESD lanes left on. On Sail River, a 4T4R two-carrier configuration uses about 61% of the logic, 95% of the RAM, and 45% of the DSP of an Agilex 5 around the A5E065 size. Transceivers plus fabric at that level are about 35 W until the Power Analyzer gives a real number. Agilex 7 is higher still, so this unit stays on Agilex 5.

The 12 V supply printed on the label must still deliver at least 97 W after thermal derating. At +70 °C many supplies are down to about 60% of the labeled power. The label needs about 97 / 0.6 = 162 W. Choose a 12 V, 15 A, 180 W supply, rated from −40 °C to +85 °C. The input voltage is still 12 V.

Each rail also has 10% current margin over the maximum load current on that rail, not only at the 12 V input.

| Rail | Job | Change from the previous revision |
| --- | --- | --- |
| 12 V input | Fuse, reverse-polarity protection, TVS, EMI filter, inrush limit | The previous revision only said 12 V |
| FPGA core | A POL that follows the Agilex power-up order, with PG and current sense | Do not share one POL |
| 0.9 V and 1.2 V AFE | A separate POL, capacitors next to the balls | |
| AFE VDDA 1.8 V | An LDO after the POL, not shared with the digital 1.8 V | Split the analog rail |
| 5 V PA | Four electronic fuses, one path per antenna, cut by the TDD GPIO | One shared 5 V rail is not enough to isolate a fault |
| 3.3 V clock and SFP | A separate POL | |

The full-load source is still the 12 V, 180 W supply. The MGMT port also carries PoE Class 8. PoE powers the unit only after the HPS has limited the PAs, because the standard stops at 71.3 W.

An alarm goes to the HPS when the 12 V current passes 90% of 8.1 A, about 7.3 A, or when one PA passes its rated current. The FPGA, the AFE, and the four PAs dump heat into the aluminum enclosure through thermal pads. Do not rely on a fan. A fan is a failure point and a hole for radiated noise.

24 dBm is the level at the antenna port. The PA makes up the filter and switch loss.

| Point | Average level |
| --- | --- |
| Antenna port | 24 dBm |
| After the TDD switch | about 25 dBm |
| After the ceramic or BAW filter | about 27 dBm |
| PA output | about 28 dBm |

The OFDM peak is about 8 dB higher if CFR is not present yet. The PA and the switch must survive that peak. DPD is not required yet at 24 dBm. A coupler of about 20 dB is still fitted so the level can be measured.

The 48 V rail exists only on the isolated primary side of the PoE supply. The PA, the FPGA, and the clock have no 48 V rail.

## 4. MGMT port, PoE power, and the debug port

One RJ45 does both jobs: management Ethernet into the HPS, and PoE power into the PD chip. The fronthaul stays on the SFP28. It does not share this cable.

The power chip is TI's **TPS2373-4**, an IEEE 802.3bt Type 4, Class 8 PD. The datasheet lists about 71.3 W delivered. The TPS2373-4EVM-758 evaluation board is a 70 W supply. Do not use the TPS23734. That chip only reaches Class 4, about 25.5 W.

The management PHY is the **DP83867**, RGMII into an HPS EMAC. The PHY takes 3.3 V and 2.5 V after the diode-OR. It does not take power from the 48 V side.

After the 48 V to 12 V converter, the 12 V rail has only about 60 W left. That is enough for the FPGA, the AFE, the clock, the PHY, and the debug ports. It is not enough for four PAs at full transmit power. When only PoE is plugged in, the HPS reads the BT pin and enables only one or two PAs. All four PAs turn on only when the 12 V, 180 W supply is present.

```text
RJ45 MGMT, four-pair magjack, Class 8 rated
  data, after the transformer
        -> DP83867 -> RGMII -> HPS
  center taps of the four pairs
        pairs 1-2 and 3-6 -> bridge rectifier A
        pairs 4-5 and 7-8 -> bridge rectifier B
        the two positive poles join at VDD, the two negative poles join at VSS
TPS2373-4
  DEN: 24.9 kΩ up to VDD
  CLSA, CLSB down to VSS through the Class 8 resistors in the datasheet
  RTN -> primary ground of the isolated 48 V to 12 V converter
  PG, TPH, TPL, BT -> opto -> HPS
  APD -> detects the 12 V jack. If 12 V is present, turn off the PoE MOSFET
Isolated converter -> diode-OR with the 12 V jack -> EMI filter -> POLs
Debug ports take 3.3 V from an LDO after the diode-OR, through an eFuse of about 0.5 A
```

The 12 V jack always wins if both sources are plugged in. PoE does not go straight onto the PA 5 V rail. The debug header has no 12 V pin. JTAG, UART, SPI, and I2C still run when only the MGMT cable is plugged in, because they sit after the 12 V converter. Header logic levels follow the HPS bank. Do not plug in a 5 V TTL adapter.

## 5. Connection diagram so the high-speed routes stay short

This file does not assign Agilex ball numbers. Ball numbers depend on the OPN and must come from Pin Planner after the Sail River project is opened. AFE ball numbers come from the AFE7950 datasheet Rev. E, 400-ball package, 17 mm × 17 mm. The rules below keep the 8 Gb/s routes and the clocks from crossing the board.

Place the parts, from the optical port inward:

```text
SFP28 -- F-Tile quad A -- HPS and DDR
                |
             SI5518 between the F-Tile and the AFE
                |
             AFE7950 facing quad B
                |
             four RF clusters next to the AFE analog pins
```

Quad A receives only 156.25 MHz. Quad B receives only 122.88 MHz. Do not share a refclk.

### JESD, 8 lanes, 8110.08 Mb/s

The AFE has 8 lanes, up to 29.5 Gb/s. This design does not use 29.5 Gb/s. Keep 8.11 Gb/s so it matches the Sail River IP and so the board is easier to build. Lanes stay together in one quad, in order, and do not cross into another quad.

| AFE signal | Data direction | FPGA signal | Job |
| --- | --- | --- | --- |
| SRX1+/- through SRX4+/- | FPGA transmits, AFE receives | TX quad B, lanes 0–3 | DAC samples, four antennas |
| STX1+/- through STX4+/- | AFE transmits, FPGA receives | RX quad B, lanes 0–3 | ADC samples, four antennas |
| STX5+/- through STX6+/- | AFE transmits, FPGA receives | RX quad B, lanes 4–5 | Two feedback paths |
| SRX5+/- through SRX8+/- | Unused in this revision | Left open, terminated as the datasheet says | Spare |
| REFCLK+/- | SI5518 into the AFE | 491.52 MHz, differential pair | RF sample PLL |
| SYSREF+/- | SI5518 into the AFE and into quad B | Same source, same length | Subclass 1 alignment, then turn it off |

AFE STX is an output. AFE SRX is an input. Reversing this direction means the link does not come up.

Each differential pair is length-matched inside the pair, and the skew between lanes stays under the limit the JESD IP allows at 8.11 Gb/s. AC-couple a lane if both datasheets require it. Do not route a lane under the PA power section.

### Clock and control

| Signal | Connection | Preference |
| --- | --- | --- |
| SI5518 output, 156.25 MHz | Quad A refclk | Short, and not near a PA |
| SI5518 output, 122.88 MHz | Quad B refclk and the fabric clock | Same chip as SYSREF |
| SI5518 output, 491.52 MHz | AFE REFCLK+/- | The shortest of the analog clocks |
| SYSREF | AFE and quad B | Length-matched, off after bring-up |
| SPICLK, SPISEN, SPISDIO, SPISDO | HPS SPI | 1.8 V, shared with RESETZ |
| RESETZ | HPS GPIO | A pulse of at least 1 ms, per the AFE datasheet |
| TDD GPIO | Fabric 1.8 V bank | To the PA enable and the TDD switch, not through the HPS |
| n77 or n79 band select | Fabric GPIO | One bit for four antennas, because the whole unit is on one band at a time |
| SI5518 LOS and lock | HPS | Report to the M-plane when SyncE is lost |

Do not take the AFE SPI from a transceiver bank. That bank is reserved for JESD and 25 GbE.

### One antenna

```text
AFE TXx -> driver -> 3.5 GHz PA or 4.7 GHz PA
        -> coupler -> filter -> TDD switch -> antenna port
coupler -20 dB -> 4-to-2 switch -> AFE FB0 or FB1
antenna port -> TDD switch -> filter -> LNA -> AFE RXx
```

Four couplers combine into two FB ports. Two antennas share a pair, because the AFE7950 has only two feedback receivers. At 24 dBm, feedback is only for measurement. Add DPD later if ACLR is not met.

The 3.5 GHz branch and the 4.7 GHz branch do not transmit at the same time on one antenna. One band-select bit cuts the enable of the PA that is idle.

## 6. Environment and interference

A 24 dBm unit still has to survive a harsh environment. These are design targets, not a certificate:

| Item | Target |
| --- | --- |
| Operating temperature | −40 °C to +70 °C outside the enclosure |
| Storage temperature | −40 °C to +85 °C |
| Vibration and shock | MIL-STD-810H, Methods 514 and 516 |
| Humidity and salt fog | MIL-STD-810H, Methods 507 and 509. Sealed enclosure, Gore vent |
| Emissions and susceptibility | MIL-STD-461G: CE102, CS101, CS114, CS115, CS116, RE102, RS103 |
| ESD on external ports | IEC 61000-4-2, level 4 |

Parts that have to be added:

- A continuous aluminum enclosure, conductive gasket, and a lid screwed down evenly. Digital, AFE, and PA sit in three cavities.
- Shield lids over the Agilex, over the AFE, and over the PA cluster.
- An input power filter. Do not bring 12 V straight into a POL.
- The antenna port is the only RF port that leaves the enclosure. The fronthaul is optical only. Do not use copper 25 GbE.
- Industrial or automotive temperature parts. Do not use a commercial 0–70 °C grade for the OCXO, DDR, POLs, or PAs.
- Conformal coat after the debug stage is finished.
- One star point for the enclosure ground screws, with the AFE analog ground and the PA ground kept apart.

## 7. Debug and development ports

The MGMT RJ45 sits on the enclosure edge, next to the debug cluster. The MGMT cable is both management Ethernet and PoE power. The other headers sit behind the lid. Do not leave them open in operation.

| Port | Job | Power |
| --- | --- | --- |
| RJ45 MGMT | 1000BASE-T into the HPS through the DP83867. PoE into the TPS2373-4 | Class 8 on the cable, data isolated by the transformer |
| FPGA JTAG | Program and rebuild while editing DSP Builder | 3.3 V after the diode-OR, 0.5 A eFuse |
| HPS UART | Linux console | The same 3.3 V rail |
| SPI header | Read the AFE7950 and SI5518 directly before software is up | Same rail, level follows the HPS bank |
| I2C | Temperature sensors and the calibration EEPROM | Same rail |
| 10 MHz U.FL | Compare the clock with a reference instrument | No power out of the connector |
| 1 PPS U.FL | Compare PTP phase | No power out of the connector |
| Test-point row | Measure loss of power, loss of clock, a dropped JESD link, one dead antenna, or loss of MGMT | No power. Each cluster has a ground pad next to it |
| PMBus or current sense | Measure each rail and compare it with the 97 W budget | Sense only. Do not load the probe point |
| LEDs inside the enclosure | Power, PTP lock, JESD lock, PA fault, and whether power is PoE or the 12 V jack | 3.3 V rail |

With only PoE plugged in, JTAG and UART still work. All four PAs do not turn on in that state.

Test points sit behind the lid, with names printed on the board, and they stay exposed under the conformal coat. Each cluster has a ground pad right beside it so the instrument ground clip stays short. Do not cut a hole through the enclosure.

Do not solder a probe directly onto an 8.11 Gb/s JESD pair, onto the 491.52 MHz REFCLK, or onto an F-Tile refclk. Watch those routes through a buffered copy, or through a series resistor of about 1 kΩ on a copy. Data lanes have no test point.

The PoE primary side can reach about 57 V. Keep those points in their own area, away from the 1.8 V and 3.3 V rows.

| Symptom | Where to measure | What the reading means |
| --- | --- | --- |
| Power does not come up | 12 V before the eFuse, 12 V after the eFuse, PG of each POL | Lost before the eFuse means the jack or the fuse. Lost after the eFuse means current limit or reversed polarity. One rail's PG low means that POL has not turned on. Check the Agilex group order: 1, then 2A, then 2B |
| A rail sags while transmitting | 12 V current sense, each PA sense, AFE 0.9 V and 1.2 V, FPGA core | 12 V current above about 7.3 A is past 90% of the budget. One PA higher than the other antennas is a fault on that antenna |
| PoE is plugged in and the unit does not run | TPS2373-4 VDD, PG, BT, and TPH/TPL after the opto | No VDD means the cable or a bridge rectifier. VDD present and PG still down means the 48 V to 12 V converter. BT not reporting Type 4 means the switch is not granting Class 8 |
| Both supplies are plugged in and the unit is still weak | APD, PG of the 12 V jack | APD low means the PoE MOSFET has not released, so the 12 V jack has not won |
| PTP or SyncE does not lock | OCXO 10 MHz U.FL, SI5518 LOS and lock, copies of 122.88 MHz and 156.25 MHz | A dead OCXO kills the whole clock tree. LOS high while the OCXO is alive means SyncE was lost on the optical link. 122.88 MHz gone while 10 MHz remains means the SI5518 |
| JESD does not come up | SYSREF through a buffer, AFE RESETZ, JESD lock brought out to a GPIO | SYSREF must have a few edges at bring-up and then turn off. RESETZ must stay low for at least 1 ms. If lock still does not come up, check SPI and lane order. Do not probe the differential pair directly |
| One antenna does not transmit | That antenna's PA enable, the band-select bit, TDD, and the U.FL taken from the −20 dB coupler | Enable low means the GPIO or the PA eFuse has cut it. Enable correct and no signal on the U.FL means the PA or the filter. Signal on the U.FL and nothing at the antenna port means the TDD switch or the connector |
| Transmitting on the wrong band | The n77 or n79 select bit, and the enable of the PA that should be off | Both enables high is a software fault. Only one band may be on |
| Receive is noisy, or there is no receive | LNA power, the receive-side TDD path | LNA power lost means all four receive antennas die together. One antenna means look at that antenna's TDD switch |
| MGMT does not link | Series resistor on RGMII RX_CLK, PHY reset pin, DP83867 link LED | If the PHY cannot be reset, the HPS has not provided the management clock. Link LED off while the PHY has power means the cable or the transformer |
| Cut off by heat | Sensors on the FPGA lid, on the AFE, and on each PA, read over I2C | One PA hotter than the other three is that antenna. The whole FPGA hot is digital load, not the PA |

The coupler U.FL is only for measurement with the lid open. In operation that measurement path connects to the AFE feedback. Do not leave it open.

## 8. BOM and price

Retail component prices are a reference, one piece, around October 2026. Ask the vendor for the FPGA, the licenses, and the cavity filters. Leave the price cell blank when there is no trustworthy list price.

| Item | Part | Qty | Reference price | Note |
| --- | --- | --- | --- | --- |
| FPGA SoC | Agilex 5 E-series or D-series, the part that is in Sail River, for example the A5E family | 1 | Altera quote | Do not buy Agilex 7 for a 24 dBm unit unless a power measurement still has margin |
| Tool license | Quartus Prime for Agilex, DSP Builder | 1 | Altera quote | The free edition cannot synthesize this family |
| O-RU workload | Sail River package | 1 | Altera quote | Includes eCPRI, O-RAN, JESD, low-PHY, DUC/DDC |
| AFE | AFE7950IABJ, 400 ball | 1 | About 2,130 USD each on [LCSC](https://www.lcsc.com/product-image/C3606796.html) at qty 1. About 1,890 USD at qty 1,000. Out of stock when last checked | Datasheet [Rev. E](https://www.ti.com/lit/ds/symlink/afe7950.pdf). Ask TI for a direct TI price |
| Clock | SI5518 | 1 | Ask Skyworks | One distributor listing is about 27 USD. That is unusually low for the NetSync family. Do not use it as the order price |
| OCXO | 10 MHz, a type that can hold PTP holdover | 1 | About 50 to 200 USD | An ordinary crystal is not enough for 30 minutes of holdover |
| Memory | DDR for the HPS, the type the Agilex 5 board supports | 1 set | About 20 to 60 USD | |
| Optical | SFP28 25 GbE SR and an SFP cage | 1 | About 30 to 80 USD | |
| PA | Two small-cell PAs per antenna, about 28 dBm, one at 3.3–4.2 GHz and one at 4.4–5.0 GHz | 8 | About 15 to 40 USD each | Do not use an 8 W, 48 V GaN PA |
| LNA and TDD switch | A module covering 2.3–5 GHz, a QPB9850 or equivalent | 4 | Ask Qorvo | One wideband module can cover both bands on the receive side |
| Filters | BAW or ceramic, one 3.3–4.2 GHz filter and one 4.4–5.0 GHz filter per antenna | 8 | About 5 to 20 USD each | Do not use a cavity filter at 24 dBm |
| Coupler | About 20 dB, 3–5 GHz | 4 | About 2 to 8 USD | |
| Supply | 12 V, 15 A, 180 W, −40 °C to +85 °C, plus EMI filter, fuse, and TVS | 1 set | About 80 to 200 USD | Must deliver 97 W after thermal derating |
| MGMT and PoE | Four-pair RJ45 magjack, DP83867, TPS2373-4, two bridges, isolated converter to 12 V | 1 | Ask TI for the TPS2373-4. The TPS2373-4EVM-758 is a 70 W sample | Class 8, about 71.3 W at the chip. Same port as management Ethernet. It does not replace the 180 W supply |
| POLs and LDOs | FPGA rails, AFE rails, four PA paths with fuses | 1 set | About 40 to 120 USD | 10% current margin on each rail |
| Enclosure | Sealed aluminum, conductive gasket, three cavities, shield lids | 1 | Depends on the mechanics | MIL-STD-810 and MIL-STD-461 are measurement targets, not a certificate |
| Debug | JTAG, UART, SPI, I2C, clock U.FL, one coupler U.FL per antenna, power and GPIO test points | 1 set | About 20 to 40 USD | Behind the lid. Do not put a test point on a JESD lane |
| M-plane, PSS servo, CFR, DPD | Not purchased yet | 0 | | Buy them when a real measurement requires them |

The visible retail parts, excluding the FPGA, the licenses, and the printed circuit, come to a few thousand USD for one prototype. The AFE is the most expensive part with a public price. The part that sets the real project price is the Sail River and Agilex quote.

## 9. What may be changed after the package is purchased

| Change | Where to change it |
| --- | --- |
| Change eAxC, turn a carrier on or off, select 20, 60, or 100 MHz | Registers, the HPS. Do not resynthesize |
| Add 10, 40, 50, or 80 MHz | DSP Builder, the FFT and the filter coefficients, then program a new bitstream |
| A new section type or a different compression format | Inside the O-RAN IP. Without source, it cannot be changed |
| Change the RF band | The PA-select GPIO and the AFE NCO. Do not change the C/U package |

## 10. What cannot be filled in before the Quartus project exists

The Agilex ball numbers, the lane order the Sail River project already chose, and the maximum SYSREF frequency. Those three come from the project after Altera delivers it, and only then is the schematic locked. Do not copy balls from another board.
