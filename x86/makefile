prog: main.o proj.o
	@echo "Linking files..."
	gcc -m32 main.o proj.o -o prog
	@echo "SUCCSESS\n\n"

main.o: main.c
	@echo "Compiling C FUNCTION..."
	gcc -m32 -c main.c -o main.o
	@echo "SUCCSESS\n\n"
	
proj.o: proj.asm
	@echo "Compiling ASM FUNCTION..."
	nasm -f elf32 proj.asm -o proj.o
	@echo "SUCCESS\n\n"
