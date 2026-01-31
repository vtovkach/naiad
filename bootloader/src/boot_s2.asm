
org 0x7E00
bits 16 

start: 
    ; Stage 2 Code goes here 
    
    mov si, stage2_success_msg
    call printStatus

    jmp done 

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

; Halt CPU 
done: 
    cli 
    hlt 

stage2_success_msg:
    db "Second stage loaded successfully", 0x0D, 0x0A, 0

times (32*512) - ($-$$) db 0 