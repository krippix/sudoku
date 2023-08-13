.MODEL TINY
.STACK 100h
.486
LOCALS @@

.DATA
; Array of bytes for each game field:
; |8|7|6|5|4-1|
;  | | | |  |
;  | | | |  `-------- Number within field
;  | | | `----------- Number is predetermined
;  | | `------------- Field is highlighted
;  | `--------------- incorrect (marks number red, or yellow if predet)
;  `----------------- Unused
fields db 81 dup (0)
modified db 0        ; keeps track of changes to fields
videomode db 00h     ; used to return to previously used videomode
currentColor db 04h  ; color to use for drawing
active_box db 0FFh   ; number of the active box -> FF if none
origin_x dw 0        ; top-left-most point of the grid
origin_y dw 0        ; top-left-most point of the grid

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

    call set_origin_coord

    call prep_video
    call mouse_show
    call draw_grid

    mov di, 0
    @@test_loop:
    mov [fields+di], 01101000b ; testdata
    mov cx, di
    inc di
    call draw_box
    cmp di, 81
    jl @@test_loop


mainloop:
    call handle_keyboard
    call handle_mouse
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