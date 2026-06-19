; practice10.asm
; I/O: int 80h
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    ; memory
    prompt db "practice10: see README.md", 10
    prompt_len equ $-prompt
    
    char_zero db "0", 0
    char_one db "1", 0
    space db " ", 0
    newline db 10

    ; Позиції бітів за завданням (наприклад: встановити 3-й та 5-й, скинути 4-й)
    bit_p equ 3
    bit_q equ 5
    bit_r equ 4

SECTION .bss
    ; memory
    buf resb 256
    out_buf resb 32
    x resd 1
    popcount resd 1

SECTION .text
_start:
    ; I/O: write prompt
    mov eax, 4          
    mov ebx, 1          
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; I/O: read line
    mov eax, 3          
    mov ebx, 0          
    mov ecx, buf
    mov edx, 255
    int 0x80

    ; parse
    mov esi, buf
    call _atoi
    mov [x], eax

    ; logic
    mov ebx, [x]        ; ebx зберігає копію числа x для зсувів
    xor ecx, ecx        ; ecx = лічильник бітів (0..31)
    mov dword [popcount], 0

.loop_binary:
    ; loops
    cmp ecx, 32
    jge .binary_done

    ; math
    ; Перевіряємо старший біт через маску або зсув (друк зліва направо)
    mov eax, ebx
    and eax, 0x80000000

    ; logic
    jnz .print_one

.print_zero:
    ; I/O
    push ecx
    push ebx
    mov eax, 4
    mov ebx, 1
    mov ecx, char_zero
    mov edx, 1
    int 0x80
    pop ebx
    pop ecx
    jmp .check_space

.print_one:
    ; I/O
    push ecx
    push ebx
    mov eax, 4
    mov ebx, 1
    mov ecx, char_one
    mov edx, 1
    int 0x80
    pop ebx
    pop ecx
    
    ; math
    inc dword [popcount]

.check_space:
    ; math
    shl ebx, 1          ; Зсуваємо вліво для наступного біта
    inc ecx             ; Наступний біт
    
    ; logic
    mov eax, ecx
    and eax, 3          ; Перевірка, чи індекс кратний 4
    jnz .loop_binary
    cmp ecx, 32
    jge .loop_binary

    ; I/O: друк пробілу між групами по 4 біти
    push ecx
    push ebx
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop ebx
    pop ecx
    jmp .loop_binary

.binary_done:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; logic / I/O: вивід кількості одиничних бітів (popcount)
    mov eax, [popcount]
    call _print_numeric

    ; logic
    ; Застосування масок: set бітів p, q; clear біта r
    mov eax, [x]
    
    ; math
    ; SET бітів p та q (через OR)
    mov edx, 1
    mov ecx, bit_p
    shl edx, cl
    or eax, edx

    mov edx, 1
    mov ecx, bit_q
    shl edx, cl
    or eax, edx

    ; CLEAR біта r (через AND NOT)
    mov edx, 1
    mov ecx, bit_r
    shl edx, cl
    not edx
    and eax, edx

    ; I/O: вивід модифікованого числа в десятковому вигляді
    call _print_numeric

    ; exit
    mov eax, 1          
    xor ebx, ebx
    int 0x80

_atoi:
    ; logic
    xor eax, eax
    mov edi, 10

.skip_spaces:
    ; loops / logic
    mov dl, [esi]
    cmp dl, ' '
    je .inc_space
    cmp dl, 9
    je .inc_space
    cmp dl, 10
    je .inc_space
    cmp dl, 13
    je .inc_space
    jmp .loop_atoi
.inc_space:
    inc esi
    jmp .skip_spaces

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
    inc esi
    ret

_print_numeric:
    ; logic
    call _print_numeric_raw
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret

_print_numeric_raw:
    ; logic
    mov ecx, out_buf
    add ecx, 31
    mov edi, 10
    xor esi, esi
.loop_itoa:
    ; math / loops
    xor edx, edx
    div edi
    ; parse
    add dl, '0'
    dec ecx
    mov [ecx], dl
    inc esi
    ; loops
    test eax, eax
    jnz .loop_itoa
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov edx, esi
    int 0x80
    ret
