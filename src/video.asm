prep_video proc
    ; get videomode and save for later use
    mov ah, 0Fh
    int 10h
    mov videomode, al

    ; set video mode
    mov ax, 13h ; implizit al 00h
    int 10h
    
    ret
prep_video endp
