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
;  `----------------- collision bit 2 (used to determine if collision changed)
fields db 81 dup (0)
previous_vector dw 2 dup (0)    ; contains previous interrupt 08h
time_left dw (18*10)            ; 1 second ~ 18
videomode db 00h                ; used to return to previously used videomode
gameover db 00h                 ; set to 1 once game is over, blocks keyboard inputs except for esc
last_modified dw 0FFh           ; last modified box FF -> none
currentColor db 04h             ; color to use for drawing
active_box db 0FFh              ; number of the active box -> FF if none
origin_x dw 0                   ; top-left-most point of the grid
origin_y dw 0                   ; top-left-most point of the grid
; "strings"
you_lose db 59h, 6Fh, 75h, 20h, 4Ch, 6Fh, 73h, 65h, 21h
you_win  db 59h, 6Fh, 75h, 20h, 57h, 69h, 6Eh, 21h

.CODE
    ORG 0100h
    include keyboard.asm
    include video.asm
    include mouse.asm
    include game.asm
    include timer.asm

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

    ; register custom timer
    call prepare_int

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