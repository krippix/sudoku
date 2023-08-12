; constants
vidadr dw 0A000h
chradr dw 0F000h
ascadr = 0FA6Eh
newline = 320
origin = 13220 - 4*320 - 18 ; origin coordinate of grid (top left)
line_thickness = 1
box_width = 16
box_height = 14
hor_line_length = 9*box_width + 10*line_thickness
vert_line_length = 9*box_height + 10*line_thickness - 9
box_content_offset = 5 + 3*newline ; moves char to middle of box

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
    mov bh, 0fh   ; background color 
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
screen_white endp

; draws games grid
draw_grid proc
    push bx ; lineloop
    push cx ; rowloop
    push di ; pixel location

    ; hide mouse
    call mouse_hide

    xor bx, bx
    xor cx, cx
    xor di, di

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

    call mouse_show
    pop di
    pop cx
    pop bx
    ret
draw_grid ENDP

; draws a 8x8 char from memory
; al = ascii symbol ; 30h = '0'
; bx = start pixel
draw_char proc
    push bx
    push cx ; loop increment
    push di ; calculates byte to load

    call mouse_hide

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

    call mouse_show
    pop di
    pop cx
    pop bx
    ret
draw_char endp

; draws the given byte using the following information:
; ah = byte to use
; bx = pixel to draw on
; USAGE:
draw_byte proc
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
draw_middle proc
    mov byte ptr es:[160 + 320*100 -1], 6
    mov byte ptr es:[160 + 320*99  -1], 6
    mov byte ptr es:[159 + 320*100 -1], 6
    mov byte ptr es:[159 + 320*99  -1], 6

    ret
draw_middle ENDP

; test function for measuring girdsize
draw_gridmeasure proc
    mov byte ptr es:[origin+1*321], 3
    mov byte ptr es:[origin+2*321], 3
    mov byte ptr es:[origin+3*321], 3
    mov byte ptr es:[origin+4*321], 3
    mov byte ptr es:[origin+5*321], 3
    mov byte ptr es:[origin+6*321], 3
    mov byte ptr es:[origin+7*321], 3
    mov byte ptr es:[origin+8*321], 3
    mov byte ptr es:[origin+9*321], 3
    mov byte ptr es:[origin+10*321], 3
    mov byte ptr es:[origin+11*321], 3
    mov byte ptr es:[origin+12*321], 3
    mov byte ptr es:[origin+13*321], 3
    mov byte ptr es:[origin+12*321+2], 3
    mov byte ptr es:[origin+13*321+2], 3
    mov byte ptr es:[origin+12*321+4], 3
    ret
draw_gridmeasure endp

; Draws box onto the screen
; cx = box number [0-80]
draw_box proc
    push ax ; al = byte; ah = color
    push bx ; stores origin of box to draw
    push di ; used to load data from ds
    push si ; holds calculation results

    xor ax, ax
    xor bx, bx
    xor di, di
    xor si, si

    mov bx, origin + newline + 1 ; TODO: calculate bx!!

    ; get box from ds by provided number
    mov di, cx
    mov al, fields[di]

    ; draw background (depending on if it's selected)
    mov ah, 0Fh      ; set color to white
    mov si, ax
    and si, 100000b  ; check if selected bit is set
    cmp si, 0
    jz @@skip_grey ; jump if not selected

    mov ah, Bh      ; change color to cyan

    @@skip_grey:
    call draw_box_background

    ; first check if any number is set
    xor si, si
    mov si, ax
    and si, 01111b
    cmp si, 0
    jz @@return

    ; determine color to use for char
    ; predet. | wrong   | color
    ;------------------------------
    ;    0    |    0    | blue
    ;    0    |    1    | red
    ;    1    |    0    | black
    ;    1    |    1    | yellow
    
    ; check if predetermined
    mov si, ax
    and si, 10000b
    cmp si, 0
    jz @@user_placed ; jump if not predetermined

    ; check if if wrong
    mov si, ax
    and si, 1000000b
    cmp si, 0
    jz @@predet_correct 

    ; predetermined and wrong
    mov currentColor, 0Eh ; yellow
    jmp @@color_done

    @@predet_correct:
    mov currentColor, 0 ; set color black
    jmp @@color_done ; jump to end

    @@user_placed:
    ; check if wrong
    mov si, ax
    and si, 1000000b
    cmp si, 0
    jz @@userp_correct

    ; userplaced and wrong
    mov currentColor, 0Ch ; light red
    jmp @@color_done

    @@userp_correct:
    mov currentColor, 9 ; light blue

    @@color_done:
    ; draw the char
    mov si, ax
    and si, 01111b ; write value of number from al into si

    mov ax, 30h ; 30h is the ascii symbol 0
    add ax, si

    add bx, box_content_offset
    call draw_char

    @@return:
    pop si
    pop di
    pop bx
    pop ax
    ret
draw_box endp

; Simply draws a box from given origin coordinate
; bx = coordinate
; ah = color
draw_box_background proc
    push cx ; loop counter: cl = inner; ch = outer
    push di ; coordinate for pixel

    xor cx, cx
    xor di, di

    mov di, bx

    @@draw_loop:
    mov byte ptr es:[di], ah

    inc di
    inc cl
    cmp cl, box_width
    jl @@draw_loop
    xor cl, cl
    sub di, box_width

    add di, newline
    inc ch
    cmp ch, box_height -1
    jl @@draw_loop

    pop di
    pop cx
    ret
draw_box_background endp