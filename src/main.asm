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
;  | `--------------- collision (marks number red, or yellow if predet)
;  `----------------- Unused
fields db 81 dup (0)
videomode db 00h        ; used to return to previously used videomode
last_modified dw 0FFh   ; last modified box FF -> none
currentColor db 04h     ; color to use for drawing
active_box db 0FFh      ; number of the active box -> FF if none
origin_x dw 0           ; top-left-most point of the grid
origin_y dw 0           ; top-left-most point of the grid

.CODE
    ORG 0100h
    include keyboard.asm
    include video.asm
    include mouse.asm
    include game.asm

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

    push bx
    mov bx, 3
    ;call find_collisions_cube
    pop bx

mainloop:
    call handle_mouse
    call handle_keyboard
    call handle_game
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