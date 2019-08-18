firmware.elf: cascades_sections.lds main.c bsp
	riscv32-unknown-elf-gcc -DCASCADES -march=rv32ic -Wl,-Bstatic,-T,cascades_sections.lds,--strip-debug,-fno-asynchronous-unwind-tables -o firmware.elf \
	bsp/crt0.o main.c

firmware.hex: firmware.elf
	riscv32-unknown-elf-objcopy -O verilog firmware.elf firmware.hex

firmware.bin: firmware.elf
	riscv32-unknown-elf-objcopy -O binary firmware.elf firmware.bin	

clean:
	rm -f *.o
	rm -f *.elf
	cd bsp && make clean

bsp:
	cd bsp
	make

prog:
	iceprog -o 1M firmware.bin