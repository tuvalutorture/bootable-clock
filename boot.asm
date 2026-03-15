org 0x7C00
bits 16
cpu 8086
entry: jmp start

hour db 0
minute db 0
second db 0

%include "text.asm"

start:
    mov ax, 0x0107
    call set_colour
    jmp main

; put bcd value into al
; get seperated bcd into ax
; al goes from xxxx xxxx to ah: xxxx al: xxxx
; written by human instead of slop machine
split_bcd:
    mov ah, al
    shr ah, 1
    shr ah, 1
    shr ah, 1
    shr ah, 1
    and al, 0x0F
    ret

; just here to prevent repeating code
print_digits:
    mov dl, ah
    add dl, 48
    call print_char
    inc ch

    mov dl, al
    add dl, 48
    call print_char
    inc ch

    ret

print_time:
    mov dh, [colour]

    ; hours
    mov al, [hour]
    call split_bcd
    cmp ax, 0
    jnz .pm_check
    mov ax, 0x0102 ; print 12 if 00:xx
    jmp .print_hour_digit

.pm_check:
    cmp ax, 0x0102
    jna .print_hour_digit
    cmp byte [hour], 0x22 ; fuckery to get around 8/9 pm
    jnl .sub_twelve
    cmp byte [hour], 0x20
    jl .sub_twelve
    add al, 0x08
    xor ah, ah
    jmp .print_hour_digit
.sub_twelve:
    sub ax, 0x0102

.print_hour_digit:
    call print_digits
    mov dl, 0x3A
    call print_char
    inc ch

; minutes
    mov al, [minute]
    call split_bcd
    call print_digits
    mov dl, 0x3A
    call print_char
    inc ch

; seconds
    mov al, [second]
    call split_bcd
    call print_digits

; meridian (am/pm)
    xor dl, dl
    call print_char
    inc ch
    cmp byte [hour], 0x12
    jnae .print_am
    mov dl, 0x50 ; print pm
    jmp .print_m

.print_am:
    mov dl, 0x41

.print_m:
    call print_char
    inc ch
    mov dl, 0x4D
    call print_char
    inc ch
    call move_cursor

    ret

main:
    mov ax, 0x0200
    int 0x1A
    cmp dh, [second]
    je main
    mov [second], dh
    mov [hour], ch
    mov [minute], cl

    mov ah, [colour]
    xor al, al
    call fill_screen
    call print_time
    jmp main

times 510-($-$$) db 0
dw 0AA55h