default: xvlog

base_dir = ..

tb_srcs = \
	minion_tb.v \

verilog_srcs = \
	nettype_none.v \
	coremem.sv \
	dualmem.v \
	rachelset.v \
	iopad.v \
	my_fifo.v \
	generic_fifo_dc.v \
	minion_soc.sv \
	ps2_keyboard.v \
	ps2_translation_table.v \
	ps2.v \
	rx_delay.v \
	sd_cmd_serial_host.v \
	sd_crc_16.v \
	sd_crc_7.v \
	sd_data_serial_host.sv \
	sd_top.sv \
	uart.v \
	nettype_wire.v \
	fstore2.v \
	../pulpino/ips/riscv/controller.sv \
	../pulpino/ips/riscv/cs_registers.sv \
	../pulpino/ips/riscv/debug_unit.sv \
	../pulpino/ips/riscv/decoder.sv \
	../pulpino/ips/riscv/exc_controller.sv \
	../pulpino/ips/riscv/ex_stage.sv \
	../pulpino/ips/riscv/hwloop_controller.sv \
	../pulpino/ips/riscv/hwloop_regs.sv \
	../pulpino/ips/riscv/id_stage.sv \
	../pulpino/ips/riscv/if_stage.sv \
	../pulpino/ips/riscv/include/riscv_config.sv \
	../pulpino/ips/riscv/load_store_unit.sv \
	../pulpino/ips/riscv/mult.sv \
	../pulpino/ips/riscv/prefetch_L0_buffer.sv \
	../pulpino/ips/riscv/register_file_ff.sv \
	../pulpino/ips/riscv/riscv_core.sv \
	../pulpino/rtl/components/cluster_clock_gating.sv \
	../pulpino/ips/riscv/alu.sv \
	../pulpino/ips/riscv/alu_div.sv \
	../pulpino/ips/riscv/compressed_decoder.sv \
	../pulpino/ips/riscv/prefetch_buffer.sv \
	code0.v data0.v
#	../software/bootstrap/code.v \
	../software/bootstrap/data.v \

verilog_headers = \
	ps2_defines.v \
	sd_defines.h \
	ascii_code.v \
	../pulpino/rtl/includes/config.sv \

#--------------------------------------------------------------------
# Build Verilog
#--------------------------------------------------------------------

verilator: $(tb_srcs) $(verilog_srcs) $(verilog_headers)
	verilator -cc -DBYPASS_CLK_DIV -DSKIP_ASSERT \
        +incdir+../pulpino/rtl/includes \
        +incdir+../pulpino/ips/riscv/include \
	$(tb_srcs) $(verilog_srcs) 2>&1 | tee $@.log

cvc: $(tb_srcs) $(verilog_srcs) $(verilog_headers)
	echo -sv +libext+.v +lint=TFIPC-L +show_canceled_e \
	+define+BYPASS_CLK_DIV +define+SKIP_ASSERT \
        +incdir+../pulpino/rtl/includes \
        +incdir+../pulpino/ips/riscv/include \
	$(tb_srcs) $(verilog_srcs) >cvc.cmd
	cvc64 -f cvc.cmd 2>&1 | tee $@.log

iverilog: $(tb_srcs) $(verilog_srcs) $(verilog_headers)
	iverilog -g2012 -DSKIP_ASSERT \
        -I ../pulpino/rtl/includes \
        -I ../pulpino/ips/riscv/include \
	$(tb_srcs) $(verilog_srcs) 2>&1 | tee $@.log

xvlog: $(tb_srcs) $(verilog_srcs) $(verilog_headers)
	xvlog -d BYPASS_CLK_DIV -d SKIP_ASSERT --sv \
        -i ../pulpino/rtl/includes \
        -i ../pulpino/ips/riscv/include \
	$(tb_srcs) $(verilog_srcs) 2>&1 | tee $@.log
	xelab minion_tb
	echo run all | xsim work.minion_tb
	gtkwave dump.vcd

simv: $(tb_srcs) $(verilog_srcs) $(verilog_headers)
	vcs -full64 +systemverilogext+sv +libext+.v +lint=TFIPC-L -gui \
	+define+BYPASS_CLK_DIV \
        +incdir+../pulpino/rtl/includes \
        +incdir+../pulpino/ips/riscv/include \
	$(tb_srcs) $(verilog_srcs) 2>&1 | tee $@.log

yosys: $(verilog_srcs) $(verilog_headers)
	@rm -f $@.cmd
	echo read_verilog -DBYPASS_CLK_DIV -DSKIP_ASSERT -sv -noopt -I../pulpino/rtl/includes -I../pulpino/ips/riscv/include $(verilog_srcs) >>$@.cmd
	echo write_verilog $@.yosys >>$@.cmd
	yosys -s $@.cmd 2>&1 | tee $@.log

sed: $(tb_srcs) $(verilog_srcs)
	sh remove_modern_constructs.sh $(tb_srcs) $(verilog_srcs)

#--------------------------------------------------------------------
# clean up
#--------------------------------------------------------------------

clean:
	rm -rf $(junk)

.PHONY: clean
