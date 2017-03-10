##7 segment display

set_property PACKAGE_PIN T10 [get_ports {SEG[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[0]}]
set_property PACKAGE_PIN R10 [get_ports {SEG[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[1]}]
set_property PACKAGE_PIN K16 [get_ports {SEG[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[2]}]
set_property PACKAGE_PIN K13 [get_ports {SEG[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[3]}]
set_property PACKAGE_PIN P15 [get_ports {SEG[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[4]}]
set_property PACKAGE_PIN T11 [get_ports {SEG[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[5]}]
set_property PACKAGE_PIN L18 [get_ports {SEG[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SEG[6]}]

set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports DP]

set_property PACKAGE_PIN J17 [get_ports {AN[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[0]}]
set_property PACKAGE_PIN J18 [get_ports {AN[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[1]}]
set_property PACKAGE_PIN T9 [get_ports {AN[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[2]}]
set_property PACKAGE_PIN J14 [get_ports {AN[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[3]}]
set_property PACKAGE_PIN P14 [get_ports {AN[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[4]}]
set_property PACKAGE_PIN T14 [get_ports {AN[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[5]}]
set_property PACKAGE_PIN K2 [get_ports {AN[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[6]}]
set_property PACKAGE_PIN U13 [get_ports {AN[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[7]}]


##Buttons
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports GPIO_SW_C]
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports GPIO_SW_N]
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports GPIO_SW_W]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports GPIO_SW_E]
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports GPIO_SW_S]

#VGA Connector

set_property PACKAGE_PIN A3 [get_ports {VGA_RED_O[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RED_O[0]}]
set_property PACKAGE_PIN B4 [get_ports {VGA_RED_O[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RED_O[1]}]
set_property PACKAGE_PIN C5 [get_ports {VGA_RED_O[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RED_O[2]}]
set_property PACKAGE_PIN A4 [get_ports {VGA_RED_O[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RED_O[3]}]

set_property PACKAGE_PIN C6 [get_ports {VGA_GREEN_O[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_GREEN_O[0]}]
set_property PACKAGE_PIN A5 [get_ports {VGA_GREEN_O[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_GREEN_O[1]}]
set_property PACKAGE_PIN B6 [get_ports {VGA_GREEN_O[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_GREEN_O[2]}]
set_property PACKAGE_PIN A6 [get_ports {VGA_GREEN_O[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_GREEN_O[3]}]

set_property PACKAGE_PIN B7 [get_ports {VGA_BLUE_O[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_BLUE_O[0]}]
set_property PACKAGE_PIN C7 [get_ports {VGA_BLUE_O[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_BLUE_O[1]}]
set_property PACKAGE_PIN D7 [get_ports {VGA_BLUE_O[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_BLUE_O[2]}]
set_property PACKAGE_PIN D8 [get_ports {VGA_BLUE_O[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_BLUE_O[3]}]

set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports VGA_HS_O]
set_property -dict {PACKAGE_PIN B12 IOSTANDARD LVCMOS33} [get_ports VGA_VS_O]

#USB HID (PS/2)

set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports PS2_CLK]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports PS2_DATA]



set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
