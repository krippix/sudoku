; constants
vidadr dw 0A000h
chradr dw 0F000h
ascadr = 0FA6Eh
newline = 320
origin = 13220 - 4*320 - 18 ; origin coordinate of grid (top left)
line_thickness = 1
box_width = 16
box_height = 14
hor_line_length = (9*box_width) + (10*line_thickness)
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

    call mouse_hide

    mov ah, 06h
    mov dx, 184Fh
    mov bh, 0fh   ; background color 
    int 10h

    call mouse_show

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
; al = ascii symbol ; 30h = '0' ; 41h = 'A'
; bx = start pixel
draw_char proc
    push ax
    push bx
    push cx ; loop increment
    push dx
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
    pop dx
    pop cx
    pop bx
    pop ax
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


; draws dx register to top left of the screen
; dx = data to display
; bx = pixel to start at
draw_dx proc
    push ax ; ascii symbol to draw <- result
    push bx ; current pixel
    push cx ; 
    push dx ; data to display
    push di ; loop counter
    push si ; value to and with

    xor ax, ax
    mov cl, 12
    xor di, di
    mov si, 0F000h
    mov currentColor, 8

    ; draw as hex
    @@byte_loop:
    mov ax, dx
    and ax, si
    shr si, 4
    shr ax, cl
    cmp al, 9
    jle @@draw       ; dont jump if letter
    add al, 7

    @@draw:
    push ax
    mov ah, 0Fh
    call draw_box_background
    pop ax
    add al, 30h
    call draw_char  ; al = ascii symbol ; 30h = '0' , 40h = 'A'
    add bx, 9       ; move cursor

    sub cl, 4
    inc di
    cmp di, 4
    jne @@byte_loop

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_dx endp


; draws middle dot onto the canvas
draw_middle proc
    mov byte ptr es:[160 + 320*100 -1], 6
    mov byte ptr es:[160 + 320*99  -1], 6
    mov byte ptr es:[159 + 320*100 -1], 6
    mov byte ptr es:[159 + 320*99  -1], 6

    ret
draw_middle ENDP

; Draws box onto the screen
; cx = box number [0-80]
draw_box proc
    push ax ; al = byte; ah = color
    push bx ; stores origin of box to draw
    push cx ; box to draw
    push di ; used to load data from ds
    push si ; holds calculation results

    xor ax, ax
    xor bx, bx
    xor di, di
    xor si, si

    call mouse_hide

    mov al, cl
    call get_box_origin

    ; get box from ds by provided number
    mov di, cx
    mov al, [fields+di]

    ; draw background (depending on if it's selected)
    mov ah, 0Fh      ; set color to white
    mov si, ax
    and si, 100000b  ; check if selected bit is set
    cmp si, 0
    jz @@skip_grey   ; jump if not selected

    mov ah, 0Ah       ; change color to green

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
    ;    1    |    1    | magenta
    
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
    mov currentColor, 0Dh ; magenta
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
    call mouse_show

    pop si
    pop di
    pop cx
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


draw_all_boxes proc
    push ax
    push cx
    push di

    xor di, di

    @@draw_loop:
    mov cx, di
    call draw_box
    inc di
    cmp di, 81
    jl @@draw_loop

    pop di
    pop cx
    pop ax
    ret
draw_all_boxes endp


; draws all boxes with value that is not 0
draw_set_boxes proc
    push bx
    push cx ; box nr to draw
    push di
    
    xor cx, cx
    xor di, di

    @@box_loop:
    mov bl, [fields+di]
    cmp bl, 0
    je @@skip_draw

    call draw_box
    
    @@skip_draw:
    inc cx
    inc di
    cmp cx, 81
    jl @@box_loop

    pop di
    pop cx
    pop bx
    ret
draw_set_boxes endp


; Calculates pixel from coordinate
; cx = x-coord
; dx = y-coord
; RETURN:
; cx = pixel
coord_to_pixel proc
    push ax
    push bx
    xor ax, ax

    mov ax, dx
    mov bx, 320
    mul bx ; := ax * bx

    add ax, cx
    mov cx, ax

    pop bx
    pop ax
    ret
coord_to_pixel endp


; get coord from pixel
; ax = pixel
; RETURN:
; cx = x-coord
; dx = y-coord
pixel_to_coord proc
    push bx

    xor cx, cx
    xor dx, dx
    
    ; y = count how often <newline> can be substracted
    @@subtractloop:
    sub ax, newline
    inc dl
    jnc @@subtractloop
    add ax, newline
    dec dl

    ; x = leftover number
    mov cl, al

    pop bx
    ret
pixel_to_coord endp


; calculates box [0-81] from given pixel
; cx = x-coord
; dx = y-coord
; RETURN:
; al = box nr -> FF is none
coord_to_box proc
    push cx
    push dx
    push di
    push si
 
    mov bh, cl
    mov bl, dl

    ; determine if completely out of the grid
    cmp cx, origin_x
    jl @@none

    cmp cx, 0EBh ; multiplying variables yielded wrong results
    jg @@none
    
    cmp dx, origin_y
    jl @@none

    cmp dx, 0A3h
    jg @@none

    ; map x axis to 1-9 (from origin to origin + horizontal_line_length)
    xor di, di
    mov si, origin_x

    @@x_loop:
    inc di
    add si, box_width + 1
    cmp cx, si
    jg @@x_loop
    dec di
    mov ax, di

    ; map y axis to 1-9
    xor di, di
    mov si, origin_y
    
    @@y_loop:
    inc di
    add si, box_height
    cmp dx, si
    jg @@y_loop
    dec di
    
    push ax
    push bx 
    mov ax, di
    mov bx, 9
    mul bx
    mov di, ax
    pop bx
    pop ax
    add ax, di

    @@return:
    pop si
    pop di
    pop dx
    pop cx
    ret

    @@none:
    mov al, 0FFh
    jmp @@return
coord_to_box endp


; write to origin_x and _y
set_origin_coord proc
    push ax
    push cx
    push dx

    mov ax, origin
    call pixel_to_coord
    mov origin_x, cx
    mov origin_y, dx

    pop dx
    pop cx
    pop ax
    ret
set_origin_coord endp

; calculates box's origin by it's number
; al = box_number
; RETURN
; bx = pixel
get_box_origin proc
    push ax
    push cx
    push di
    push si

    xor di, di
    mov ah, 0
    mov al, cl

    ; check which row
    @@y_loop:
    sub al, 9
    inc di
    jnc @@y_loop
    dec di
    add al, 9

    ;         |--- x-axis ---|   |------- y-axis ----------|
    ; coord = (ax * box_width) + (di * box_height * newline) + origin
    ; (ax * box_width)
    mov cx, box_width + 1 
    mul cx
    mov cx, ax

    ; (di * box_height * newline)
    mov ax, box_height * newline
    mul di

    add ax, cx
    add ax, origin + 1

    mov bx, ax
    add bx, newline

    pop si
    pop di
    pop cx
    pop ax
    ret
get_box_origin endp


; draws array's ascii values byte for byte
; color: uses current_color variable
; 0FFh marks end of array! (sorry ÿ)
; ax = offset to first byte
; bx = starting pixel
; RETURN:
; nothing
draw_array proc
    push ax
    push bx
    push cx
    push di

    mov di, ax

    mov cl, currentColor

    @@draw_loop:
    mov al, [di]

    cmp al, 0FFh
    je @@return
    
    call draw_char

    add bx, 9
    inc di
    jmp @@draw_loop

    @@return:
    pop di
    pop cx
    pop bx
    pop ax
    ret
draw_array endp


; Draws indicator showing that the game is won
draw_win proc
    push ax
    push bx
    push cx
    push di

    xor ax, ax
    xor di, di

    mov currentColor, 2     ; red color
    
    mov bx, 16*320+125
    @@draw_loop:
    mov al, [str_you_win+di]

    call draw_char

    add bx, 9
    inc di
    cmp di, 8
    jl @@draw_loop

    mov currentColor, cl    ; restore previous color

    pop di
    pop cx
    pop bx
    pop ax
    ret
draw_win endp


; Draws indicator showing that the game was lost
; that implementation is ugly
draw_lose proc
    push ax
    push bx
    push cx
    push dx
    push di

    xor ax, ax
    xor di, di
    ; al = ascii symbol ; 30h = '0' ; 41h = 'A'
    ; bx = start pixel
    ; draw_char

    mov cl, currentColor
    mov currentColor, 4     ; red color
    
    mov bx, 16*320+120

    @@draw_loop:
    mov al, [str_you_lose+di]

    call draw_char

    add bx, 9
    inc di
    cmp di, 9
    jl @@draw_loop

    mov currentColor, cl    ; restore previous color

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_lose endp


draw_menu proc
    push ax
    push bx

    ; clear screen
    call screen_white

    ; sudoku text
    mov currentColor, 0
    mov bx, 10*320+130
    mov ax, offset str_sudoku
    call draw_array

    ; draw current timer
    call draw_menu_timer
    
    ; esc
    mov currentColor, 8
    mov bx, 60*320+6+30
    mov ax, offset str_esc
    call draw_array

    ; option 1
    add bx, 15*320+18
    mov ax, offset str_loadEmpty
    call draw_array

    ; option 2
    add bx, 9*320
    mov ax, offset str_loadEasy
    call draw_array

    ; option 3
    add bx, 9*320
    mov ax, offset str_loadMedium
    call draw_array

    ; option 4
    add bx, 9*320
    mov ax, offset str_loadHard
    call draw_array

    ; option 4
    add bx, 9*320

    ; option 6
    add bx, 9*320
    mov ax, offset str_timer15
    call draw_array

    ; option 7
    add bx, 9*320
    mov ax, offset str_timer300
    call draw_array

    ; option 8
    add bx, 9*320
    mov ax, offset str_timer900
    call draw_array

    ; option 9
    add bx, 9*320
    mov ax, offset str_timerNone
    call draw_array
    
    pop bx
    pop ax
    ret
draw_menu endp


draw_menu_timer proc
    push ax
    push bx
    push dx

    mov bx, 27*320+6

    mov currentColor, 8

    mov ax, offset str_timer
    call draw_array

    add bx, 7*9

    call draw_timer_background

    cmp time_left, 0FFFFh
    jne @@draw_dx
    
    add bx, 13
    mov al, 2Dh      
    call draw_char
    jmp @@return

    @@draw_dx:
    mov dx, time_left
    call draw_dx

    @@return:
    pop dx
    pop bx
    pop ax
    ret
draw_menu_timer endp


; bx = start pixel
draw_timer_background proc
    push bx
    push cx
    push di

    xor cx, cx
    mov di, bx

    mov bx, 27*320+6

    @@draw_outer_loop: ; ch
    
    @@draw_inner_loop: ; cl
    mov byte ptr es:[di], 0Fh

    inc di
    inc cl
    cmp cl, 4*9
    jl @@draw_inner_loop

    add di, 320-4*9
    xor cl, cl
    inc ch
    cmp ch, 9
    jl @@draw_outer_loop

    pop di
    pop cx
    pop bx
    ret
draw_timer_background endp

draw_timer proc
    ret
draw_timer endp


draw_game proc
    call screen_white
    call mouse_show
    call set_origin_coord
    call draw_grid
    ret
draw_game endp