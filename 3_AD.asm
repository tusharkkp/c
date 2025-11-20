//Write an ALP to accept the 64 bit numbers from user, perform arithmetic operations on them, and display the 
//result. i) Addition ii) Division


%macro WRITE 2
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro READ 2
    mov rax, 0
    mov rdi, 0
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro EXIT 0
    mov rax, 60
    xor rdi, rdi
    syscall
%endmacro

section .data
menu db "1. Addition",10
     db "2. Division",10
     db "3. Exit",10
     db "Enter your choice: ",0
menulen equ $ - menu

prompt1 db "Enter first number: ",0
len_p1 equ $ - prompt1

prompt2 db "Enter second number: ",0
len_p2 equ $ - prompt2

msg_add db "Addition is: ",0
len_add equ $ - msg_add

msg_divq db "Quotient is: ",0
len_divq equ $ - msg_divq

msg_divr db "Remainder is: ",0
len_divr equ $ - msg_divr

msg_divzero db "Error: Division by zero",10
len_divzero equ $ - msg_divzero

msg_wrong db "Wrong choice. Try again.",10
len_wrong equ $ - msg_wrong

section .bss
a resq 1
b resq 1
c resq 1
d resq 1
choice resb 4
char_buf resb 64
disp_buf resb 64

section .text
global _start

_start:

main_loop:

    ; --- INPUT FIRST NUMBER ---
    WRITE prompt1, len_p1
    READ char_buf, 64
    call accept_decimal
    mov [a], rbx

    ; --- INPUT SECOND NUMBER ---
    WRITE prompt2, len_p2
    READ char_buf, 64
    call accept_decimal
    mov [b], rbx

menu_print:
    WRITE menu, menulen
    READ choice, 4

    mov al, [choice]

    cmp al, '1'
    je do_add

    cmp al, '2'
    je do_div

    cmp al, '3'
    je do_exit

    WRITE msg_wrong, len_wrong
    jmp menu_print

; ---------------- ADDITION ----------------
do_add:
    mov rax, [a]
    add rax, [b]
    mov [c], rax
    WRITE msg_add, len_add
    mov rbx, [c]
    call display_decimal
    jmp menu_print

; ---------------- DIVISION ----------------
do_div:
    mov rax, [b]
    cmp rax, 0
    jne do_div_ok

    WRITE msg_divzero, len_divzero
    jmp menu_print

do_div_ok:
    mov rax, [a]
    xor rdx, rdx
    mov rcx, [b]
    mov rbx, rcx
    div rbx

    mov [c], rax
    mov [d], rdx

    WRITE msg_divq, len_divq
    mov rbx, [c]
    call display_decimal

    WRITE msg_divr, len_divr
    mov rbx, [d]
    call display_decimal
    jmp menu_print

do_exit:
    EXIT

; ---------- ACCEPT DECIMAL ----------
accept_decimal:
    mov rcx, rax
    xor rax, rax
    xor rbx, rbx
    mov rsi, char_buf

parse_loop:
    cmp rcx, 0
    je accept_done

    mov dl, [rsi]
    cmp dl, 10
    je accept_done

    cmp dl, '0'
    jb skip_ch
    cmp dl, '9'
    ja skip_ch

    sub dl, '0'
    imul rax, rax, 10
    movzx rdx, dl
    add rax, rdx

skip_ch:
    inc rsi
    dec rcx
    jmp parse_loop

accept_done:
    mov rbx, rax
    ret

; ---------- DISPLAY DECIMAL ----------
display_decimal:

    mov rax, rbx
    cmp rax, 0
    jne disp_conv

    mov byte [disp_buf], '0'
    mov byte [disp_buf+1], 10
    mov rdx, 2
    WRITE disp_buf, rdx
    ret

disp_conv:
    mov rcx, 0
    lea rdi, [disp_buf + 63]
    mov rax, rbx

conv_loop:
    xor rdx, rdx
    mov rbx, 10
    div rbx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    inc rcx
    cmp rax, 0
    jne conv_loop

    lea rsi, [rdi + 1]

    mov rbx, rcx
    lea rdi, [rsi + rbx]
    mov byte [rdi], 10

    mov rdx, rbx
    inc rdx

    WRITE rsi, rdx
    ret
