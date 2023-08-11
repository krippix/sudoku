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

; Get mouse position
; RETURN:
; bx = button press
; cx = x
; dx = y
get_mouse_pos proc
    push ax

    ; Check if mouse is present
    mov ax, 0
    int 33h
    cmp ax, 0FFFFh
    je @@return ; jump to end if mouse inactive

    ; get position and button status
    mov ax, 3
    int 33h
    shr cx, 1 ; adjust for 320x200 from 640x200

    @@return:
    pop ax
    ret
get_mouse_pos endp