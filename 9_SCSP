Write a menu driven ALP to implement various mentioned string operations. i)String length  ii) String 
Concatination iii) String palindrome



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
Menumsg db 10, "1. String length",10
       db "2. String concat",10
       db "3. Check palindrome",10
       db "4. Exit",10
       db "Enter your choice - 1-4 : ",0
Menulen equ $ - Menumsg

msg1 db "Enter String1: ",0
len1 equ $ - msg1
msg2 db "Enter String2: ",0
len2 equ $ - msg2

msg3 db "The length of string: ",10,0
len3 equ $ - msg3
msg8 db "The string concated: ",10,0
len8 equ $ - msg8
msg9 db "String is palindrome",10,0
len9 equ $ - msg9
msg10 db "String not palindrome",10,0
len10 equ $ - msg10
msg13 db "Wrong choice",10,0
len13 equ $ - msg13

section .bss
string1 resb 64
string2 resb 64
string3 resb 128
l1 resq 1
l2 resq 1
l3 resq 1
choice resb 4
buff resb 16

section .text
global _start

_start:
menu_loop:
    ; Print menu first
    write Menumsg, Menulen

    ; Read choice
    read choice, 4

    ; Compare choice and jump to appropriate handler
    cmp byte [choice], '1'
    je handle_strlen

    cmp byte [choice], '2'
    je handle_concat

    cmp byte [choice], '3'
    je handle_palindrome

    cmp byte [choice], '4'
    je do_exit

    ; invalid
    write msg13, len13
    jmp menu_loop

; ---------- Handle: String Length ----------
; Print prompt, read string1, compute length, display
handle_strlen:
    write msg1, len1
    read string1, 64
    dec rax
    mov [l1], rax

    write msg3, len3
    mov rbx, [l1]
    call display

    jmp menu_loop

; ---------- Handle: Concatenation ----------
; Prompt both strings, then concat and display concatenated string
handle_concat:
    write msg1, len1
    read string1, 64
    dec rax
    mov [l1], rax

    write msg2, len2
    read string2, 64
    dec rax
    mov [l2], rax

    ; copy string1 -> string3
    mov rsi, string1
    mov rdi, string3
    mov rcx, [l1]
    cld
    rep movsb

    ; append string2
    mov rsi, string2
    mov rcx, [l2]
    rep movsb

    ; update l3 = l1 + l2
    mov rax, [l1]
    add rax, [l2]
    mov [l3], rax

    write msg8, len8
    ; write concatenated result (length [l3])
    mov rdx, [l3]        ; size
    ; syscall expects rsi to point to buffer, so use write macro:
    write string3, rdx

    jmp menu_loop

; ---------- Handle: Palindrome ----------
; Prompt re-read string1 (as in original), reverse and compare
handle_palindrome:
    write msg1, len1
    read string1, 64
    dec rax
    mov [l1], rax

    ; reverse string1 into string3
    mov rsi, string1
    mov rdx, [l1]
    ; rsi currently at start; move to last char
    add rsi, rdx
    dec rsi
    mov rdi, string3
    mov rcx, [l1]
rev_loop:
    mov dl, byte [rsi]
    mov byte [rdi], dl
    dec rsi
    inc rdi
    dec rcx
    jnz rev_loop

    ; compare string1 and reversed string3
    mov rsi, string1
    mov rdi, string3
    mov rcx, [l1]
    cld
    repe cmpsb
    jne not_pal
    write msg9, len9
    jmp menu_loop

not_pal:
    write msg10, len10
    jmp menu_loop

do_exit:
    mov rax, 60
    xor rdi, rdi
    syscall

; ---------- display: prints RBX as 16 hex nibbles (kept identical) ----------
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
