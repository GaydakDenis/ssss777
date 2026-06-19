; practice6.asm
; I/O: int 80h
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    ; memory
    prompt db "practice6: see README.md", 10
    prompt_len equ $-prompt
    
    txt_signed db "SIGNED: ", 0
    len_signed equ $-txt_signed
    txt_unsigned db "UNSIGNED: ", 0
    len_unsigned equ $-txt_unsigned
    
    txt_lt db "a < b", 10, 0
    len_lt equ $-txt_lt
    txt_eq db "a = b", 10, 0
    len_eq equ $-txt_eq
    txt_gt db "a > b", 10, 0
    len_gt equ $-txt_gt
    
    txt_max_s db "max_signed: ", 0
    len_max_s equ $-txt_max_s
    txt_max_u db "max_unsigned: ", 0
    len_max_u equ $-txt_max_u
    
    newline db 10

SECTION .bss
    ; memory
    buf resb 256
    out_buf resb 32
    num_a resd 1
    num_b resd 1

SECTION .text
_start:
    ; I/O: write prompt
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; I/O: read line
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, buf
    mov edx, 255
    int 0x80

    ; parse
    mov esi, buf
    call _atoi
    mov [num_a], eax

    call _atoi
    mov [num_b], eax

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_signed
    mov edx, len_signed
    int 0x80

    ; logic
    mov eax, [num_a]
    mov ebx, [num_b]
    cmp eax, ebx
    jl .signed_lt
    je .signed_eq
    jg .signed_gt

.signed_lt:
    ; I/O
    mov ecx, txt_lt
    mov edx, len_lt
    jmp .print_signed_res

.signed_eq:
    ; I/O
    mov ecx, txt_eq
    mov edx, len_eq
    jmp .print_signed_res

.signed_gt:
    ; I/O
    mov ecx, txt_gt
    mov edx, len_gt

.print_signed_res:
    ; I/O
    mov eax, 4
    mov ebx, 1
    int 0x80

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_unsigned
    mov edx, len_unsigned
    int 0x80

    ; logic
    mov eax, [num_a]
    mov ebx, [num_b]
    cmp eax, ebx
    jb .unsigned_lt
    je .unsigned_eq
    ja .unsigned_gt

.unsigned_lt:
    ; I/O
    mov ecx, txt_lt
    mov edx, len_lt
    jmp .print_unsigned_res

.unsigned_eq:
    ; I/O
    mov ecx, txt_eq
    mov edx, len_eq
    jmp .print_unsigned_res

.unsigned_gt:
    ; I/O
    mov ecx, txt_gt
    mov edx, len_gt

.print_unsigned_res:
    ; I/O
    mov eax, 4
    mov ebx, 1
    int 0x80

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_max_s
    mov edx, len_max_s
    int 0x80

    ; logic
    mov eax, [num_a]
    mov ebx, [num_b]
    cmp eax, ebx
    jg .max_s_a
    mov eax, ebx
.max_s_a:
    call _print_numeric_signed

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_max_u
    mov edx, len_max_u
    int 0x80

    ; logic
    mov eax, [num_a]
    mov ebx, [num_b]
    cmp eax, ebx
    ja .max_u_a
    mov eax, ebx
.max_u_a:
    call _print_numeric_unsigned

    ; exit
    mov eax, 1          ; sys_exit
    xor ebx, ebx
    int 0x80

_atoi:
    ; logic
    xor eax, eax
    xor ecx, ecx
    mov edi, 10

.skip_spaces:
    ; loops / logic
    mov dl, [esi]
    cmp dl, ' '
    je .inc_space
    cmp dl, 9
    je .inc_space
    jmp .check_sign
.inc_space:
    inc esi
    jmp .skip_spaces

.check_sign:
    ; logic
    cmp dl, '-'
    jne .loop_atoi
    mov ecx, 1
    inc esi

.loop_atoi:
    ; loops
    movzx ebx, byte [esi]
    
    ; logic
    cmp bl, 10
    je .atoi_done
    cmp bl, 13
    je .atoi_done
    cmp bl, 0
    je .atoi_done
    cmp bl, ' '
    je .atoi_done
    cmp bl, '0'
    jb .atoi_done
    cmp bl, '9'
    ja .atoi_done

    ; math
    mul edi
    sub bl, '0'
    add eax, ebx
    
    ; loops
    inc esi
    jmp .loop_atoi

.atoi_done:
    ; logic
    cmp ecx, 1
    jne .atoi_exit
    neg eax
.atoi_exit:
    ret

_print_numeric_signed:
    ; logic
    test eax, eax
    jns _print_numeric_unsigned
    
    push eax
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, buf
    mov byte [buf], '-'
    mov edx, 1
    int 0x80
    pop eax
    neg eax

_print_numeric_unsigned:
    ; logic
    mov ecx, out_buf
    add ecx, 31
    mov ebx, 10
    xor esi, esi

.loop_itoa:
    ; math / loops
    xor edx, edx
    div ebx
    
    ; parse
    add dl, '0'
    dec ecx
    mov [ecx], dl
    inc esi

    ; loops / logic
    test eax, eax
    jnz .loop_itoa

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov edx, esi
    int 0x80

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret
