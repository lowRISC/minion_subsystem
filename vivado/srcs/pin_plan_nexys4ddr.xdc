# on board single-end clock, 100MHz
set_property PACKAGE_PIN E3 [get_ports clk_p]
set_property IOSTANDARD LVCMOS33 [get_ports clk_p]

# Reset "CPU_RESET" active low
set_property IOSTANDARD LVCMOS33 [get_ports rst_top]
set_property PACKAGE_PIN C12 [get_ports rst_top]
#set_property IOSTANDARD LVCMOS33 [get_ports rst_top]
#set_property LOC J15 [get_ports rst_top]; # mapped to switch 0

# UART Pins
set_property PACKAGE_PIN C4 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]
set_property PACKAGE_PIN D4 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]
#set_property PACKAGE_PIN E5 [get_ports uart_rts]
#set_property IOSTANDARD LVCMOS33 [get_ports uart_rts]
#set_property PACKAGE_PIN D3 [get_ports uart_cts]
#set_property IOSTANDARD LVCMOS33 [get_ports uart_cts]

## Switches

set_property PACKAGE_PIN J15 [get_ports {i_dip[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_dip[0]}]
set_property PACKAGE_PIN L16 [get_ports {i_dip[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_dip[1]}]
set_property PACKAGE_PIN M13 [get_ports {i_dip[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_dip[2]}]
set_property PACKAGE_PIN R15 [get_ports {i_dip[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_dip[3]}]
#set_property PACKAGE_PIN R17 [get_ports {i_dip[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {i_dip[4]}]
#set_property PACKAGE_PIN T18 [get_ports {i_dip[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {i_dip[5]}]
#set_property PACKAGE_PIN U18 [get_ports {i_dip[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {i_dip[6]}]
#set_property PACKAGE_PIN R13 [get_ports {i_dip[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {i_dip[7]}]
# SW8 and SW9 are in the same bank of the DDR2 interface, which requires 1.8 V
#set_property PACKAGE_PIN T8 [get_ports {i_dip[8]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {i_dip[8]}]
#set_property PACKAGE_PIN U8 [get_ports {i_dip[9]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {i_dip[9]}]
#set_property PACKAGE_PIN R16 [get_ports {i_dip[10]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {i_dip[10]}]
#set_property PACKAGE_PIN T13 [get_ports {i_dip[11]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {i_dip[11]}]
#set_property PACKAGE_PIN H6 [get_ports {i_dip[12]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {i_dip[12]}]
#set_property PACKAGE_PIN U12 [get_ports {i_dip[13]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {i_dip[13]}]
#set_property PACKAGE_PIN U11 [get_ports {i_dip[14]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {i_dip[14]}]
#set_property PACKAGE_PIN V10 [get_ports {i_dip[15]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {i_dip[15]}]

## o_leds

set_property PACKAGE_PIN H17 [get_ports {o_led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_led[0]}]
set_property PACKAGE_PIN K15 [get_ports {o_led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_led[1]}]
set_property PACKAGE_PIN J13 [get_ports {o_led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_led[2]}]
set_property PACKAGE_PIN N14 [get_ports {o_led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_led[3]}]
set_property PACKAGE_PIN R18 [get_ports {o_led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_led[4]}]
set_property PACKAGE_PIN V17 [get_ports {o_led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_led[5]}]
set_property PACKAGE_PIN U17 [get_ports {o_led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_led[6]}]
set_property PACKAGE_PIN U16 [get_ports {o_led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_led[7]}]
#set_property PACKAGE_PIN V16 [get_ports {o_led[8]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {o_led[8]}]
#set_property PACKAGE_PIN T15 [get_ports {o_led[9]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {o_led[9]}]
#set_property PACKAGE_PIN U14 [get_ports {o_led[10]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {o_led[10]}]
#set_property PACKAGE_PIN T16 [get_ports {o_led[11]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {o_led[11]}]
set_property PACKAGE_PIN V15 [get_ports o_etx_er]
set_property IOSTANDARD LVCMOS33 [get_ports o_etx_er]
set_property PACKAGE_PIN V14 [get_ports o_egtx_clk]
set_property IOSTANDARD LVCMOS33 [get_ports o_egtx_clk]
set_property PACKAGE_PIN V12 [get_ports {o_etxd[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_etxd[2]}]
set_property PACKAGE_PIN V11 [get_ports {o_etxd[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_etxd[3]}]

##Buttons

#set_property PACKAGE_PIN N17 [get_ports i_rst]
#set_property IOSTANDARD LVCMOS33 [get_ports i_rst]

#set_property PACKAGE_PIN P17 [get_ports {i_etxd[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {i_etxd[2]}]
#set_property PACKAGE_PIN M17 [get_ports {i_etxd[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {i_etxd[3]}]

##SMSC Ethernet PHY
set_property PACKAGE_PIN C9 [get_ports o_emdc]
set_property IOSTANDARD LVCMOS33 [get_ports o_emdc]
set_property PACKAGE_PIN A9 [get_ports io_emdio]
set_property IOSTANDARD LVCMOS33 [get_ports io_emdio]
set_property PACKAGE_PIN B3 [get_ports o_erstn]
set_property IOSTANDARD LVCMOS33 [get_ports o_erstn]
set_property PACKAGE_PIN D9 [get_ports i_erx_dv]
set_property IOSTANDARD LVCMOS33 [get_ports i_erx_dv]
set_property PACKAGE_PIN C10 [get_ports i_erx_er]
set_property IOSTANDARD LVCMOS33 [get_ports i_erx_er]
set_property PACKAGE_PIN C11 [get_ports {i_erxd[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_erxd[0]}]
set_property PACKAGE_PIN D10 [get_ports {i_erxd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_erxd[1]}]
set_property PACKAGE_PIN B9 [get_ports o_etx_en]
set_property IOSTANDARD LVCMOS33 [get_ports o_etx_en]
set_property PACKAGE_PIN A10 [get_ports {o_etxd[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_etxd[0]}]
set_property PACKAGE_PIN A8 [get_ports {o_etxd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_etxd[1]}]
set_property PACKAGE_PIN D5 [get_ports o_erefclk]
set_property IOSTANDARD LVCMOS33 [get_ports o_erefclk]
set_property -dict {PACKAGE_PIN B8 IOSTANDARD LVCMOS33} [get_ports i_emdint]

# 8-Digit Seven-Segment Display Segments
#set_property PACKAGE_PIN L3 [get_ports {disp_seg_o[0]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_seg_o[0]' has been applied to the port object 'disp_seg_o[0]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_seg_o[0]}]
#set_property PACKAGE_PIN N1 [get_ports {disp_seg_o[1]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_seg_o[1]' has been applied to the port object 'disp_seg_o[1]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_seg_o[1]}]
#set_property PACKAGE_PIN L5 [get_ports {disp_seg_o[2]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_seg_o[2]' has been applied to the port object 'disp_seg_o[2]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_seg_o[2]}]
#set_property PACKAGE_PIN L4 [get_ports {disp_seg_o[3]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_seg_o[3]' has been applied to the port object 'disp_seg_o[3]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_seg_o[3]}]
#set_property PACKAGE_PIN K3 [get_ports {disp_seg_o[4]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_seg_o[4]' has been applied to the port object 'disp_seg_o[4]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_seg_o[4]}]
#set_property PACKAGE_PIN M2 [get_ports {disp_seg_o[5]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_seg_o[5]' has been applied to the port object 'disp_seg_o[5]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_seg_o[5]}]
#set_property PACKAGE_PIN L6 [get_ports {disp_seg_o[6]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_seg_o[6]' has been applied to the port object 'disp_seg_o[6]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_seg_o[6]}]
#DP
#set_property PACKAGE_PIN M4 [get_ports {disp_seg_o[7]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_seg_o[7]' has been applied to the port object 'disp_seg_o[7]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_seg_o[7]}]
# 8-Digit Seven-Segment Display Anodes, Active-Low
#set_property PACKAGE_PIN N6 [get_ports {disp_an_o[0]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_an_o[0]' has been applied to the port object 'disp_an_o[0]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_an_o[0]}]
#set_property PACKAGE_PIN M6 [get_ports {disp_an_o[1]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_an_o[1]' has been applied to the port object 'disp_an_o[1]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_an_o[1]}]
#set_property PACKAGE_PIN M3 [get_ports {disp_an_o[2]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_an_o[2]' has been applied to the port object 'disp_an_o[2]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_an_o[2]}]
#set_property PACKAGE_PIN N5 [get_ports {disp_an_o[3]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_an_o[3]' has been applied to the port object 'disp_an_o[3]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_an_o[3]}]
#set_property PACKAGE_PIN N2 [get_ports {disp_an_o[4]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_an_o[4]' has been applied to the port object 'disp_an_o[4]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_an_o[4]}]
#set_property PACKAGE_PIN N4 [get_ports {disp_an_o[5]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_an_o[5]' has been applied to the port object 'disp_an_o[5]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_an_o[5]}]
#set_property PACKAGE_PIN L1 [get_ports {disp_an_o[6]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_an_o[6]' has been applied to the port object 'disp_an_o[6]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_an_o[6]}]
#set_property PACKAGE_PIN M1 [get_ports {disp_an_o[7]}]
# The conversion of 'IOSTANDARD' constraint on 'net' object 'disp_an_o[7]' has been applied to the port object 'disp_an_o[7]'.
#set_property IOSTANDARD LVCMOS18 [get_ports {disp_an_o[7]}]


create_clock -period 10.000 -name clk_p -waveform {0.000 5.000} [get_ports clk_p]
create_clock -period 40.000 -name SD_CLK -waveform {0.000 5.000} [get_pins msoc/clock_divider0/SD_CLK_buf_inst/O]
create_clock -period 25.000 -name VIRTUAL_clk_out2_clk_wiz_0 -waveform {0.000 12.500}
create_clock -period 20.000 -name VIRTUAL_clk_out3_clk_wiz_0 -waveform {0.000 10.000}
create_clock -period 50.000 -name VIRTUAL_msoc/clock_divider0/SD_CLK_O_reg_0 -waveform {0.000 25.000}
set_input_delay -clock [get_clocks VIRTUAL_clk_out2_clk_wiz_0] -min -add_delay 0.000 [get_ports {i_dip[*]}]
set_input_delay -clock [get_clocks VIRTUAL_clk_out2_clk_wiz_0] -max -add_delay 0.000 [get_ports {i_dip[*]}]
set_input_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -min -add_delay 0.000 [get_ports {i_dip[*]}]
set_input_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -max -add_delay 0.000 [get_ports {i_dip[*]}]
set_input_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -min -add_delay 10.000 [get_ports {i_erxd[*]}]
set_input_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -max -add_delay 10.000 [get_ports {i_erxd[*]}]
set_input_delay -clock [get_clocks VIRTUAL_msoc/clock_divider0/SD_CLK_O_reg_0] -min -add_delay 0.000 [get_ports {sd_dat[*]}]
set_input_delay -clock [get_clocks VIRTUAL_msoc/clock_divider0/SD_CLK_O_reg_0] -max -add_delay 0.000 [get_ports {sd_dat[*]}]
set_input_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -min -add_delay 10.000 [get_ports i_erx_dv]
set_input_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -max -add_delay 10.000 [get_ports i_erx_dv]
set_input_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -min -add_delay 10.000 [get_ports io_emdio]
set_input_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -max -add_delay 10.000 [get_ports io_emdio]
set_input_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -min -add_delay 10.000 [get_ports rst_top]
set_input_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -max -add_delay 10.000 [get_ports rst_top]
set_input_delay -clock [get_clocks VIRTUAL_msoc/clock_divider0/SD_CLK_O_reg_0] -min -add_delay 0.000 [get_ports sd_cmd]
set_input_delay -clock [get_clocks VIRTUAL_msoc/clock_divider0/SD_CLK_O_reg_0] -max -add_delay 0.000 [get_ports sd_cmd]
set_input_delay -clock [get_clocks VIRTUAL_clk_out2_clk_wiz_0] -min -add_delay 0.000 [get_ports uart_rx]
set_input_delay -clock [get_clocks VIRTUAL_clk_out2_clk_wiz_0] -max -add_delay 0.000 [get_ports uart_rx]
set_output_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -min -add_delay 0.000 [get_ports {o_etxd[*]}]
set_output_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -max -add_delay 15.000 [get_ports {o_etxd[*]}]
set_output_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -min -add_delay 0.000 [get_ports {o_led[*]}]
set_output_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -max -add_delay 15.000 [get_ports {o_led[*]}]
set_output_delay -clock [get_clocks VIRTUAL_msoc/clock_divider0/SD_CLK_O_reg_0] -min -add_delay 0.000 [get_ports {sd_dat[*]}]
set_output_delay -clock [get_clocks VIRTUAL_msoc/clock_divider0/SD_CLK_O_reg_0] -max -add_delay 0.000 [get_ports {sd_dat[*]}]
set_output_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -min -add_delay 10.000 [get_ports io_emdio]
set_output_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -max -add_delay 10.000 [get_ports io_emdio]
set_output_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -min -add_delay 0.000 [get_ports o_emdc]
set_output_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -max -add_delay 15.000 [get_ports o_emdc]
set_output_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -min -add_delay 0.000 [get_ports o_erstn]
set_output_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -max -add_delay 15.000 [get_ports o_erstn]
set_output_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -min -add_delay 0.000 [get_ports o_etx_en]
set_output_delay -clock [get_clocks VIRTUAL_clk_out3_clk_wiz_0] -max -add_delay 15.000 [get_ports o_etx_en]
set_output_delay -clock [get_clocks VIRTUAL_msoc/clock_divider0/SD_CLK_O_reg_0] -min -add_delay 0.000 [get_ports sd_cmd]
set_output_delay -clock [get_clocks VIRTUAL_msoc/clock_divider0/SD_CLK_O_reg_0] -max -add_delay 0.000 [get_ports sd_cmd]
set_output_delay -clock [get_clocks VIRTUAL_clk_out2_clk_wiz_0] -min -add_delay 0.000 [get_ports sd_reset]
set_output_delay -clock [get_clocks VIRTUAL_clk_out2_clk_wiz_0] -max -add_delay 0.000 [get_ports sd_reset]
set_output_delay -clock [get_clocks VIRTUAL_clk_out2_clk_wiz_0] -min -add_delay 0.000 [get_ports uart_tx]
set_output_delay -clock [get_clocks VIRTUAL_clk_out2_clk_wiz_0] -max -add_delay 0.000 [get_ports uart_tx]


set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets msoc/sd_sclk_monitor]
