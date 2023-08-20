; Hides Mouse cursor
mouse_hide proc
    push ax
    push bx
    mov ax, 2
    int 33h
    pop bx
    pop ax
    ret
mouse_hide endp


; Shows mouse cursor
mouse_show proc
    push ax
    mov ax, 1
    int 33h
    pop ax
    ret
mouse_show endp


; get mouse button press information
; RETURN:
; bx = no of presses
; cx = x-coord
; dx = y-coord
get_mouse_press proc
    push ax

    ; Check if mouse is present
    ;mov ax, 0
    ;int 33h
    ;cmp ax, 0FFFFh
    ;je @@return ; jump to end if mouse inactive

    mov ax, 5
    int 33h ; bx = no of presses; cx = x-coor; dx = y-coord

    shr cx, 1 ; corrects 640 to 320

    @@return:
    pop ax
    ret
get_mouse_press endp


; Handles mouse inputs
handle_mouse proc
    push ax
    push bx
    push cx
    push dx
    push di

    xor ax, ax
    xor di, di

    cmp menu, 1
    je @@return

    call get_mouse_press
    cmp bx, 0
    jz @@return ; return if nothing was pressed

    ; calculate which box (if any) the pixel belongs to
    call coord_to_box ; returns to al; -> FF is none
    cmp al, 0FFh      ; jump to end if it's in no box
    je @@return

    ; calculate pixel from coord
    call coord_to_pixel ; returns to cx

    ; if clicked box is not the currently highlighted one, deactivate the old one
    cmp al, active_box
    je @@invert_highlight ; jmp if equal

    cmp active_box, 0FFh
    je @@invert_highlight ; jmp if FF (none)

    ; switch active status of previous
    xor bx, bx
    mov bl, active_box
    mov di, bx
    mov cl, [fields+di]
    xor cl, 00100000b
    mov [fields+di], cl

    mov cx, di
    call draw_box

    ; invert the clicked box's highlighted status
    @@invert_highlight:
    mov di, ax
    mov al, [fields+di]
    xor al, 00100000b
    mov [fields+di], al

    mov cx, di
    call draw_box

    ; Change active_box variable to new box (if it became active)
    mov cx, 00100000b
    and cx, ax
    cmp cx, 0
    je @@inactive ; jump if zero

    mov ax, di
    mov active_box, al
    jmp @@return

    @@inactive:
    mov ax, 0FFh
    mov active_box, al

    @@return:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
handle_mouse endp