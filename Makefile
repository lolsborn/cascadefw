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
	main.c

GLOSS_HDRS = \
	bsp/machine/syscall.h \

GLOSS_SRCS = \
	bsp/nanosleep.c \
	bsp/sys_access.c \
	bsp/sys_chdir.c \
	bsp/sys_chmod.c \
	bsp/sys_chown.c \
	bsp/sys_close.c \
	bsp/sys_conv_stat.c \
	bsp/sys_execve.c \
	bsp/sys_exit.c \
	bsp/sys_faccessat.c \
	bsp/sys_fork.c \
	bsp/sys_fstatat.c \
	bsp/sys_fstat.c \
	bsp/sys_ftime.c \
	bsp/sys_getcwd.c \
	bsp/sys_getpid.c \
	bsp/sys_gettimeofday.c \
	bsp/sys_isatty.c \
	bsp/sys_kill.c \
	bsp/sys_link.c \
	bsp/sys_lseek.c \
	bsp/sys_lstat.c \
	bsp/sys_openat.c \
	bsp/sys_open.c \
	bsp/sys_read.c \
	bsp/sys_sbrk.c \
	bsp/sys_stat.c \
	bsp/sys_sysconf.c \
	bsp/sys_times.c \
	bsp/sys_unlink.c \
	bsp/sys_utime.c \
	bsp/sys_wait.c \
	bsp/sys_write.c 

CRT0 = bsp/crt0.S

CRT0_OBJ = $(CRT0:.S=.o)
GLOSS_OBJS  = $(GLOSS_SRCS:.c=.o)
APP_OBJ = $(SRCS:.c=.o)
OBJS = $(CRT0_OBJ) $(GLOSS_OBJS) $(APP_OBJ)
LIBS	 =  -lc_nano -lgcc
LDFLAGS	 = -T start.ld -nostartfiles -nostdlib
ASFLAGS  += -g $(ARCH) $(ABI)  -Wa,-Ilegacy

%.o: %.c
	@echo "    CC $<"
	@$(CC) -c $(CFLAGS) -o $@ $<

%.o: %.S
	@echo "    CC $<"
	@$(CC) $(ASFLAGS) -c $(CFLAGS) -o $@ $<

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