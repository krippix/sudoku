; prepares timer interrupt
prepare_int proc
    push ax
    push bx
    push dx
    push es

    ; load current interrupt vector (4 bytes large)
    mov ax, 351Ch   ; 35h: load vector to es:bx, the vector to load
    int 21h

    ;mov ax, es
    push ax
    pop es

    mov [previous_vector], ax     ; write es address
    mov [previous_vector+2], bx   ; write interrupt result

    push ds
    push cs
    pop ds      ; cs -> ds

    mov dx, offset timer_int

    mov ax, 251Ch               ; set interrupt vector
    int 21h                     ; DS:DX -> new interrupt handler

    pop ds      ; ds -> ds

    pop es
    pop dx
    pop bx
    pop ax
    ret
prepare_int endp
; called every 55ms as interrupt 1C around 18 times per second
timer_int:
    push ax
    push dx
    push ds

    mov ax, @DATA
    mov ds, ax

    cmp gameover, 1
    je @@return

    cmp time_left, 0FFFFh
    je @@return

    cmp menu, 1
    je @@return

    ; return if buffer not "full"
    inc time_buffer
    cmp time_buffer, 18
    jl @@return

    mov time_buffer, 0 ; reset buffer

    dec time_left
    cmp time_left, 0
    jne @@draw
    call game_lost

    @@draw:
    mov dx, time_left
    push bx
    mov bx, newline+1
    call draw_dx
    pop bx

    ; TODO? convert to minutes:seconds and display as such
    @@return:
    pop ds
    pop dx
    pop ax
    iret