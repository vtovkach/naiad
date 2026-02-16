# Top-level Makefile (simple)
# Disk layout (512-byte sectors):
#   LBA 0      : bootloader/bin/boot_s1.bin  (1 sector, must be exactly 512 bytes)
#   LBA 1..12  : bootloader/bin/boot_s2.bin  (<= 12 sectors)
#   LBA 13..32 : kernel (20 sectors)

SHELL := /bin/bash

MAKE    := make
LD      := ld
OBJCOPY := objcopy
QEMU    := qemu-system-i386

OUTDIR := bin
IMG    := $(OUTDIR)/os.img

BOOT_S1 := bootloader/bin/boot_s1.bin
BOOT_S2 := bootloader/bin/boot_s2.bin

KOBJDIR := kernel/obj
KLD     := linker/kernel/kernel.ld

KERNEL_ELF := $(OUTDIR)/kernel.elf
KERNEL_BIN := $(OUTDIR)/kernel.bin

.PHONY: all bootloader kernel image run clean

all: image

bootloader:
	$(MAKE) -C bootloader

kernel:
	$(MAKE) -C kernel

$(KERNEL_ELF): kernel
	@mkdir -p $(OUTDIR)
	$(LD) -m elf_i386 -T $(KLD) -nostdlib -o $@ $$(find $(KOBJDIR) -type f -name '*.o')

$(KERNEL_BIN): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $< $@
	truncate -s $$((512 * 20)) $@

image: bootloader $(KERNEL_BIN)
	@mkdir -p $(OUTDIR)
	@S1=$$(stat -c%s "$(BOOT_S1)"); [ $$S1 -eq 512 ] || (echo "ERROR: $(BOOT_S1) must be 512 bytes, got $$S1" && exit 1)
	@S2=$$(stat -c%s "$(BOOT_S2)"); [ $$S2 -le $$((512 * 12)) ] || (echo "ERROR: $(BOOT_S2) must be <= 12 sectors, got $$S2 bytes" && exit 1)

	dd if=$(BOOT_S1) of=$(IMG) bs=512 count=1 conv=notrunc status=none
	dd if=$(BOOT_S2) of=$(IMG) bs=512 seek=1 conv=notrunc status=none
	dd if=$(KERNEL_BIN) of=$(IMG) bs=512 seek=13 count=20 conv=notrunc status=none

run: image
	$(QEMU) -drive format=raw,file=$(IMG)

clean:
	-$(MAKE) -C bootloader clean
	-$(MAKE) -C kernel clean
	rm -rf $(OUTDIR)
