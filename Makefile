C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
C_HEADERS = $(wildcard kernel/*.h drivers/*.h)
OBJ = ${C_SOURCES:.c=.o}

%.o : %.c
	i686-linux-gnu-gcc-7 -ffreestanding -fno-pie -c $< -o $@

%.bin : %.asm
	nasm $< -f bin -o $@

%.o : %.asm
	nasm $< -f elf -o $@

run: all
	bochs -rc .debug.rc

all: os-image

os-image : boot/boot.bin kernel.bin
	cat $^ > $@

kernel.bin : kernel/kernel_entry.o ${OBJ}
	ld -o kernel.bin -Ttext 0x1000 $^ -m elf_i386 --oformat binary

clean :
	rm -fr *.bin *.dis *.o os-image
	rm -fr kernel/*.o boot/*.bin drivers/*.o

%.dis : %
	ndisasm -b 32 $< > $@
