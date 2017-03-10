set origin_dir "."
# open implemented design
open_run impl_1

# search for all RAMB blocks
rm msoc.log
foreach m [get_cells msoc/block_i/RAMB16_*] { report_property -file msoc.log -append $m {NAME}; report_property -file msoc.log -append $m {LOC} }
#report_property  [get_cells ram_reg_1] {LOC}
#report_property  [get_cells ram_reg_2] {LOC}
#report_property  [get_cells ram_reg_3] {LOC}
#report_property  [get_cells ram_reg_4] {LOC}
#report_property  [get_cells ram_reg_5] {LOC}
#report_property  [get_cells ram_reg_6] {LOC}
#report_property  [get_cells ram_reg_7] {LOC}
