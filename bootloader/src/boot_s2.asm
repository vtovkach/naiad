
BITS 16 
ORG 0x7E00

; ------------
; CONSTANTS
; ------------
SMAP        equ 0x534D4150 
E820_MAX    equ 64
E820_ES     equ 0x0000

GDT_NULL    equ 0x0000000000000000
GDT_CODE    equ 0x00CF9A000000FFFF
GDT_DATA    equ 0x00CF92000000FFFF

stage2_start: 
    
    ; Display Success Transition Message 
    mov si, stage2_success_msg
    call printStatus

    ; Retrieve memory layout 
    call get_e820

    ; Display E820 Success Message 
    mov si, e820_retrieve_msg
    call printStatus

    ; Sleep for 1.5 seconds before entering PM 
    mov ah, 0x86          ; wait command 
    mov cx, 0x0016        ; high word
    mov dx, 0xE360        ; low word  
    int 0x15
    
    ; Enter Protected Mode 
    jmp switch_mode

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

    mov ax, E820_ES
    mov es, ax
    mov di, e820_buf

    xor ebx, ebx
    xor bp, bp

.e820_next:
    mov edx, SMAP
    mov eax, 0xE820
    mov dword [es:di+20], 1
    mov ecx, 24
    int 0x15
    jc .done

    cmp eax, SMAP
    jne .done

    ; ignore zero-length
    mov eax, [es:di+8]
    or  eax, [es:di+12]
    jz  .skip_store

    inc bp
    add di, 24
    cmp bp, E820_MAX
    jae .done

.skip_store:
    test ebx, ebx
    jne .e820_next

.done:
    mov [e820_count], bp

    pop es
    pop ds
    popad
    ret

; To initialize Protected Mode 
; 1.) cli  
; 2.) Set up GDT wiht at least CODE Segment and Data Segment 
; 3.) Load GDT register lgdt 
; 4.) Set first bit of CR0 
; 5.) Perform far jump "jmp CODE_SEGMENT:EIP" 
;       - CODE_SEGMENT -> pointer to the CODE SEGMENT in GDT 
;       - EIP -> pointer to the first instruction to execute  
;

switch_mode: 
    cli 

    xor ax, ax 
    mov es, ax 
    mov ds, ax 
    mov di, 0xBE00

    cld 

    ; Load Null Segment Descriptor 
    xor ax, ax 
    stosw  
    stosw
    stosw
    stosw 

    ; Load Code Segment Descriptor 
    mov ax, 0xFFFF
    stosw 
    mov ax, 0x0000
    stosw 
    mov ax, 0x9A00
    stosw 
    mov ax, 0x00CF
    stosw 

    ; Load Data Segment Descriptor 
    mov ax, 0xFFFF
    stosw 
    mov ax, 0x0000
    stosw 
    mov ax, 0x9200
    stosw 
    mov ax, 0x00CF
    stosw 

    lgdt [gdt_desc] 

    mov eax, cr0 
    or eax, 1 
    mov cr0, eax 

    jmp 0x08:PM 

; Halt CPU 
halt: 
    cli 
    hlt 

; ---------------
; Status Messages
; --------------- 
stage2_success_msg: db "Second stage loaded successfully", 0x0D, 0x0A, 0
e820_retrieve_msg:  db "E820 Retrieved Successfully", 0x0D, 0x0A, 0

gdt_desc:
    dw 0x17         ; limit (3 entries)
    dd 0x0000BE00   ; base (linear address )

; ------------------ 
; E820 Data 
; ------------------
e820_count: dw 0
e820_buf:
    times(E820_MAX*24) db 0



; ====================================== PROTECTED MODE ===========================================



[bits 32]
PM:
    mov ax, 0x10          ; DATA_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x00007C00   

    mov edi, 0xB8000
    mov ecx, 80*25
    mov ax, 0x0720
    cld 
    rep stosw

    mov esi, protected_mode_msg
    mov edi, 0xB8000
    mov ah, 0x0F  ; white on black 
    cld 

.print:
    lodsb 
    test al, al 
    jz .done 
    stosw 
    jmp .print

.done 

    jmp halt

protected_mode_msg:
    db "Protected Mode Entered Successfully"
pm_msg_end: 


PM_MSG_LEN  equ (pm_msg_end - protected_mode_msg)

times (32*512) - ($-$$) db 0 
