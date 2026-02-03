
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

    ; Retrieve memory layout 
    call get_e820

    call print_e820

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

; ------------------
; E820 display helpers
; ------------------

; Print a single character in AL using teletype BIOS
putc:
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10
    ret

; Print 8 hex digits from EAX (uppercase)
; Clobbers: EAX, ECX, EBX
print_dword_hex:
    push ecx
    push ebx
    mov ecx, 8
    mov ebx, eax
.pd_loop:
    mov edx, ebx
    shr edx, 28
    and dl, 0x0F
    cmp dl, 10
    jb .pd_digit
    add dl, 'A' - 10
    jmp .pd_write
.pd_digit:
    add dl, '0'
.pd_write:
    mov al, dl
    call putc
    shl ebx, 4
    dec ecx
    jnz .pd_loop
    pop ebx
    pop ecx
    ret

; Print 64-bit value given in EDX:EAX as 16 hex digits (EDX high, EAX low)
print_qword_hex_regs:
    push eax
    push edx
    mov eax, edx
    call print_dword_hex
    pop edx
    pop eax
    call print_dword_hex
    ret

; Display E820 memory map entries as: 0xHHHHHHHHLLLLLLLL - 0xHHHHHHHHLLLLLLLL : TTTTTTTT\r\n
print_e820:
    pushad
    push ds
    push es

    mov ax, E820_ES
    mov es, ax

    xor edi, edi
    mov di, [e820_count]
    cmp edi, 0
    je .pe_done

    mov si, e820_header
    call printStatus

    xor esi, esi
    mov si, e820_buf
.pe_loop:
    ; load base
    mov eax, [es:esi+0]
    mov edx, [es:esi+4]

    mov si, hex_prefix
    call printStatus

    ; print base high:low
    push eax
    push edx
    mov eax, edx
    call print_dword_hex
    pop edx
    pop eax
    call print_dword_hex

    mov si, dash_space
    call printStatus

    ; compute end = base + length - 1
    mov ebx, [es:esi+8]   ; len low
    mov ebp, [es:esi+12]  ; len high
    mov eax, [es:esi+0]   ; base low
    mov edx, [es:esi+4]   ; base high
    add eax, ebx
    adc edx, ebp
    dec eax
    sbb edx, 0

    mov si, hex_prefix
    call printStatus

    push eax
    push edx
    mov eax, edx
    call print_dword_hex
    pop edx
    pop eax
    call print_dword_hex

    mov si, colon_space
    call printStatus

    ; print type
    mov eax, [es:esi+16]
    call print_dword_hex

    mov si, newline
    call printStatus

    add esi, 24
    dec edi
    jnz .pe_loop

.pe_done:
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

e820_header: db "E820 Memory Map:", 0x0D, 0x0A, 0
hex_prefix: db "0x", 0
dash_space: db " - ", 0
colon_space: db " : ", 0
newline: db 0x0D, 0x0A, 0

; ------------------ 
; E820 Data 
; ------------------
e820_count: dw 0
e820_buf:
    times(E820_MAX*24) db 0


times (32*512) - ($-$$) db 0 