
org 0x7c00 
bits 16 

; Initialize CS:IP
cs_init:
    jmp 0x0000:start

start:
    ; Initialize Memory Segments 
    cli 
    xor ax, ax 
    mov ds, ax 
    mov es, ax 
    mov ss, ax 
    mov sp, 0x7c00 
    sti

    ; enable text mode 80x25 
    mov ax, 0x0003
    int 0x10 

    mov si, success_msg

verify_boot:
    cld 
    lodsb 
    test al, al 
    jz done
    mov ah, 0x0E
    mov bh, 0x00 
    int 0x10 
    jmp verify_boot

done: 
    jmp $

; Message to indicate successful boot 
success_msg:
    db "Boot Success", 0 

; Boot signature 
times 510-($-$$) db 0 
dw 0xAA55