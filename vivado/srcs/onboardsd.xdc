# SD Pins
set_property PACKAGE_PIN B1 [get_ports sd_sclk]
set_property PACKAGE_PIN C1 [get_ports sd_cmd]
set_property PACKAGE_PIN C2 [get_ports {sd_dat[0]}]
set_property PACKAGE_PIN E1 [get_ports {sd_dat[1]}]
set_property PACKAGE_PIN F1 [get_ports {sd_dat[2]}]
set_property PACKAGE_PIN D2 [get_ports {sd_dat[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports sd_reset]
set_property PACKAGE_PIN E2 [get_ports sd_reset]
set_property IOSTANDARD LVCMOS33 [get_ports sd_detect]
set_property PACKAGE_PIN A1 [get_ports sd_detect]


