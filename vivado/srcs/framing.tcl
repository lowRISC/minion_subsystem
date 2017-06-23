remove_container r 
read_vhdl -container r -libname WORK -2008 { framing_golden.vhd } 
set_top r:/WORK/framing 
remove_container i 
read_verilog -container i -libname WORK -05 { ../../verilog/framing.v } 
set_top i:/WORK/framing 
match 
verify 
