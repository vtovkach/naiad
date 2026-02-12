ASM := nasm
ASMFLAGS :=

SRC_DIR  := src
BIN_DIR  := bin
DISK_DIR := disk
OBJ_DIR  := obj

STAGE1 := boot_s1
STAGE2 := boot_s2
KERNEL := kernel

# Disk layout
SECTOR_SIZE    := 512
STAGE2_SECTORS := 12
KERNEL_SECTORS := 20
TOTAL_SECTORS  := 33   # 1 + stage2(12) + kernel(20)

IMG := $(DISK_DIR)/disk.img

QEMU := qemu-system-i386

CC := gcc
LD := ld
OBJCOPY := objcopy
CFLAGS := -m32 -ffreestanding -fno-pie -fno-pic -fno-stack-protector -nostdlib
LDFLAGS := -m elf_i386 -T kernel.ld

all: image

# Directories
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(DISK_DIR):
	mkdir -p $(DISK_DIR)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

# -------------------------
# Stage 1 (boot sector)
# -------------------------
$(BIN_DIR)/$(STAGE1).bin: $(SRC_DIR)/$(STAGE1).asm | $(BIN_DIR)
	$(ASM) -f bin $(ASMFLAGS) $< -o $@

# -------------------------
# Stage 2 (flat binary)
# -------------------------
$(BIN_DIR)/$(STAGE2).bin: $(SRC_DIR)/$(STAGE2).asm | $(BIN_DIR)
	$(ASM) -f bin $(ASMFLAGS) $< -o $@

# -------------------------
# Kernel (ELF + flat bin)
# -------------------------
$(OBJ_DIR)/kernel_entry.o: $(SRC_DIR)/kernel/kernel_entry.asm | $(OBJ_DIR)
	$(ASM) -f elf32 $(ASMFLAGS) $< -o $@

$(OBJ_DIR)/mini_kernel.o: $(SRC_DIR)/kernel/mini_kernel.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN_DIR)/$(KERNEL).elf: $(OBJ_DIR)/kernel_entry.o $(OBJ_DIR)/mini_kernel.o kernel.ld | $(BIN_DIR)
	$(LD) $(LDFLAGS) $(OBJ_DIR)/kernel_entry.o $(OBJ_DIR)/mini_kernel.o -o $@

$(BIN_DIR)/$(KERNEL).bin: $(BIN_DIR)/$(KERNEL).elf | $(BIN_DIR)
	$(OBJCOPY) -O binary $< $@
	truncate -s $$((512*$(KERNEL_SECTORS))) $@

# -------------------------
# Disk image
# -------------------------
image: $(IMG)

$(IMG): $(BIN_DIR)/$(STAGE1).bin $(BIN_DIR)/$(STAGE2).bin $(BIN_DIR)/$(KERNEL).bin | $(DISK_DIR)
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(TOTAL_SECTORS)
	dd if=$(BIN_DIR)/$(STAGE1).bin of=$@ bs=$(SECTOR_SIZE) conv=notrunc seek=0
	dd if=$(BIN_DIR)/$(STAGE2).bin of=$@ bs=$(SECTOR_SIZE) conv=notrunc seek=1
	dd if=$(BIN_DIR)/$(KERNEL).bin of=$@ bs=$(SECTOR_SIZE) conv=notrunc seek=13

run: image
	$(QEMU) -m 32G -no-reboot -drive format=raw,file=$(IMG)

clean:
	rm -rf $(BIN_DIR) $(DISK_DIR) $(OBJ_DIR)

.PHONY: all image run clean
