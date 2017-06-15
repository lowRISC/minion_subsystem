cd /local/scratch/jrrk2/lowrisc-chip-logging/minion_subsystem
close_hw
open_hw
connect_hw_server -quiet
create_hw_target my_svf_target
open_hw_target [get_hw_targets -regexp .*/my_svf_target]
set device0 [create_hw_device -part xc7a100tcsg321-1]
set_property PROGRAM.FILE { vivado/minion_top_nexys4ddr.runs/impl_1/eth_top.bit } $device0
set_param xicom.config_chunk_size 0
program_hw_devices -force -svf_file {eth_top.svf} $device0
close_hw_target [get_hw_targets -regexp .*/my_svf_target]
delete_hw_target [get_hw_targets -regexp .*/my_svf_target]
close_hw
