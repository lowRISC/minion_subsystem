LDFLAGS=
OBJECTS= #atmel_generic.o ihex.o srecord.o testGIS.o
CFLAGS=-Wall -Wextra -g -m32 -march=IMXpulpv2 -Wa,-march=IMXpulpv2 -Wextra -Wall -Wno-unused-parameter -Wno-unused-function -fdata-sections -ffunction-sections # -fdiagnostics-color=always
LFLAGS=-Tlink.common.ld -nostartfiles -Wl,--gc-sections -nostdlib

O =  minimal_cls.c minion.c utilities.c

all: clean target.elf

target.elf: $O
	riscv32-unknown-elf-gcc -O0 -nostdlib $(CFLAGS) -o $@ crt0.riscv.S $O $(LFLAGS)
	riscv32-unknown-elf-size target.elf | tee target.size
	riscv32-unknown-elf-nm target.elf >target.nm
	riscv32-unknown-elf-objdump -d target.elf >target.dis
	riscv32-unknown-elf-readelf -S target.elf >target.sections
	riscv32-unknown-elf-objcopy -R .debug_frame -R .comment -R .stack -R .heapsram -R .heapscm -R .scmlock -R .rodata -R .eh_frame -R .shbss -R .data -R .bss -O binary --gap-fill=0 target.elf target.bin
	riscv32-unknown-elf-objcopy -j .rodata -j .data -O binary --gap-fill=0 target.elf target.dat
	riscv32-unknown-elf-objcopy -I binary -O verilog target.bin code.mem0
	riscv32-unknown-elf-objcopy -I binary -O verilog target.dat data.mem0
	riscv32-unknown-elf-objcopy --srec-len 1 --output-target=srec target.elf target.s19
	../../romgen/bigromtest code.mem0 data.mem0 code.v data.v code.mem1 data.mem1

clean:
	rm -f target.* code.* data.*
