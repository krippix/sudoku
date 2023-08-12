; Hides Mouse cursor
mouse_hide proc
    push ax
    mov ax, 2
    int 33h
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
    push bx
    push cx
    push dx
    push di

    call get_mouse_press
    cmp bx, 0
    jz @@return ; return if nothing was pressed

    ; TEST: if button was pressed, color pixel that was clicked
    call coord_to_pixel ; returns to cx

    @@return:
    pop di
    pop dx
    pop cx
    pop bx
    ret
handle_mouse endp