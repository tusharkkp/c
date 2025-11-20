; Multiplication of two 64-bit HEX numbers using successive addition

%macro write 2
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro read 2
    mov rax, 0
    mov rdi, 0
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

section .data
msg1 db "Enter the first num: ", 10
msg1_len equ $ - msg1

msg2 db "Enter the second num: ", 10
msg2_len equ $ - msg2

msg3 db "Multiplication Result:", 10
msg3_len equ $ - msg3

section .bss
num     resb 17        ; input buffer (max 16 chars + newline)
ccnt    resq 1         ; character count from READ
no1     resq 1         ; multiplicand
no2     resq 1         ; multiplier (will be decremented)
rbuff   resb 16        ; buffer used by disp to store hex chars (16 bytes)

section .text
global _start

_start:
    ; --- Read first hex number ---
    write msg1, msg1_len
    read num, 17               ; syscall returns count in RAX
    dec rax
    mov qword [ccnt], rax
    call accept_hex            ; result in RBX
    mov qword [no1], rbx

    ; --- Read second hex number ---
    write msg2, msg2_len
    read num, 17
    dec rax
    mov qword [ccnt], rax
    call accept_hex            ; result in RBX
    mov qword [no2], rbx

    ; --- Successive addition multiplication ---
    mov rbx, 0                 ; accumulator = 0

mult_loop:
    add rbx, qword [no1]       ; acc += multiplicand
    dec qword [no2]            ; multiplier--
    cmp qword [no2], 0
    jne mult_loop

    ; --- Print result heading and result (16 hex digits) ---
    write msg3, msg3_len
    ; rbx already has the product
    call disp_hex16_from_rbx

    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall

; ---------------- accept_hex ----------------
; Converts ASCII hex string in 'num' to numeric RBX
; Uses same logic as original: shift left 4 and add nibble (handles 0-9,A-F,a-f)
accept_hex:
    xor rbx, rbx
    mov rcx, [ccnt]            ; number of characters
    mov rsi, num
up_accept:
    shl rbx, 4
    mov dl, byte [rsi]
    cmp dl, '9'
    jbe .digit_ok
    sub dl, 7                  ; 'A'-'F' or 'a'-'f' handling (as in original)
.digit_ok:
    sub dl, '0'
    movzx rdx, dl
    add rbx, rdx
    inc rsi
    dec rcx
    jnz up_accept
    ret

; ---------------- disp_hex16_from_rbx ----------------
; Produce 16 hex characters from RBX into rbuff and write them out.
; Keeps original rol/mask/convert logic.
disp_hex16_from_rbx:
    mov rcx, 16
    mov rsi, rbuff
disp_loop:
    rol rbx, 4
    mov dl, bl
    and dl, 0x0F
    cmp dl, 9
    jbe .d0to9
    add dl, 7
.d0to9:
    add dl, '0'
    mov [rsi], dl
    inc rsi
    dec rcx
    jnz disp_loop

    ; write 16-byte hex string
    mov rax, 1
    mov rdi, 1
    lea rsi, [rbuff]
    mov rdx, 16
    syscall
    ret
