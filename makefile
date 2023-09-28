bin/bomber.bin:src/bomber.asm
	dasm src/bomber.asm -f3 -v0 -obin/bomber.bin -lbin/bomber.lst -sbin/bomber.sym -Iinclude/
run:
	stella bin/bomber.bin
clean:
	rm bin/*