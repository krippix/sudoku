prep_video proc
    ; get videomode and save for later use
    mov ah, 0Fh
    int 10h
    mov videomode, al

    ; set video mode
    mov ax, 13h ; implizit al 00h
    int 10h

    ; set background color to white
    xor bh, bh ; cmd
    mov ah, 06h ; cmd
    mov bh, 0F0h ; white/black
    int 10h
    
    ret
prep_video endp

draw_grid proc
    mov bh, 0
    mov al, 0FFh
    mov cx, 100
    mov dx, 100
    mov ah, 0Ch
    int 10h
    mov cx, 101
    int 10h
    mov cx, 102
    int 10h
    ret
draw_grid endp