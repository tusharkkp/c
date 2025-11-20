Write an ALP to perform multiplication of two 64-bit hexadecimal numbers using  add and shift method


%macro PRINT 2
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro INPUT 2
    mov rax, 0
    mov rdi, 0
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

section .data
multiplicand_text db "Enter multiplicand (hex, max 16 chars):", 10
multiplicand_len  equ $-multiplicand_text

multiplier_text   db "Enter multiplier   (hex, max 16 chars):", 10
multiplier_len    equ $-multiplier_text

result_text       db "Product (A : Q) = ", 10
result_len        equ $-result_text

nl db 10
nl_len equ $-nl

section .bss
data_in      resb 18      ; input buffer (16 chars + newline + safety)
digit_count  resq 1
display_buf  resb 16
multiplicand resq 1
multiplier   resq 1
accumulator  resq 1
curr_mult    resq 1
bit_counter  resq 1

section .text
global _start

_start:
    ; Read multiplicand (B)
    PRINT multiplicand_text, multiplicand_len
    INPUT data_in, 18
    dec rax
    mov [digit_count], rax
    call to_int            ; RBX <- parsed value
    mov [multiplicand], rbx

    ; Read multiplier (Q)
    PRINT multiplier_text, multiplier_len
    INPUT data_in, 18
    dec rax
    mov [digit_count], rax
    call to_int            ; RBX <- parsed value
    mov [curr_mult], rbx

    ; Initialize A = 0, n = 64
    mov qword [accumulator], 0
    mov qword [bit_counter], 64

; Add & Shift loop
shift_loop:
    ; if Q0 == 1 then A = A + B
    mov rax, [curr_mult]
    and rax, 1
    cmp rax, 1
    jne .no_add
    mov rax, [accumulator]
    add rax, [multiplicand]
    mov [accumulator], rax
.no_add:

    ; Shift right combined A:Q by 1
    ; newQ = (Q >> 1) | ((A & 1) << 63)
    mov rax, [curr_mult]
    shr rax, 1               ; rax = Q >> 1
    mov rdx, [accumulator]
    and rdx, 1
    cmp rdx, 0
    je .skip_set_msb
    mov rcx, 1
    shl rcx, 63              ; rcx = 1 << 63
    or rax, rcx
.skip_set_msb:
    mov [curr_mult], rax

    ; A = A >> 1
    mov rax, [accumulator]
    shr rax, 1
    mov [accumulator], rax

    ; decrement counter and loop
    dec qword [bit_counter]
    cmp qword [bit_counter], 0
    jne shift_loop

    ; Print result heading and A:Q
    PRINT result_text, result_len

    ; Display A (high 64 bits)
    mov rbx, [accumulator]
    call show_value

    ; print separator " : "
    mov rcx, 3
    lea rsi, [sep_buf]
    PRINT rsi, rcx

    ; Display Q (low 64 bits)
    mov rbx, [curr_mult]
    call show_value

    PRINT nl, nl_len
    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall

; ---------- helper: parse ASCII hex into RBX ----------
; expects [digit_count] filled with number of chars to parse, input in data_in
to_int:
    mov rbx, 0
    mov rsi, data_in
    mov rcx, [digit_count]
.parse_loop:
    shl rbx, 4
    mov dl, [rsi]
    cmp dl, '9'
    jbe .digit_ok
    sub dl, 7             ; convert A-F/a-f gap (same as original logic)
.digit_ok:
    sub dl, '0'
    movzx rdx, dl
    add rbx, rdx
    inc rsi
    dec rcx
    jnz .parse_loop
    ret

; ---------- helper: display RBX as 16 hex chars ----------
; uses rol/mask/convert logic from original ALP, outputs to display_buf
show_value:
    mov rsi, display_buf
    mov rcx, 16
.show_loop:
    rol rbx, 4
    mov dl, bl
    and dl, 0x0F
    cmp dl, 9
    jbe .to_ascii
    add dl, 7
.to_ascii:
    add dl, '0'
    mov [rsi], dl
    inc rsi
    dec rcx
    jnz .show_loop
    PRINT display_buf, 16
    ret

section .data
sep_buf db " : "
