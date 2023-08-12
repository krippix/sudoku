.MODEL TINY
.STACK 100h
.486
LOCALS @@

.DATA
; Array of bytes for each game field:
; |7|6|5|4|3-0|
;  | | | |  |
;  | | | |  `-------- Number within field
;  | | | `----------- Number is predetermined
;  | | `------------- Field is highlighted
;  | `--------------- incorrect (marks number red, or yellow if predet)
;  `----------------- Unused
fields db 81 dup (0)
videomode db 00h
currentColor db 04h

.CODE
    ORG 0100h
    include keyboard.asm
    include video.asm
    include mouse.asm

start:
    mov ax, @data
    mov ds, ax ; move to datasegment register

    xor bx, bx
    xor cx, cx
    xor di, di
    xor si, si

    ; testdata         |  |
    mov fields[3], 00100111b

    call prep_video
    call mouse_show
    ;call draw_middle
    call draw_grid

    ; draw test
    mov cx, 3 ; set box number
    call draw_box

    ;mov byte ptr es:[319+320], 8 ; test pixel

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
    mov ax, 4C00h
    int 21h
END start