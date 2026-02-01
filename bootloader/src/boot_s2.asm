
org 0x7E00
bits 16 

; ------------
; CONSTANTS
; ------------
SMAP        equ 0x534D4150 
E820_MAX    equ 64
E820_ES     equ 0x0000

start: 
    
    ; Display Success Transition Message 
    mov si, stage2_success_msg
    call printStatus

    call get_e820

    call display_e820

    jmp halt

; Set SI to point to the message before the function call
printStatus:
    cld 
.beg:
    lodsb 
    test al, al 
    jz .end_print 
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10
    jmp .beg 
.end_print:
    ret

get_e820:
    pushad 
    push ds 
    push es 

    xor ax, ax 
    mov ds, ax 

    ; Point ES:DI at buffer 
    mov ax, E820_ES
    mov es, ax 
    mov di, e820_buf

    xor ebx, ebx 
    xor bp, bp 
    mov edx, SMAP

.e820_next:
    mov eax, 0xE820 
    mov ecx, 24      ; 24 bytes per entry 
    int 0x15
    jc .done         ; CF=1 -> finished/error 

    cmp eax, SMAP
    jne .done        ; BIOS did't return SMAP -> abort

    mov eax, [es:di+8]
    or eax, [es:di+12]
    jz .skip 

    inc bp

    add di, 24
    cmp bp, E820_MAX
    jae .done 

.skip:
    test ebx, ebx 
    jne .e820_next 

.done:
    mov [e820_count], bp 

    pop es
    pop ds
    popad 
    ret

; Halt CPU 
halt: 
    cli 
    hlt 

; ---------------
; Status Messages
; --------------- 
stage2_success_msg: db "Second stage loaded successfully", 0x0D, 0x0A, 0
str_base: db "BASE=", 0
str_len:  db " LEN=", 0
str_type: db " TYPE=", 0

; ------------------ 
; E820 Data 
; ------------------
e820_count: dw 0
e820_buf:
    times(E820_MAX*24) db 0


times (32*512) - ($-$$) db 0 