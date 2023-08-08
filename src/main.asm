.MODEL TINY
.STACK 100h
.486
LOCALS @@

.DATA
; 8th bit is true if number is predetermined
; bits 0-4 for the number within the field, 0 = empty
fields db 81 dup (0)
videomode db 00h

.CODE
    include keyboard.asm
    include video.asm

start:
    mov ax, @data
    mov ds, ax ; move to datasegment register

    call prep_video

mainloop:
    call handle_keyboard
    call draw_grid
    jmp mainloop

exit:
    ; return to initial videomode
    mov ah, 00h
    mov al, videomode 
    int 10h

    ; exit program
    mov ah, 31h
    int 21h
END start