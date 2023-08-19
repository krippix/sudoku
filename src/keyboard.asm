handle_keyboard proc
    push ax
    push bx
    push cx
    push dx
    push di

    xor bx, bx

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

    ; jump back if game is over
    cmp gameover, 1
    je @@return

    ; Check if active box is NOT 0FFh
    mov bl, active_box
    cmp bl, 0FFh  
    je @@return

    ; check if active box is predetermined
    mov di, bx
    mov cl, [fields+di]
    and cl, 00010000b
    cmp cl, 0
    jne @@return

    ; check for backspace
    cmp al, 08h
    jne @@skip_backspace

    mov di, bx
    mov cl, [fields+di]
    and cl, 00010000b
    mov [fields+di], cl
    mov active_box, 0FFh

    jmp @@draw

    @@skip_backspace:
    ; Check for number 1-9
    cmp al, 31h
    jl @@return
    
    cmp al, 39h
    jg @@return

    ; write new number to data
    mov cl, [fields+di]
    and cl, 10010000b       ; clear existing number, make inactive and remove collision bit
    sub al, 30h
    or cl, al
    mov [fields+di], cl
    mov active_box, 0FFh    ; mark box as inactive

    @@draw:
    mov cx, di
    mov last_modified, cx
    call draw_box

    @@return:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

    ; on esc: clear buffer and jmp to exit
    @@escape:
    mov ah, 00h 
    int 16h
    jmp exit

handle_keyboard endp