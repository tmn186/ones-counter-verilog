# Rang buoc thoi gian: clock 50 MHz (chu ky 20 ns)
create_clock -name clk -period 20.000 [get_ports {clk}]
derive_clock_uncertainty
