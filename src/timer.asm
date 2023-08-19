; prepares timer interrupt
prepare_int proc
    push ax
    push bx
    push dx
    push ds
    push es

    ; load current interrupt vector (4 bytes large)
    mov ax, 351Ch   ; 35h: load vector to es:bx, 08h the vector to load
    int 21h

    mov ax, es

    mov previous_vector, ax     ; write es address
    mov previous_vector+2, bx   ; write interrupt result

    push ds
    push cs
    pop ds      ; cs -> ds

    mov dx, offset timer_int

    mov ax, 251Ch               ; set interrupt vector 08h
    int 21h                     ; DS:DX -> new interrupt handler

    pop ds      ; ds -> ds
    pop es
    pop ds
    pop dx
    pop bx
    pop ax
    ret
prepare_int endp

; called every 55ms as interrupt 1C around 18 times per second
timer_int:
    cmp gameover, 1
    je @@return

    dec time_left
    cmp time_left, 0
    jne @@draw
    ;call game_lost
    call game_won
    @@draw:
    mov dx, time_left
    call draw_dx

    ; TODO convert to minutes:seconds and display as such
    @@return:
    iret