vidadr dw 0A000h
chradr dw 0FA6Eh

prep_video proc
    push ax

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

    mov ah, 06h    
    xor al, al     
    xor cx, cx
    mov dx, 184Fh
    mov bh, 1Eh   
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
screen_white endp

drawtest proc
    push ax

    mov al, 2        ; Set the color value (green)
    mov [es:320*0+10], al  ; Write the color to the pixel 
    mov [es:320*0+11], al
    mov [es:320*0+12], al

    mov [es:320*1+12], al
    mov [es:320*1+13], al
    
    mov [es:320*2+10], al
    mov [es:320*2+11], al
    mov [es:320*2+12], al
    mov [es:320*2+13], al

    mov [es:320*3+10], al
    mov [es:320*3+11], al
    mov [es:320*3+12], al
    mov [es:320*3+13], al

    mov [es:320*4+10], al
    mov [es:320*4+12], al

    mov [es:0], al
    mov [es:320*200-1], al

    pop ax
    ret
drawtest endp

; draws a 8x8 char from memory
; al = ascii symbol
; bx = start pixel
draw_char proc
    push cx
    push di

    ; convert ascii to memory location
    ; prepare ax for draw
    ; todo: maybe substract if list starts at 'a'
    mov di,cx
    mov ah, 0
    mul di
    mov di, ax

    ; draw 8x8 char row by row
    @@byte_loop:
    ;mov ah, byte ptr chradr[0] ;eigentlich di
    mov ah, 01010101b ; TMP test

    call draw_byte
    add di, 8
    add bx, 320 ; basically nextline
    inc cx
    cmp cx, 8
    ;jl @@byte_loop ; TODO: ENABLE

    pop di
    pop cx
    ret
draw_char endp

; draws the given byte using the following information:
; ah = byte to use
; bx = pixel to draw on
; USAGE:
draw_byte PROC
    push cx
    push si

    mov cl, currentColor

    @@draw_loop:
    shl ah, 1 ; left shift and handle carry bit

    ; only draw bit if carry is 1
    jc @@skip

    mov byte ptr es:[bx], cl
    ;mov [es:bx], cl

    @@skip:
    inc bx
    inc si
    cmp si, 8
    jb @@draw_loop ; jump back up if bit is not finished

    pop si
    pop cx
    ret
draw_byte ENDP