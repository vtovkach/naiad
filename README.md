# Naiad

Naiad is a custom x86 operating system developed from scratch in C.

## Architecture

- Custom BIOS [bootloader](https://github.com/vtovkach/naiad/blob/main/bootloader/README.md)
- UEFI bootloader (planned)
- x86 kernel implemented in C

## General Goals

- Unified kernel entry for BIOS and UEFI
- Structured memory management (PMM → VMM)
- Modular and maintainable architecture
- Progressive expansion toward a full operating system

## Roadmap

- [x] BIOS Bootloader
- [ ] GDT Finalization 
- [ ] IDT Initialization
- [ ] Interrupt/Exception Handlers
- [ ] Physical Memory Manager (PMM)
- [ ] Paging Initialization
- [ ] Virtual Memory Manager (VMM)
- [ ] Kernel Heap Allocator
