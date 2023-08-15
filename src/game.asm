handle_game proc
    call find_collisions
    ret
handle_game endp

; searches for collisions on last changed box
find_collisions proc
    push ax
    push bx
    push di

    mov bx, last_modified
    cmp last_modified, 0FFh ; check if nothing changed
    je @@return

    ; write box's vertical and horizontal rows to cx
    ; cl = horizontal | ch = vertical
    call box_to_row

    ; find collisions in horizontal row
    call find_collisions_hor

    ; find collisions in vertical row
    ; find collsions in current cube

    mov last_modified, 0FFh ; reset last modified to none

    @@return:
    pop di
    pop bx
    pop ax
    ret
find_collisions endp

; marks collisions in provided row
; cl = row to check for collisions
; RETURN:
; nothing
find_collisions_hor proc
    push ax
    push bx     ; holds numbers without data
    push cx     ; holds bytes to compare
    push di     ; current box
    push si     ; box to compare to

    xor ax, ax
    mov al, cl

    ; determine left-most box in the row
    mov bx, 9
    mul bx
    mov di, ax

    push dx
    mov dx, di
    call draw_dx
    pop dx

    ; iterate over the row
    ; make ax the upper bound
    add ax, 9

    @@outer_loop:
    mov si, di
    inc si

    mov cl, [fields+di] ; load byte and isolate number
    mov bl, cl
    and bl, 00001111b

    @@inner_loop:
    mov ch, [fields+si] ; load byte and isolate number
    mov bh, ch
    and bh, 00001111b

    cmp bh, bl
    jne @@not_equal

    or cl, 01000000b
    or ch, 01000000b

    mov [fields+di], cl
    mov [fields+si], ch

    ; draw changed boxes
    push cx
    mov cx, di
    call draw_box
    mov cx, si
    call draw_box
    pop cx

    @@not_equal:
    inc si
    cmp si, ax
    jl @@inner_loop
    inc di
    cmp di, ax
    jl @@outer_loop

    @@return:
    pop si
    pop di
    pop cx
    pop bx
    pop ax
    ret
find_collisions_hor endp

find_collisions_vert proc
    ret
find_collisions_vert endp

; checks if collisions were resolved
resolve_collision proc
    ret
resolve_collision endp

; takes boxnumber and returns horizontal row number [0-8]
; bx = boxnumber
; RETURN
; cl = horizontal row number
; ch = vertical row number
box_to_row proc
    push bx

    xor cx, cx

    @@row_loop:
    sub bx, 9
    inc cl
    jnc @@row_loop
    dec cl
    add bx, 9

    ; remainder should be horizontal row number
    mov ch, bl

    pop bx
    ret
box_to_row endp
