handle_keyboard proc
    push ax

    ; load keyboard buffer
    mov ax, 0100h
    int 16h
    jz @@return ; check if not awaiting read

    ; check if pressed key is esc
    cmp al, 1Bh
    jz @@escape

    ; read key and remove from buffer
    mov ah, 00h
    int 16h

    @@return:
    pop ax
    ret

    ; on esc: clear buffer and jmp to exit
    @@escape:
    mov ah, 00h 
    int 16h
    jmp exit

handle_keyboard endp