XILINX_VERILOG=/local/scratch/jrrk2/regression/xilinx_verilog/src

default: verilator

base_dir = ..

verilog_srcs = \
	nettype_none.v \
	minion_tb.v \
	coremem.sv \
	dualmem.v \
	fstore2.v \
	minion_soc.sv \
	my_fifo.v \
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
	../software/bootstrap/code.v \
	../software/bootstrap/data.v \

verilog_headers = \
	ps2_defines.v \
	sd_defines.h \
	ascii_code.v \
	../pulpino/rtl/includes/config.sv \

#--------------------------------------------------------------------
# Build Verilog
#--------------------------------------------------------------------

verilator: $(verilog_srcs) $(verilog_headers)
	verilator -cc -DSKIP_ASSERT \
        +incdir+../pulpino/rtl/includes \
        +incdir+../pulpino/ips/riscv/include \
	$(XILINX_VERILOG)/glbl.v \
	$(XILINX_VERILOG)/unisims/RAMB16_S1_S1.v \
	$(XILINX_VERILOG)/unisims/RAMB16_S2_S2.v \
	$(XILINX_VERILOG)/unisims/RAMB16_S9.v \
	$(XILINX_VERILOG)/unisims/FIFO18E1.v \
	$(XILINX_VERILOG)/unisims/IOBUF.v \
	$(XILINX_VERILOG)/unisims/RAMB18E1.v \
	$(verilog_srcs) 2>&1 | tee $@.log

cvc: $(verilog_srcs) $(verilog_headers) $(XILINX_VERILOG)/glbl.v
	echo -sv +libext+.v +lint=TFIPC-L +show_canceled_e \
	+define+BYPASS_CLK_DIV +define+SKIP_ASSERT \
        +incdir+../pulpino/rtl/includes \
        +incdir+../pulpino/ips/riscv/include \
	$(XILINX_VERILOG)/glbl.v \
	$(XILINX_VERILOG)/unisims/RAMB16_S1_S1.v \
	$(XILINX_VERILOG)/unisims/RAMB16_S2_S2.v \
	$(XILINX_VERILOG)/unisims/RAMB16_S9.v \
	$(XILINX_VERILOG)/unisims/FIFO18E1.v \
	$(XILINX_VERILOG)/unisims/IOBUF.v \
	$(XILINX_VERILOG)/unisims/RAMB18E1.v \
	$(verilog_srcs) >cvc.cmd
	cvc64 -f cvc.cmd 2>&1 | tee $@.log

iverilog: $(verilog_srcs) $(verilog_headers)
	iverilog -g2012 -DSKIP_ASSERT \
        -I ../pulpino/rtl/includes \
        -I ../pulpino/ips/riscv/include \
	$(verilog_srcs) 2>&1 | tee $@.log

simv: $(verilog_srcs) $(verilog_headers) $(XILINX_VERILOG)/glbl.v
	vcs -full64 +systemverilogext+sv +libext+.v +lint=TFIPC-L -gui \
	+define+BYPASS_CLK_DIV \
        +incdir+../pulpino/rtl/includes \
        +incdir+../pulpino/ips/riscv/include \
	$(XILINX_VERILOG)/glbl.v \
	-y $(XILINX_VERILOG)/unisims \
	$(verilog_srcs) 2>&1 | tee $@.log

tokens.v: $(verilog_srcs) $(verilog_headers) $(XILINX_VERILOG)/glbl.v
	vcs -full64 -Xmangle=4 +systemverilogext+sv +libext+.v +lint=TFIPC-L -gui \
	+define+BYPASS_CLK_DIV \
        +incdir+../pulpino/rtl/includes \
        +incdir+../pulpino/ips/riscv/include \
	$(XILINX_VERILOG)/glbl.v \
	-y $(XILINX_VERILOG)/unisims \
	$(verilog_srcs) 2>&1 | tee $@.log

sed: $(verilog_srcs)
	sh remove_modern_constructs.sh $(verilog_srcs)

#--------------------------------------------------------------------
# clean up
#--------------------------------------------------------------------

clean:
	rm -rf $(junk)

.PHONY: clean
