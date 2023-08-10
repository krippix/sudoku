vidadr dw 0A000h
chradr dw 0F000h
ascadr = 0FA6Eh
newline = 320

prep_video proc
    push ax

    xor ax, ax

    ; get videomode and save for later use
    mov ah, 0Fh
    int 10h
    mov videomode, al

    ; set video mode
    ; 13H: 320x200, 264 colors
    mov ax, 13h
    int 10h

    ; prepare video segment
    mov es, vidadr

    call screen_white

    pop ax
    ret
prep_video endp

; sets entire screen to white
screen_white proc
    push ax
    push bx
    push cx
    push dx

    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx

    mov ah, 06h    
    mov dx, 184Fh
    mov bh, 1Eh   
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
screen_white endp

; draws games grid
draw_grid PROC
    push bx ; lineloop
    push cx ; rowloop
    push di ; pixel location

    xor bx, bx
    xor cx, cx
    xor di, di

    origin = 13220 - 4*320 - 18
    line_thickness = 1
    box_width = 16
    box_height = 14
    hor_line_length = 9*box_width + 10*line_thickness
    vert_line_length = 9*box_height + 10*line_thickness - 9

    ; draw secondary vertical
    @@subhorloop:
    mov byte ptr es:[origin+di], 7 ; origin = 13220

    inc bx
    inc di
    cmp bx, hor_line_length
    jl @@subhorloop

    xor bx, bx
    inc cx
    add di, (newline*box_height) - hor_line_length
    cmp cx, 10
    jl @@subhorloop

    xor bx, bx
    xor cx, cx
    xor di, di

    ; draw secondary vertical
    @@subverloop:
    mov byte ptr es:[origin+di], 7

    inc bx
    add di, newline
    cmp bx, vert_line_length
    jl @@subverloop

    xor bx, bx

    inc cx
    sub di, vert_line_length*newline ; return to height of origin
    add di, box_width + line_thickness ; move to next row
    cmp cx, 10
    jl @@subverloop

    xor bx, bx
    xor cx, cx
    xor di, di

    ; draw main horizontal
    @@mainhorloop:
    mov byte ptr es:[origin+di], 0

    inc bx
    inc di
    cmp bx, hor_line_length
    jl @@mainhorloop

    xor bx, bx
    add cx, 3
    add di, (3*newline*box_height) - hor_line_length
    cmp cx, 10
    jl @@mainhorloop

    xor bx, bx
    xor cx, cx
    xor di, di

    ; draw main vertical
    @@mainverloop:
    mov byte ptr es:[origin+di], 0

    inc bx
    add di, newline
    cmp bx, vert_line_length
    jl @@mainverloop

    xor bx, bx

    add cx, 3
    sub di, vert_line_length*newline ; return to height of origin
    add di, 3*box_width + 3*line_thickness ; move to next row
    cmp cx, 10
    jl @@mainverloop

    pop di
    pop cx
    pop bx
    ret
draw_grid ENDP

; draws a 8x8 char from memory
; al = ascii symbol ; 30h = 0
; bx = start pixel
draw_char proc
    push cx ; loop increment
    push di ; calculates byte to load

    xor cx, cx
    xor di, di

    ; convert ascii to memory location
    mov ah, 0
    mov di, 8
    mul di
    mov di, ax

    ; draw 8x8 char row by row
    @@byte_loop:
    ; get byte for char
    push es
    mov ax, chradr
    mov es, ax
    mov ah, byte ptr es:[ascadr+di]
    pop es
    
    call draw_byte

    add bx, 320 ; newline
    inc di
    inc cx
    cmp cx, 8
    jl @@byte_loop ; while cx < 8

    pop di
    pop cx
    ret
draw_char endp

; draws the given byte using the following information:
; ah = byte to use
; bx = pixel to draw on
; USAGE:
draw_byte PROC
    push cx ; ch = loop counter | cl = color
    push di ; address offset to write to

    xor cx, cx
    xor di, di

    mov cl, currentColor
    mov di, bx ; bx cant be used for index access

    @@draw_loop:
    ; left shift and jump no carry
    rcl ah, 1
    jnc @@skip

    ;mov al, byte ptr es:[di] ; dummy read test
    mov byte ptr es:[di], cl

    @@skip:
    inc di
    inc ch
    cmp ch, 8
    jl @@draw_loop ; jump back up if bit is not finished

    ;mov bx, di

    pop di
    pop cx
    ret
draw_byte ENDP

; draws middle dot onto the canvas
draw_middle PROC
    mov byte ptr es:[160 + 320*100 -1], 6
    mov byte ptr es:[160 + 320*99 -1], 6
    mov byte ptr es:[159 + 320*100 -1], 6
    mov byte ptr es:[159 + 320*99 -1], 6

    ret
draw_middle ENDP