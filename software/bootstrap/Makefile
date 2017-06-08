LDFLAGS=
OBJECTS = atmel_generic.o ihex.o srecord.o testGIS.o
TOOLS=/usr/local/src/ri5cy_gnu_toolchain/install/bin
CFLAGS=-Wall -Wextra -I../hello -g -m32 -march=IMXpulpv2 -Wa,-march=IMXpulpv2 -Wextra -Wall -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -fdata-sections -ffunction-sections # -fdiagnostics-color=always
LFLAGS=-Tlink.common.ld -nostartfiles -Wl,--gc-sections -nostdlib

default: junk.elf

J =  mini-printf.o minion_lib.o junk.o

junk.elf: $J
	$(TOOLS)/riscv32-unknown-elf-gcc -nostdlib -O $(CFLAGS) -o $@ crt0.riscv.S -o $@ $J $(LFLAGS)
	$(TOOLS)/riscv32-unknown-elf-size junk.elf | tee junk.size
	$(TOOLS)/riscv32-unknown-elf-objdump -d junk.elf >junk.dis
	$(TOOLS)/riscv32-unknown-elf-readelf -S junk.elf >junk.sect
	$(TOOLS)/riscv32-unknown-elf-objcopy -R .debug_frame -R .comment -R .stack -R .heapsram -R .heapscm -R .scmlock -R .rodata -R .eh_frame -R .shbss -R .data -R .bss -O binary --gap-fill=0 junk.elf junk.bin
	$(TOOLS)/riscv32-unknown-elf-objcopy -j .rodata -j .data -O binary --gap-fill=0 junk.elf junk.dat
	$(TOOLS)/riscv32-unknown-elf-objcopy -I binary -O verilog junk.bin code.mem0
	$(TOOLS)/riscv32-unknown-elf-objcopy -I binary -O verilog junk.dat data.mem0
	$(TOOLS)/riscv32-unknown-elf-objcopy --srec-len 1 --output-target=srec junk.elf junk.s19
	../../romgen/bigromtest code.mem0 data.mem0 code.v data.v code.mem1 data.mem1

.c.o:
	$(TOOLS)/riscv32-unknown-elf-gcc -c -Os $(CFLAGS) $<
