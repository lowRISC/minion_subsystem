set_property IOSTANDARD LVCMOS25 [get_ports {{disp_an_o[*]} {disp_seg_o[*]} i_emdint i_e* i_gmiiclk_*}]
set_property IOSTANDARD LVCMOS25 [get_ports io_emdio]
set_property IOSTANDARD LVCMOS25 [get_ports {o_etxd[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {o_etxd[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {o_etxd[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {o_etxd[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports o_egtx_clk]
set_property IOSTANDARD LVCMOS25 [get_ports o_emdc]
set_property IOSTANDARD LVCMOS25 [get_ports o_erstn]
set_property IOSTANDARD LVCMOS25 [get_ports o_etx_en]
set_property IOSTANDARD LVCMOS25 [get_ports o_etx_er]
set_property IOSTANDARD LVCMOS18 [get_ports {{o_led[*]} {i_dip[*]}}]
set_property IOSTANDARD LVTTL [get_ports {sd_*}]
#set_property IOSTANDARD LVCMOS25 [get_ports sd_reset]
#set_property IOSTANDARD LVCMOS25 [get_ports sd_detect]
# on board differential clock, 200MHz
set_property IOSTANDARD DIFF_SSTL15 [get_ports clk_p]
set_property PACKAGE_PIN AD12 [get_ports clk_p]
set_property PACKAGE_PIN AD11 [get_ports clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports clk_n]

# Reset active high SW4.1 User button South
set_property VCCAUX_IO DONTCARE [get_ports rst_top]
set_property SLEW FAST [get_ports rst_top]
set_property IOSTANDARD LVCMOS18 [get_ports rst_top]
set_property PACKAGE_PIN AB12 [get_ports rst_top]

# UART Pins
set_property IOSTANDARD LVCMOS25 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS25 [get_ports uart_tx]

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
#
set_property PACKAGE_PIN Y21 [get_ports sd_reset]
set_property PACKAGE_PIN AA21 [get_ports sd_detect]
set_property PACKAGE_PIN AB22 [get_ports sd_cmd]
set_property PACKAGE_PIN AB23 [get_ports sd_sclk]
set_property PACKAGE_PIN AA22 [get_ports {sd_dat[2]}]
set_property PACKAGE_PIN AA23 [get_ports {sd_dat[1]}]
set_property PACKAGE_PIN AC20 [get_ports {sd_dat[0]}]
set_property PACKAGE_PIN AC21 [get_ports {sd_dat[3]}]
#
set_property PACKAGE_PIN G8 [get_ports i_gmiiclk_p]
set_property PACKAGE_PIN G7 [get_ports i_gmiiclk_n]
set_property PACKAGE_PIN J21 [get_ports io_emdio]
set_property PACKAGE_PIN K24 [get_ports uart_tx]
set_property PACKAGE_PIN K30 [get_ports o_egtx_clk]
set_property PACKAGE_PIN L20 [get_ports o_erstn]
set_property PACKAGE_PIN L28 [get_ports {o_etxd[3]}]
set_property PACKAGE_PIN M19 [get_ports uart_rx]
set_property PACKAGE_PIN M27 [get_ports o_etx_en]
set_property PACKAGE_PIN M28 [get_ports i_etx_clk]
set_property PACKAGE_PIN M29 [get_ports {o_etxd[2]}]
set_property PACKAGE_PIN N25 [get_ports {o_etxd[1]}]
set_property PACKAGE_PIN N27 [get_ports {o_etxd[0]}]
set_property PACKAGE_PIN N29 [get_ports o_etx_er]
set_property PACKAGE_PIN N30 [get_ports i_emdint]
set_property PACKAGE_PIN R23 [get_ports o_emdc]
set_property PACKAGE_PIN R28 [get_ports i_erx_dv]
set_property PACKAGE_PIN R30 [get_ports i_erx_crs]
set_property PACKAGE_PIN T25 [get_ports {i_erxd[2]}]
set_property PACKAGE_PIN U25 [get_ports {i_erxd[1]}]
set_property PACKAGE_PIN U27 [get_ports i_erx_clk]
set_property PACKAGE_PIN U28 [get_ports {i_erxd[3]}]
set_property PACKAGE_PIN U30 [get_ports {i_erxd[0]}]
set_property PACKAGE_PIN V26 [get_ports i_erx_er]
set_property PACKAGE_PIN W19 [get_ports i_erx_col]

set_property PACKAGE_PIN Y29 [get_ports {i_dip[0]}]
set_property PACKAGE_PIN W29 [get_ports {i_dip[1]}]
set_property PACKAGE_PIN AA28 [get_ports {i_dip[2]}]
set_property PACKAGE_PIN Y28 [get_ports {i_dip[3]}]

set_property PACKAGE_PIN AB8 [get_ports {o_led[0]}]
set_property PACKAGE_PIN AA8 [get_ports {o_led[1]}]
set_property PACKAGE_PIN AC9 [get_ports {o_led[2]}]
set_property PACKAGE_PIN AB9 [get_ports {o_led[3]}]
set_property PACKAGE_PIN AE26 [get_ports {o_led[4]}]
set_property PACKAGE_PIN G19 [get_ports {o_led[5]}]
set_property PACKAGE_PIN E18 [get_ports {o_led[6]}]
set_property PACKAGE_PIN F16 [get_ports {o_led[7]}]


