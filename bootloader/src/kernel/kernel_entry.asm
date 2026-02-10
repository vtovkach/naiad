
BITS 32 

global _start
extern kernel_main 

SECTION .text 
_start:

    ; Clear interrupts flag until implementing IDT 
    cli 

    ; Load a data selector into segment registers from gdt 
    ; INDEX:GDT/LDT:PRIVILEGE (13bits:1bit:2bits)
    mov ax, 0x10 
    mov ds, ax 
    mov es, ax 
    mov ss, ax 

    ; Set up stack 
    mov esp, 0x0007FFFF
    mov ebp, esp 

    ; Clear direction bit just in case 
    cld 

    ; Call C Entry 
    call kernel_main

.hang:
    hlt 
    jmp .hang 