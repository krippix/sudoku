handle_game proc
    call find_collisions
    ret
handle_game endp

; searches for collisions on last changed box
find_collisions proc
    push ax
    push bx
    push cx
    push dx
    push di

    mov bx, last_modified
    cmp last_modified, 0FFh ; check if nothing changed
    je @@return

    ; write box's vertical and horizontal rows to cx
    ; cl = horizontal | ch = vertical
    call box_to_row

    ; find collisions
    call find_collisions_hor
    call find_collisions_vert

    ; determine current cube
    ; dl = cube nr.
    call rows_to_cube

    ; find collsions in current cube
    call find_collisions_cube

    push dx
    mov dx, bx
    call draw_dx
    pop dx

    mov last_modified, 0FFh ; reset last modified to none

    @@return:
    pop di
    pop dx
    pop cx
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

; marks collisions in provided row
; ch = row to check for collisions
; RETURN:
; nothing
find_collisions_vert proc
    push ax
    push bx     ; holds numbers without data
    push cx     ; holds bytes to compare
    push di     ; current box
    push si     ; box to compare to

    xor ax, ax
    mov al, ch

    ; top-most box in the row
    mov di, ax

    ; make ax the upper bound
    add ax, 72

    @@outer_loop:
    mov si, di
    add si, 9

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
    add si, 9
    cmp si, ax
    jle @@inner_loop
    add di, 9
    cmp di, ax
    jl @@outer_loop

    @@return:
    pop si
    pop di
    pop cx
    pop bx
    pop ax
    ret
find_collisions_vert endp

; takes cube number and determines collisions
; bl = cube
; RETURN:
; nothing
find_collisions_cube proc
    push ax
    push cx     ; holds bytes to compare
    push di     ; current box
    push si     ; box to compare to

    xor ax, ax
    xor di, di

    ; set top-left box in the cube
    cmp bl, 0
    je @@case_0
    cmp bl, 1
    je @@case_1
    cmp bl, 2
    je @@case_2
    cmp bl, 3
    je @@case_3
    cmp bl, 4
    je @@case_4
    cmp bl, 5
    je @@case_5
    cmp bl, 6
    je @@case_6
    cmp bl, 7
    je @@case_7
    cmp bl, 8
    je @@case_8

    @@case_0:
    mov bl, 0
    jmp @@jump_table_end
    @@case_1:
    mov bl, 3
    jmp @@jump_table_end
    @@case_2:
    mov bl, 6
    jmp @@jump_table_end
    @@case_3:
    mov bl, 27
    jmp @@jump_table_end
    @@case_4:
    mov bl, 30
    jmp @@jump_table_end
    @@case_5:
    mov bl, 33
    jmp @@jump_table_end
    @@case_6:
    mov bl, 54
    jmp @@jump_table_end
    @@case_7:
    mov bl, 57
    jmp @@jump_table_end
    @@case_8:
    mov bl, 60

    @@jump_table_end:
    jmp @@return ; tmp

    ; TODO IMPLEMENT ITERATION OVER ELEMENTS

    ; make ax the upper bound
    add ax, 72

    @@outer_loop:
    mov si, di
    add si, 9

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
    add si, 9
    cmp si, ax
    jle @@inner_loop
    add di, 9
    cmp di, ax
    jl @@outer_loop

    @@return:
    pop si
    pop di
    pop cx
    pop ax
    ret
find_collisions_cube endp

; takes boxnumber and returns horizontal row number [0-8]
; bx = boxnumber
; RETURN:
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

; determine cube nr from horizontal and vertical row
; formula: bl = ( ch // 3 ) * 3 + ( cl // 3)
; ch = vertical row
; cl = horizontal row
; RETURN:
; bl = cube number
rows_to_cube proc
    push ax
    push cx

    xor ax, ax
    xor bx, bx

    ; ax = ( ch // 3 ) * 3
    mov al, cl
    mov dl, 3

    div dl
    mul dl
    mov bx, ax

    ; ax = cl // 3
    mov al, ch
    div dl

    add ax, bx

    mov bl, al 

    pop cx
    pop ax
    ret
rows_to_cube endp