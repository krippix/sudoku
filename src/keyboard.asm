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

    ; TODO: Check if active box is NOT 0FFh

    ; TODO: Check if key is 1-9, enter, delete or backspace

    ; TODO: Write pressed key to data

    @@return:
    pop ax
    ret

    ; on esc: clear buffer and jmp to exit
    @@escape:
    mov ah, 00h 
    int 16h
    jmp exit

handle_keyboard endp