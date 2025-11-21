; Menu-driven ALP: 1) String length   2) String Reverse   3) String palindrome


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
menu_msg     db 10, "1. String length",10
             db "2. String Reverse",10
             db "3. String palindrome",10
             db "4. Exit",10
             db "Enter your choice - 1-4 : ",0
menu_len     equ $ - menu_msg

prompt_s1    db "Enter String: ",0
prompt_s1_len equ $ - prompt_s1

out_len_msg  db "Length of string: ",0
out_len_len  equ $ - out_len_msg

out_rev_msg  db "Reversed string: ",0
out_rev_len  equ $ - out_rev_msg

out_pal_yes  db "String is palindrome",10,0
out_pal_yes_len equ $ - out_pal_yes

out_pal_no   db "String is NOT palindrome",10,0
out_pal_no_len  equ $ - out_pal_no

invalid_msg  db "Wrong choice",10,0
invalid_len  equ $ - invalid_msg

nl           db 10
nl_len       equ $ - nl

section .bss
str1         resb 128      ; input buffer
str_rev      resb 128      ; reversed buffer
len1         resq 1
choice       resb 4
dec_buf      resb 64       ; buffer for decimal printing

section .text
global _start

_start:
menu_loop:
    ; Print menu and read choice
    write menu_msg, menu_len
    read choice, 4

    cmp byte [choice], '1'
    je do_strlen

    cmp byte [choice], '2'
    je do_reverse

    cmp byte [choice], '3'
    je do_palindrome

    cmp byte [choice], '4'
    je do_exit

    write invalid_msg, invalid_len
    jmp menu_loop

; ---------------- Option 1: String length ----------------
do_strlen:
    write prompt_s1, prompt_s1_len
    read str1, 128
    dec rax                 ; exclude newline
    mov [len1], rax

    write out_len_msg, out_len_len
    mov rbx, [len1]
    call display_decimal
    jmp menu_loop

; ---------------- Option 2: String reverse ----------------
do_reverse:
    write prompt_s1, prompt_s1_len
    read str1, 128
    dec rax
    mov [len1], rax

    ; reverse into str_rev
    mov rcx, [len1]         ; count
    mov rsi, str1
    add rsi, rcx
    dec rsi                 ; point to last char
    mov rdi, str_rev

.rev_loop:
    cmp rcx, 0
    je .rev_done
    mov al, [rsi]
    mov [rdi], al
    dec rsi
    inc rdi
    dec rcx
    jmp .rev_loop

.rev_done:
    ; print reversed string
    write out_rev_msg, out_rev_len
    mov rdx, [len1]
    write str_rev, rdx
    write nl, nl_len
    jmp menu_loop

; ---------------- Option 3: Palindrome ----------------
do_palindrome:
    write prompt_s1, prompt_s1_len
    read str1, 128
    dec rax
    mov [len1], rax

    ; reverse into str_rev (same as above)
    mov rcx, [len1]
    mov rsi, str1
    add rsi, rcx
    dec rsi
    mov rdi, str_rev

.rev2_loop:
    cmp rcx, 0
    je .rev2_done
    mov al, [rsi]
    mov [rdi], al
    dec rsi
    inc rdi
    dec rcx
    jmp .rev2_loop

.rev2_done:
    ; compare byte-by-byte
    mov rcx, [len1]
    mov rsi, str1
    mov rdi, str_rev
    cmp rcx, 0
    je .pal_yes    ; empty string -> palindrome

.compare_loop2:
    mov al, [rsi]
    cmp al, [rdi]
    jne .pal_no
    inc rsi
    inc rdi
    dec rcx
    jnz .compare_loop2

.pal_yes:
    write out_pal_yes, out_pal_yes_len
    jmp menu_loop

.pal_no:
    write out_pal_no, out_pal_no_len
    jmp menu_loop

; ---------------- Exit ----------------
do_exit:
    mov rax, 60
    xor rdi, rdi
    syscall

; ---------------- Helper: display_decimal ----------------
; Input: rbx = unsigned integer to print
; Uses dec_buf as temporary storage; prints decimal and newline
display_decimal:
    mov rax, rbx
    cmp rax, 0
    jne .conv_start
    mov byte [dec_buf], '0'
    mov byte [dec_buf+1], 10
    write dec_buf, 2
    ret

.conv_start:
    xor rcx, rcx
    lea rdi, [dec_buf + 63]

.conv_loop:
    mov rdx, 0
    mov rsi, 10
    div rsi                 ; rax = rax/10, rdx = rax%10 (note: dividend in rax)
    add dl, '0'
    mov [rdi], dl
    dec rdi
    inc rcx
    mov rax, rax            ; rax already quotient
    ; but we need to loop with quotient in rax; however above div used rax as dividend, quotient in rax already
    ; prepare for next iteration: use rax as dividend (already)
    cmp rax, 0
    jne .conv_loop

    lea rsi, [rdi + 1]
    mov rdx, rcx
    mov byte [rsi + rcx], 10
    inc rdx
    write rsi, rdx
    ret
