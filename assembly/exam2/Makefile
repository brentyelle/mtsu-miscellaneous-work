all: yelle_exam2

yelle_exam2: main io convert
	ld -o yelle9 -g main.o io.o convert.o
main:
	nasm -g -f elf64 main.asm
io:
	nasm -g -f elf64 io.asm
convert:
	nasm -g -f elf64 convert.asm

clean:
	rm ./*.o
	rm ./yelle9
