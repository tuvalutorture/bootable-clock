SCREEN_HEIGHT   EQU 25
SCREEN_WIDTH    EQU 80
SCREEN_MEM      EQU 0xB800

; no arguments needed here, just call
scroll_screen:
    push cx

    call set_screen_regs

    mov cx, SCREEN_WIDTH * (SCREEN_HEIGHT - 1)

    push ds
    push si
    mov bx, es
    mov ds, bx
    mov si, di
    add si, SCREEN_WIDTH * 2

    rep movsw

    pop si
    pop ds
    mov cx, SCREEN_WIDTH

    xor ax, ax
    rep stosw

    pop cx
    ret

; set CH to X, CL to Y
; sets AX to position in memory
calculate_position:
    push di
    xor ax, ax
    mov al, cl

    xor di, di

    shl ax, 1
    shl ax, 1
    shl ax, 1
    shl ax, 1

    add di, ax
    add di, ax
    add di, ax
    add di, ax
    add di, ax

    xor ax, ax
    mov al, ch

    add di, ax              ; add the x
    shl di, 1               ; multiply by 2 because it's two bytes per char (char, colour)

    mov ax, di
    pop di
    ret

; how to call:
; set ES to 0xB800
; set DH to your colour (bg == upper 4 bits, fg == lower 4 bits), set DL to your char
; set CH to X, CL to Y
print_char:
    push ax
    push di

    call calculate_position
    mov di, ax

    mov word [es:di], dx

    pop di
    pop ax
    ret

; set CH to X, CL to Y
move_cursor:
    push ax
    push dx

    mov dx, 0x3D4
    mov al, 14
    out dx, al

    mov dx, 0x3D5
    call calculate_position
    shr ax, 1

    push ax

    push cx
    mov cx, 8
    shr ax, cl
    pop cx

    and al, 0xFF
    out dx, al

    mov dx, 0x3D4
    mov al, 15
    out dx, al

    mov dx, 0x3D5
    pop ax

    and al, 0xFF
    out dx, al

    pop dx
    pop ax
    ret


; set al to char, set ah to colour
fill_screen:
    mov cx, SCREEN_WIDTH * SCREEN_HEIGHT
    call set_screen_regs
    rep stosw
    ret

; if anyone but me calls this there's an issue
set_screen_regs: ; gatta save them 512 bytes
    mov bx, SCREEN_MEM
    mov es, bx
    xor di, di
    ret