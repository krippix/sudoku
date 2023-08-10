.MODEL TINY
.STACK 100h
.486
LOCALS @@

.DATA
; 8th bit is true if number is predetermined
; bits 0-4 for the number within the field, 0 = empty
fields db 81 dup (0)
videomode db 00h
currentColor db 00h

.CODE
    ORG 100h
    include keyboard.asm
    include video.asm

start:
    mov ax, @data
    mov ds, ax ; move to datasegment register

    call prep_video
    call draw_middle
    call draw_grid

    mov al, 31h
    xor bx, bx
    mov currentColor, 4
    call draw_char

mainloop:
    call handle_keyboard
    ;call draw_grid
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