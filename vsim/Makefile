# See LICENSE for license details.

# check Verilator environment variable
ifndef VERILATOR_ROOT
$(error Please set environment for the Verilator simulator)
endif

all:  clean veri sim copy

cls:  clean cls veri sim copy

finj: clean finj veri sim copy
#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

verilog_srcs = \
		../socgen/minion_soc.sv \
		../socgen/coremem.sv \
		../verilog/debouncer.v \
		../verilog/dpram.v \
		../verilog/dualmem.v \
		../verilog/fstore2.v \
		../verilog/my_fifo.v \
		../verilog/rambyte.v \
		../verilog/rx_delay.v \
		../verilog/uart.v \
		../pulpino/ips/riscv/include/riscv_defines.sv \
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
		src/mem_tb.v \
	  src/xilinx_tb.v \

all: tb_src = \
        src/veri_top.cc \

cls: tb_src = \
        src/veri_top.cc \

finj: tb_src = \
        src/veri_top_finj.cc \

cls: cls_srcs := \
		../socgen/minion_cls.sv \
		../verilog/cls_unit.sv \

finj: finj_srcs := \
		../socgen/minion_cls.sv \
		../verilog/cls_unit.sv \
		../verilog/fault_injection.sv \

all: DATAMEM=../software/minimal/data.mem1
all: CODEMEM=../software/minimal/code.mem1

cls: DATAMEM=../software/minimal_cls/data.mem1
cls: CODEMEM=../software/minimal_cls/code.mem1

finj: DATAMEM=../software/minimal_cls/data.mem1
finj: CODEMEM=../software/minimal_cls/code.mem1


#--------------------------------------------------------------------
# Build rules (verilator)
#--------------------------------------------------------------------
veri:
	verilator \
	  --cc \
    $(verilog_srcs) \
		$(cls_srcs) \
		$(finj_srcs) \
	  -DVERILATOR_GCC \
	  +incdir+../verilog \
		      +incdir+src \
	        +incdir+../pulpino/rtl/includes \
	        +incdir+../pulpino/ips/riscv/include \
	  --top-module minion_soc \
	  --unroll-count 256 \
	  --error-limit 500 \
	    --output-split 80000 \
	  --output-split-cfuncs 10000 \
	  -O3 -Wno-lint -Wno-style -Wno-STMTDLY -Wno-ASSIGNIN -Wno-fatal --coverage --trace-max-array 17000 \
	  -CFLAGS "-std=c++11" \
	  -CFLAGS "-I/media/nanimo/lowRISC_repo/minion_subsystem/vsim" \
	  -LDFLAGS "-pthread" \
	  --trace \
	 	--exe $(tb_src)

#--------------------------------------------------------------
# Build the simulator (verilator)
#--------------------------------------------------------------------

sim:
	make -j -C obj_dir -f Vminion_soc.mk Vminion_soc

#--------------------------------------------------------------
# Copy memory files to directory
#--------------------------------------------------------------------

copy:
	cp $(DATAMEM) obj_dir/
	cp $(CODEMEM) obj_dir/

#--------------------------------------------------------------------
# clean up
#--------------------------------------------------------------------

clean:
	rm -rf obj_dir
