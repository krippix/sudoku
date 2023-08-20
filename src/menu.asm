open_menu proc
    mov menu, 1
    mov time_left, 0FFFFh
    call draw_menu
    ret
open_menu endp