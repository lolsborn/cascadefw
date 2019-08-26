RISCV_XLEN ?= 32
RISCV_LIB  ?= elf

# This is what the ice breaker is currently using,
# P1's are using rv32im
ARCH 		= -march=rv32ic
ABI 		= -mabi=ilp32

TARGET=$(CCPATH)riscv${RISCV_XLEN}-unknown-${RISCV_LIB}

CC		= $(TARGET)-gcc
GCC		= $(CC)
OBJCOPY	= $(TARGET)-objcopy
OBJDUMP	= $(TARGET)-objdump
AR		= $(TARGET)-ar
RANLIB	= $(TARGET)-ranlib
COMPILER_FLAGS = -mcmodel=medany

SRCS = \
	main.c \
	bsp/syscall.c

CRT0 = bsp/crt0.S

CRT0_OBJ = $(CRT0:.S=.o)
APP_OBJ = $(SRCS:.c=.o)
OBJS = $(CRT0_OBJ) $(APP_OBJ)
LIBS	 =  -lc -lgcc
LDFLAGS	 = -T start.ld -nostartfiles -nostdlib
ASFLAGS  += -g $(ARCH) $(ABI)  -Wa,-Ilegacy

%.o: %.c
	@echo "    CC $<"
	$(CC) -c $(CFLAGS) -o $@ $<

%.o: %.S
	@echo "    CC $<"
	$(CC) $(ASFLAGS) -c $(CFLAGS) -o $@ $<

all: firmware.elf firmware.hex firmware.bin

firmware.elf: $(OBJS)
	$(GCC) -o $@ $(LDFLAGS) $(OBJS) $(LIBS)

firmware.hex: firmware.elf
	$(OBJCOPY) -O verilog firmware.elf firmware.hex	

firmware.bin: firmware.elf
	$(OBJCOPY) -O binary firmware.elf firmware.bin



clean :
	@rm -f $(OBJS)
	@rm -f $(PROG).elf 
	@rm -f $(PROG).map
	@rm -f $(PROG).asm

prog:
	iceprog -o 1M firmware.bin