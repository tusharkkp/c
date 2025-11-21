Write a menu driven ALP to implement various mentioned string operations. i)String length ii) String 
Compare iii) String Copy





%macro read 2
    mov rax, 0
    mov rdi, 0
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro write 2
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

section .data
Menumsg  db 10, "1. String length",10
        db "2. String compare",10
        db "3. String copy",10
        db "4. Exit",10
        db "Enter your choice - 1-4 : ",0
Menulen  equ $ - Menumsg

msg_s1  db "Enter String1: ",0
len_s1  equ $ - msg_s1
msg_s2  db "Enter String2: ",0
len_s2  equ $ - msg_s2

msg_len db "Length of string: ",10,0
len_len equ $ - msg_len

msg_eq  db "Strings are equal",10,0
len_eq  equ $ - msg_eq
msg_ne  db "Strings are NOT equal",10,0
len_ne  equ $ - msg_ne

msg_copy_ok db "String copied. Result: ",10,0
len_copy_ok equ $ - msg_copy_ok

msg_wrong db "Wrong choice",10,0
len_wrong equ $ - msg_wrong

section .bss
string1     resb 64
string2     resb 64
string_dest resb 128
len1        resq 1
len2        resq 1
lend        resq 1
choice      resb 4
buff        resb 16        ; used by display routine

section .text
global _start

_start:
menu_loop:
    ; print menu and read choice
    write Menumsg, Menulen
    read choice, 4

    cmp byte [choice], '1'
    je handle_strlen

    cmp byte [choice], '2'
    je handle_compare

    cmp byte [choice], '3'
    je handle_copy

    cmp byte [choice], '4'
    je do_exit

    ; invalid choice
    write msg_wrong, len_wrong
    jmp menu_loop

; ---------------- Handle: String length ----------------
handle_strlen:
    write msg_s1, len_s1
    read string1, 64
    dec rax
    mov [len1], rax

    write msg_len, len_len
    mov rbx, [len1]
    call display        ; display length using same display routine
    jmp menu_loop

; ---------------- Handle: String compare ----------------
handle_compare:
    write msg_s1, len_s1
    read string1, 64
    dec rax
    mov [len1], rax

    write msg_s2, len_s2
    read string2, 64
    dec rax
    mov [len2], rax

    ; if lengths differ -> not equal
    mov rax, [len1]
    cmp rax, [len2]
    jne .not_equal

    ; lengths same -> compare byte-wise
    mov rsi, string1
    mov rdi, string2
    mov rcx, [len1]
    cld
    repe cmpsb
    jne .not_equal

    ; equal
    write msg_eq, len_eq
    jmp menu_loop

.not_equal:
    write msg_ne, len_ne
    jmp menu_loop

; ---------------- Handle: String copy ----------------
handle_copy:
    write msg_s1, len_s1
    read string1, 64
    dec rax
    mov [len1], rax

    ; copy string1 -> string_dest
    mov rsi, string1
    mov rdi, string_dest
    mov rcx, [len1]
    cld
    rep movsb

    mov rax, [len1]
    mov [lend], rax

    write msg_copy_ok, len_copy_ok
    ; write the copied string using its length
    write string_dest, [lend]
    jmp menu_loop

do_exit:
    mov rax, 60
    xor rdi, rdi
    syscall

; ---------- display: prints RBX as 16 hex nibbles (kept identical to original) ----------
display:
    mov rsi, buff
    mov rcx, 16
display_loop:
    rol rbx, 4
    mov dl, bl
    and dl, 0x0F
    cmp dl, 9
    jbe .add30
    add dl, 7
.add30:
    add dl, '0'
    mov byte [rsi], dl
    inc rsi
    dec rcx
    jnz display_loop
    write buff, 16
    ret
