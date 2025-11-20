
; ALP: Convert 64-bit BCD (decimal digits input) into equivalent HEX (prints hex)

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
msg_in  db "Enter BCD number (decimal digits): ",0
len_in  equ $ - msg_in
msg_out db "HEX equivalent is : ",0
len_out equ $ - msg_out

section .bss
in_buf  resb 32        ; input ascii decimal digits (up to 19 digits for 64-bit but buffer larger)
cnt     resq 1
hex_ch  resb 1
tmp_buf resb 32        ; to push hex digits (we'll use stack-like pushes then pop into tmp_buf)
 
section .text
global _start

_start:
    ; Prompt & read decimal (BCD) input
    WRITE msg_in, len_in
    READ in_buf, 32        ; rax = bytes read

    ; Parse ASCII decimal into numeric value in rbx
    ; (same logic style as PDF: accumulate = accumulate*10 + digit)
    call parse_decimal     ; returns value in rbx

    ; Convert numeric value in rbx to hex by repeated div 16
    mov rcx, 0             ; hex digit count
    mov rax, rbx           ; value to convert

    cmp rax, 0
    jne conv_hex_loop
    ; handle zero specially
    mov byte [tmp_buf], '0'
    mov rcx, 1
    jmp print_hex

conv_hex_loop:
    xor rdx, rdx
    mov rbx, 16
    div rbx                ; rax = quotient, rdx = remainder (0..15)
    ; convert remainder to ascii hex (0-9,A-F)
    cmp rdx, 10
    jb rem_is_digit
    add dl, 'A' - 10
    jmp store_digit
rem_is_digit:
    add dl, '0'
store_digit:
    ; store digit into tmp_buf at index rcx
    mov [tmp_buf + rcx], dl
    inc rcx
    cmp rax, 0
    jne conv_hex_loop

print_hex:
    ; Print header
    WRITE msg_out, len_out
    ; tmp_buf currently has hex digits in reverse (least significant first) with count rcx
    ; print them in reverse order
    mov rsi, rcx
    dec rsi                 ; index = rcx - 1
print_loop:
    cmp rsi, -1
    jl finish_print
    mov al, [tmp_buf + rsi]
    mov [hex_ch], al
    WRITE hex_ch, 1
    dec rsi
    jmp print_loop

finish_print:
    ; write newline
    mov byte [hex_ch], 10
    WRITE hex_ch, 1
    EXIT

; ---------------- parse_decimal ----------------
; Reads: in_buf contains ASCII bytes, rax holds bytes read from last READ syscall
; Output: rbx = numeric value (unsigned)
parse_decimal:
    mov rcx, rax           ; bytes read
    xor rbx, rbx           ; accumulator
    mov rsi, in_buf

parse_loop:
    cmp rcx, 0
    je parse_done
    mov dl, [rsi]
    ; stop on newline or CR
    cmp dl, 10
    je parse_done
    cmp dl, 13
    je parse_done
    ; skip any non-digit (space etc.)
    cmp dl, '0'
    jb skip_char
    cmp dl, '9'
    ja skip_char
    ; rbx = rbx * 10 + (dl - '0')
    imul rbx, rbx, 10
    movzx rdx, dl
    sub rdx, '0'
    add rbx, rdx

skip_char:
    inc rsi
    dec rcx
    jmp parse_loop

parse_done:
    ret
