; BCD -> HEX standalone (fixed sections for NASM)

%macro READ 2
    mov rax, 0
    mov rdi, 0
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro WRITE 2
    mov rax, 1
    mov rdi, 1
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
msg1    db "Enter BCD number: ",0
len1    equ $ - msg1

msg2    db "BCD to Hex converted number is : ",0
len2    equ $ - msg2

nl      db 10
len_nl  equ $ - nl

section .bss
char_buff   resb 17      ; input buffer and reused for hex output (16 bytes + optional)
ans         resq 1       ; store resulting numeric value

section .text
global _start

_start:
    ; Prompt and read BCD (ASCII decimal digits)
    WRITE msg1, len1
    READ char_buff, 17           ; rax <- bytes read

    ; Parse ASCII BCD into numeric value in RAX (preserve original logic)
    dec rax                      ; adjust count (syscall returns count incl newline)
    mov rcx, rax                 ; rcx = number of chars to process
    mov rsi, char_buff           ; rsi -> input buffer
    mov rax, 0                   ; accumulator in RAX
    mov rbx, 0xA                 ; multiplier = 10

l1:
    mul rbx                      ; rdx:rax = rax * rbx  (RAX <- previous * 10)
    mov rdx, 0
    mov dl, byte [rsi]           ; next ASCII character
    sub dl, '0'                  ; convert ASCII to numeric digit
    add rax, rdx                 ; rax = rax + digit
    inc rsi
    dec rcx
    jnz l1

    mov [ans], rax               ; store numeric result (64-bit)

    ; Print heading
    WRITE msg2, len2

    ; Display stored value as 16 hex digits using original display routine
    mov rbx, [ans]
    call display_hex16

    ; newline and exit
    WRITE nl, len_nl
    EXIT

; ---------------------------------------------------------
; display_hex16: display 16 hex digits corresponding to qword in RBX
; (keeps the original rol/mask/convert logic)
; ---------------------------------------------------------
display_hex16:
    mov rcx, 16
    mov rsi, char_buff           ; output buffer start
display_loop:
    rol rbx, 4
    mov dl, bl
    and dl, 0x0F
    cmp dl, 9
    jbe .digit_is_0to9
    add dl, 7
.digit_is_0to9:
    add dl, '0'
    mov byte [rsi], dl
    inc rsi
    dec rcx
    jnz display_loop

    ; write 16-byte hex string
    WRITE char_buff, 16
    ret
