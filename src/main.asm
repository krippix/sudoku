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
time_left dw 0FFFFh             ; timer in seconds
time_buffer db 0                ; increased 18 times before decreasing time_left
videomode db 00h                ; used to return to previously used videomode
gameover db 0                   ; set to 1 once game is over, blocks keyboard inputs except for esc
menu db 1                       ; set to 1 while in menu
last_modified dw 0FFh           ; last modified box FF -> none
currentColor db 04h             ; color to use for drawing
active_box db 0FFh              ; number of the active box -> FF if none
origin_x dw 0                   ; top-left-most point of the grid
origin_y dw 0                   ; top-left-most point of the grid
; prepared sudoku fields
easy_sudoku db 0h, 0h, 16h, 0h, 0h, 18h, 0h, 0h, 0h, 0h, 0h, 0h, 15h, 0h, 0h, 0h, 16h, 12h, 12h, 19h, 0h, 0h, 0h, 0h, 15h, 17h, 0h, 0h, 0h, 0h, 18h, 14h, 0h, 19h, 0h, 0h, 0h, 12h, 15h, 11h, 16h, 0h, 18h, 13h, 17h, 18h, 11h, 19h, 13h, 15h, 0h, 0h, 12h, 14h, 0h, 14h, 12h, 19h, 0h, 13h, 0h, 0h, 0h, 0h, 0h, 0h, 12h, 0h, 0h, 17h, 0h, 0h, 16h, 18h, 0h, 0h, 0h, 15h, 0h, 0h, 13h
medium_sudoku db 16h, 0h, 14h, 0h, 0h, 0h, 19h, 18h, 0h, 18h, 19h, 0h, 16h, 0h, 13h, 0h, 0h, 0h, 0h, 0h, 0h, 19h, 0h, 0h, 12h, 0h, 16h, 0h, 0h, 0h, 0h, 11h, 15h, 0h, 12h, 0h, 0h, 0h, 0h, 0h, 0h, 0h, 0h, 15h, 0h, 15h, 12h, 11h, 0h, 0h, 0h, 13h, 19h, 18h, 0h, 17h, 15h, 11h, 0h, 0h, 0h, 16h, 19h, 14h, 0h, 0h, 15h, 0h, 0h, 0h, 0h, 0h, 19h, 0h, 13h, 0h, 0h, 12h, 15h, 0h, 0h
hard_sudoku db 0h, 12h, 19h, 11h, 0h, 0h, 0h, 16h, 0h, 0h, 17h, 0h, 0h, 0h, 0h, 0h, 0h, 15h, 0h, 0h, 11h, 13h, 0h, 14h, 0h, 0h, 0h, 0h, 0h, 13h, 0h, 0h, 0h, 0h, 0h, 19h, 0h, 0h, 0h, 16h, 14h, 0h, 18h, 0h, 0h, 0h, 0h, 0h, 15h, 13h, 0h, 0h, 0h, 12h, 0h, 19h, 0h, 0h, 0h, 0h, 12h, 0h, 0h, 0h, 0h, 0h, 12h, 0h, 0h, 0h, 0h, 0h, 18h, 0h, 0h, 0h, 0h, 0h, 0h, 15h, 17h
; "strings"
str_sudoku db 53h, 75h, 64h, 6Fh, 6Bh, 75h, 0FFh
str_loadEmpty db 31h, 3Ah, 20h, 4Ch, 6Fh, 61h, 64h, 20h, 45h, 6Dh, 70h, 74h, 79h, 20h, 47h, 72h, 69h, 64h, 0FFh
str_loadEasy db 32h, 3Ah, 20h, 4Ch, 6Fh, 61h, 64h, 20h, 45h, 61h, 73h, 79h, 20h, 50h, 75h, 7Ah, 7Ah, 6Ch, 65h, 0FFh
str_loadMedium db 33h, 3Ah, 20h, 4Ch, 6Fh, 61h, 64h, 20h, 4Dh, 65h, 64h, 69h, 75h, 6Dh, 20h, 50h, 75h, 7Ah, 7Ah, 6Ch, 65h, 0FFh
str_loadHard db 34h, 3Ah, 20h, 4Ch, 6Fh, 61h, 64h, 20h, 48h, 61h, 72h, 64h, 20h, 50h, 75h, 7Ah, 7Ah, 6Ch, 65h, 0FFh
str_timer15 db 36h, 3Ah, 20h, 53h, 65h, 74h, 20h, 74h, 69h, 6Dh, 65h, 72h, 20h, 74h, 6Fh, 20h, 31h, 35h, 20h, 73h, 65h, 63h, 6Fh, 6Eh, 64h, 73h, 0FFh
str_timer300 db 37h, 3Ah, 20h, 53h, 65h, 74h, 20h, 74h, 69h, 6Dh, 65h, 72h, 20h, 74h, 6Fh, 20h, 20h, 35h, 20h, 6Dh, 69h, 6Eh, 75h, 74h, 65h, 73h, 0FFh
str_timer900 db 38h, 3Ah, 20h, 53h, 65h, 74h, 20h, 74h, 69h, 6Dh, 65h, 72h, 20h, 74h, 6Fh, 20h, 31h, 35h, 20h, 6Dh, 69h, 6Eh, 75h, 74h, 65h, 73h, 0FFh
str_timerNone db 39h, 3Ah, 20h, 44h, 69h, 73h, 61h, 62h, 6Ch, 65h, 20h, 74h, 69h, 6Dh, 65h, 72h, 0FFh
str_esc db 65h, 73h, 63h, 3Ah, 20h, 45h, 78h, 69h, 74h, 0FFh
str_timer db 54h, 69h, 6Dh, 65h, 72h, 3Ah, 0FFh
str_you_lose db 59h, 6Fh, 75h, 20h, 4Ch, 6Fh, 73h, 65h, 21h, 0FFh
str_you_win  db 59h, 6Fh, 75h, 20h, 57h, 69h, 6Eh, 21h, 0FFh

.CODE
    ORG 0100h
    include keyboard.asm
    include video.asm
    include mouse.asm
    include game.asm
    include timer.asm
    include menu.asm

start:
    mov ax, @data
    mov ds, ax ; move to datasegment register

    xor bx, bx
    xor cx, cx
    xor di, di
    xor si, si

    call prep_video
    call draw_menu

    ; register custom timer
    call prepare_int
menuloop:

mainloop:
    call handle_mouse
    call handle_keyboard
    call handle_game
    jmp mainloop

exit:
    ; restore interrupt vector
    push ds
    mov ax, [previous_vector]
    mov dx, [previous_vector+2]
    mov ds, ax

    mov ax, 251Ch
    ;int 21h
    pop ds

    ; return to initial videomode
    mov ah, 00h
    mov al, videomode
    int 10h

    ; exit program
    mov ax, 4C00h
    int 21h
END start