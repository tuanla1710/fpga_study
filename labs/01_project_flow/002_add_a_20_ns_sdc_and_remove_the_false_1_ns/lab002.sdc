# Board oscillator on Q240 pin 28. 50 MHz, period 20 ns.
# The false 1 ns line was: create_clock -name clk -period 1.000 [get_ports clk]
# That compile reported setup slack -12.831 ns and still had 0 errors.
create_clock -name clk -period 20.000 [get_ports clk]
