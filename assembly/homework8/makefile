all: yelle8

yelle8: main.o maxmin.o io.o average.o
	ld -o yelle8 -g maxmin.o io.o average.o main.o
main.o:
	nasm -g -f elf64 main.asm
maxmin.o:
	nasm -g -f elf64 maxmin.asm
io.o:
	nasm -g -f elf64 io.asm
average.o:
	nasm -g -f elf64 average.asm

clean:
	rm ./*.o
	rm ./yelle8

