# Board oscillator on Q240 pin 28. 50 MHz is the usual NTC FB-CY6-DEV clock.
create_clock -name clk -period 20.000 [get_ports clk]
