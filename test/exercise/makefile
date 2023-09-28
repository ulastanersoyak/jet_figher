# Define the assembler and flags
ASSEMBLER = dasm
ASSEMBLY_FLAGS = -f3 -v0

# List of assembly source files
SOURCES = ex1.asm ex2.asm ex2.asm ex3.asm ex4.asm ex5.asm ex6.asm ex7.asm ex8.asm ex9.asm

# Generate binary file names from assembly file names
BINARIES = $(SOURCES:.asm=.bin)

# Default target
all: $(BINARIES)

# Rule to assemble each assembly file into a binary file
%.bin: %.asm
	$(ASSEMBLER) $< $(ASSEMBLY_FLAGS) -o$@

# Clean up generated files
clean:
	rm -f $(BINARIES)
