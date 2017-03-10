CC = gcc
CFLAGS = -Wall -Wextra -g
LDFLAGS=
OBJECTS = atmel_generic.o ihex.o srecord.o testGIS.o
ROOT=/home/jrrk2/proj/lowrisc-chip-eth-debug-pulpino/src/test/cxx/sw
TOOLS=/usr/local/src/ri5cy_gnu_toolchain/install/bin
CFLAGS=-g -m32 -march=IMXpulpv2 -Wa,-march=IMXpulpv2 -Wextra -Wall -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -fdata-sections -ffunction-sections -fdiagnostics-color=never -I$(ROOT)/libs/sys_lib/inc -I$(ROOT)/libs/string_lib/inc
LFLAGS=-Tlink.common.ld -nostartfiles -Wl,--gc-sections -nostdlib
BLFLAGS=-Tlink.boot.ld -nostartfiles -Wl,--gc-sections -nostdlib

all: hello.elf

O = start.o 	   diskio.o  elf.o  file.o	init.o	  minion_helper.o  \
console.o  dummy.o   ff.o   memory.o  sbi_impl.o	   string.o  mini-printf.o  \
minion_lib.o  simple_lib.o # vm.o  spi.o  bbl.o

hello.elf: $O
	$(TOOLS)/riscv32-unknown-elf-ld -melf32lriscv --march=IMXpulpv2 -o $@ $O -Tlink.junk.ld
	$(TOOLS)/riscv32-unknown-elf-objdump -d hello.elf >hello.dis
	$(TOOLS)/riscv32-unknown-elf-size $@ | tee hello.siz
	$(TOOLS)/riscv32-unknown-elf-objdump -d hello.elf >hello.dis
	$(TOOLS)/riscv32-unknown-elf-readelf -S hello.elf >hello.sect

bootstrap: hello.elf
	../tester/tester -loadelf $< -bootstrap

.c.o:
	$(TOOLS)/riscv32-unknown-elf-gcc -c -Os $(CFLAGS) $<
