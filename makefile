SRC_DIR := src
BIN_DIR := bin
TEST_DIR := test
MACROS_DIR := $(TEST_DIR)/macros
SRC_FILE := $(SRC_DIR)/bomber.asm
BIN_FILE := $(BIN_DIR)/bomber.bin
LIST_FILE := $(BIN_DIR)/bomber.lst
SYM_FILE := $(BIN_DIR)/bomber.sym
ASSEMBLER := dasm
EMULATOR := stella
ASSEMBLER_FLAGS := -f3 -v0 -o$(BIN_FILE) -l$(LIST_FILE) -s$(SYM_FILE) -I$(MACROS_DIR)
$(shell mkdir -p $(BIN_DIR))
.PHONY: run clean
$(BIN_FILE): $(SRC_FILE)
	$(ASSEMBLER) $(SRC_FILE) $(ASSEMBLER_FLAGS)
run: $(BIN_FILE)
	$(EMULATOR) $(BIN_FILE)
clean:
	rm -rf $(BIN_DIR)
