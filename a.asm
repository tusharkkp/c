//Write an ALP to accept the 64 bit numbers from user, perform arithmetic operations on them, and display the 
//result. i) Addition ii) Division


section .data
    msg db "Enter first number:",10
    len equ $-msg
    msg1 db "Enter second number:",10
    len1 equ $-msg1
    msg2 db "The sum is: ",10
    len2 equ $-msg2

section .bss
    num1 resb 2        ; buffer for first number (1 char + newline)
    num2 resb 2        ; buffer for second number
    sum resb 2         ; buffer for sum (as ASCII)

section .text
    global _start

_start:
    ; Print prompt for first number
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, len
    syscall

    ; Read first number (2 bytes: digit and newline)
    mov rax, 0
    mov rdi, 0
    mov rsi, num1
    mov rdx, 2
    syscall

    ; Print prompt for second number
    mov rax, 1
    mov rdi, 1
    mov rsi, msg1
    mov rdx, len1
    syscall

    ; Read second number
    mov rax, 0
    mov rdi, 0
    mov rsi, num2
    mov rdx, 2
    syscall

    ; Convert ASCII to integer
    mov al, [num1]
    sub al, '0'
    mov bl, [num2]
    sub bl, '0'

    ; Add numbers
    add al, bl
    add al, '0'    ; convert sum to ASCII

    mov [sum], al  ; store sum as ASCII
    mov byte [sum+1], 10 ; add newline

    ; Print "The sum is:" message
    mov rax, 1
    mov rdi, 1
    mov rsi, msg2
    mov rdx, len2
    syscall

    ; Print result
    mov rax, 1
    mov rdi, 1
    mov rsi, sum
    mov rdx, 2
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
