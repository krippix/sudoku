; hands over keyboard-task depending on game state
handle_keyboard proc
    push ax

    ; check if anything is in the keyboard buffer
    mov ax, 0100h
    int 16h
    jz @@return 

    ; read keyboard buffer
    xor ax, ax
    int 16h

    cmp al, 0
    jz @@return ; return if nothing found

    ; load last pressed button to ah = bios scan code; al = ascii char2

    cmp menu, 0
    je @@game

    call keyboard_menu
    jmp @@return

    @@game:
    call keyboard_ingame
    
    @@return:
    pop ax
    ret
handle_keyboard endp


; handle keyboard while in menu
keyboard_menu proc
    push ax

    ; check if pressed key was esc
    cmp ax, 011Bh
    je exit

    ; check for numbers 1-9
    cmp al, 031h
    je @@case_1
    cmp al, 032h
    je @@case_2
    cmp al, 033h
    je @@case_3
    cmp al, 034h
    je @@case_4
    cmp al, 035h
    je @@case_5
    cmp al, 036h
    je @@case_6
    cmp al, 037h
    je @@case_7
    cmp al, 038h
    je @@case_8
    cmp al, 039h
    je @@case_9

    jmp @@return    ; return if nothing matches

    @@case_1:       ; start game with empty grid
    call reset_data
    call start_game
    jmp @@return

    @@case_2:       ; start game with prepared grid 1
    mov ax, offset easy_sudoku
    call load_array
    call start_game
    jmp @@return
    
    @@case_3:       ; start game with prepared grid 2
    mov ax, offset medium_sudoku
    call load_array
    call start_game
    jmp @@return

    @@case_4:       ; start game with prepared grid 3
    mov ax, offset hard_sudoku
    call load_array
    call start_game
    jmp @@return

    @@case_5:
    jmp @@return

    @@case_6:       ; set timer to 15 seconds
    mov time_left, 15
    call draw_menu_timer
    jmp @@return

    @@case_7:       ; set timer to 300 seconds ( 5 min)
    mov time_left, 300
    call draw_menu_timer
    jmp @@return

    @@case_8:       ; set timer to 900 seconds (15 min)
    mov time_left, 900
    call draw_menu_timer
    jmp @@return

    @@case_9:       ; disable timer
    mov time_left, 0FFFFh
    call draw_menu_timer

    @@return:
    pop ax
    ret
keyboard_menu endp


; Handle keyboard while game is running
; ax: ah = bios_code, al = ascii
; RETURN:
; nothing
keyboard_ingame proc
    push ax
    push bx
    push cx
    push di

    ; check if pressed key is esc
    cmp ax, 011Bh
    je @@escape

    ; ignore all else on gameover
    cmp gameover, 1
    je @@return

    ; Check if active box is not 0FFh (none)
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
    cmp ax, 0E08h
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

    ; on esc: reset data, go back to menu
    jmp @@return
    @@escape:
    call reset_data
    call open_menu

    @@return:
    pop di
    pop cx
    pop bx
    pop ax
    ret
keyboard_ingame endp