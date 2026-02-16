ASM      := nasm
FORMAT   := bin
ASMFLAGS :=

SRC_DIR := src
BIN_DIR := bin

ASM_SRCS := $(shell find $(SRC_DIR) -type f -name '*.asm')
BIN_BINS := $(patsubst $(SRC_DIR)/%.asm,$(BIN_DIR)/%.bin,$(ASM_SRCS))

all: $(BIN_BINS)

$(BIN_DIR)/%.bin: $(SRC_DIR)/%.asm
	mkdir -p $(dir $@)
	$(ASM) -f $(FORMAT) $(ASMFLAGS) $< -o $@

clean:
	rm -rf $(BIN_DIR)

.PHONY: all clean