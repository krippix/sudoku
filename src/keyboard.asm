handle_keyboard proc
    ; load keyboard buffer
    mov ah, 01h
    int 16h
    jz @@return ; check if not awaiting read

    ; check if pressed key is esc
    cmp al, 1Bh
    jz @@escape

    ; read key and remove from buffer
    mov ah, 00h
    int 16h
    mov dl, al ; write read symbol to dl
    
    ; print read value
    mov ah, 02h
    int 21h

    @@return:
    ret

    ; on esc: clear buffer and jmp to exit
    @@escape:
    mov ah, 00h 
    int 16h
    jmp exit

handle_keyboard endp