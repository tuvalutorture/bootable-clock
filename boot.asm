org 0x7C00
bits 16
cpu 8086
entry: jmp start

%include "text.asm"

section .data
hour db 0
minute db 0
second db 0

section .text
start:
    jmp main

; courtesy of the slop machine
bcd_to_bin:
    ; input: BCD in AL
    ; output: binary in AL
    push cx
    mov ah, al         ; backup original BCD value
    and al, 0x0F       ; isolate the lower nybble (units place)
    mov bl, al         ; save units in BL
    mov al, ah         ; restore original BCD
    mov cx, 0x0A04
    shr al, cl         ; shift down high nybble (tens place)
    imul ch            ; multiply by 10
    add al, bl         ; add units place
    pop cx
    ret

print_time:
    mov ax, 0x1700
    call fill_screen
    mov dh, 0x17

.print_hour:
    mov al, [hour]
    cmp al, 12
    jna .print_leading_one
    sub al, 12

.print_leading_one:
    cmp al, 10
    jnae .print_hour_digit

    mov dl, 0x31
    call print_char
    inc ch

    sub al, 10

.print_hour_digit:
    mov dl, al
    add dl, 48
    call print_char
    inc ch

    mov dl, 0x3A
    call print_char
    inc ch

.print_minute:
    xor ax, ax
    mov al, [minute]
    cmp al, 10
    jnae .print_minute_digit

.minute_loop:
    inc ah
    sub al, 10
    cmp al, 10
    jge .minute_loop

.print_minute_digit:
    mov dl, ah
    add dl, 48
    call print_char
    inc ch
    mov dl, al
    add dl, 48
    call print_char
    inc ch

    mov dl, 0x3A
    call print_char
    inc ch

.print_second:
    xor ax, ax
    mov al, [second]
    cmp al, 10
    jnae .print_second_digit

.second_loop:
    inc ah
    sub al, 10
    cmp al, 10
    jge .second_loop

.print_second_digit:
    mov dl, ah
    add dl, 48
    call print_char
    inc ch
    mov dl, al
    add dl, 48
    call print_char
    inc ch

.print_meridian_specifier:
    mov dx, 0x1700
    call print_char
    inc ch
    cmp byte [hour], 12
    jnae .print_am
    mov dx, 0x1750 ; print pm
    jmp .print_m

.print_am:
    mov dx, 0x1741

.print_m:
    call print_char
    inc ch
    mov dx, 0x174D
    call print_char
    inc ch
    call move_cursor
    ret

main:
    xor cx, cx
    call move_cursor

loop:
    mov ax, 0x0200
    int 0x1A
    mov al, dh
    call bcd_to_bin
    cmp al, [second]
    je .dont_bother
    mov [second], al

    mov al, ch
    call bcd_to_bin
    mov [hour], al
    mov al, cl
    call bcd_to_bin
    mov [minute], al

    call print_time
.dont_bother:
    jmp loop

times 510-($-$$) db 0
dw 0AA55h