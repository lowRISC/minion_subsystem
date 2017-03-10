LDFLAGS=
OBJECTS = atmel_generic.o ihex.o srecord.o testGIS.o
TOOLS=/usr/local/src/ri5cy_gnu_toolchain/install/bin
CFLAGS=-Wall -Wextra -I../hello -g -m32 -march=IMXpulpv2 -Wa,-march=IMXpulpv2 -Wextra -Wall -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -fdata-sections -ffunction-sections # -fdiagnostics-color=always
LFLAGS=-Tlink.common.ld -nostartfiles -Wl,--gc-sections -nostdlib

O =  hello.c # simple.c minion_lib.c

target.elf: $O
	$(TOOLS)/riscv32-unknown-elf-gcc -nostdlib -O $(CFLAGS) -o $@ crt0.riscv.S $O $(LFLAGS)
	$(TOOLS)/riscv32-unknown-elf-size target.elf | tee target.size
	$(TOOLS)/riscv32-unknown-elf-nm target.elf >target.nm
	$(TOOLS)/riscv32-unknown-elf-objdump -d target.elf >target.dis
	$(TOOLS)/riscv32-unknown-elf-readelf -S target.elf >target.sections
	$(TOOLS)/riscv32-unknown-elf-objcopy -R .debug_frame -R .comment -R .stack -R .heapsram -R .heapscm -R .scmlock -R .rodata -R .eh_frame -R .shbss -R .data -R .bss -O binary --gap-fill=0 target.elf target.bin
	$(TOOLS)/riscv32-unknown-elf-objcopy -j .rodata -j .data -O binary --gap-fill=0 target.elf target.dat
	$(TOOLS)/riscv32-unknown-elf-objcopy -I binary -O verilog target.bin code.mem0
	$(TOOLS)/riscv32-unknown-elf-objcopy -I binary -O verilog target.dat data.mem0
	$(TOOLS)/riscv32-unknown-elf-objcopy --srec-len 1 --output-target=srec target.elf target.s19
	../../romgen/bigromtest code.mem0 data.mem0 code.v data.v code.mem1 data.mem1

J =  start.o mini-printf.o minion_lib.o simple.o

junk.elf: $J
	$(TOOLS)/riscv32-unknown-elf-ld -melf32lriscv --march=IMXpulpv2 -o $@ $J -Tlink.junk.ld
	$(TOOLS)/riscv32-unknown-elf-size junk.elf | tee junk.size
	$(TOOLS)/riscv32-unknown-elf-objdump -d junk.elf >junk.dis
	$(TOOLS)/riscv32-unknown-elf-readelf -S junk.elf >junk.sect

jbootstrap: junk.elf
	../tester/tester -loadelf $< -bootstrap

M =  start.o mini-printf.o minion_lib.o simple.o minion_helper.o

minion.elf: $J
	$(TOOLS)/riscv32-unknown-elf-ld -melf32lriscv --march=IMXpulpv2 -o $@ $J -Tlink.minion.ld
	$(TOOLS)/riscv32-unknown-elf-size minion.elf | tee minion.size
	$(TOOLS)/riscv32-unknown-elf-objdump -d minion.elf >minion.dis
	$(TOOLS)/riscv32-unknown-elf-readelf -S minion.elf >minion.sect

mbootstrap: minion.elf
	../tester/tester -loadelf $< -bootstrap

.c.o:
	$(TOOLS)/riscv32-unknown-elf-gcc -c -Os $(CFLAGS) $<
