; practice13.asm
; I/O: int 80h
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    ; memory
    prompt db "practice13: see README.md", 10
    prompt_len equ $-prompt
    
    txt_yes db "PALINDROME: YES", 10, 0
    len_yes equ $-txt_yes
    txt_no db "PALINDROME: NO", 10, 0
    len_no equ $-txt_no
    
    space db " ", 0
    newline db 10

SECTION .bss
    ; memory
    buf resb 2048
    out_buf resb 32
    array_orig resd 200
    array_rev resd 200
    n resd 1

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
    mov edx, 2047
    int 0x80

    ; parse
    mov esi, buf
    call _atoi
    mov [n], eax

    ; Зчитуємо елементи масиву
    xor ecx, ecx
.loop_read_arr:
    ; loops
    cmp ecx, [n]
    jge .process_arrays
    
    push ecx
    call _atoi
    pop ecx
    
    ; memory
    mov [array_orig + ecx*4], eax
    
    ; loops
    inc ecx
    jmp .loop_read_arr

.process_arrays:
    ; memory / logic
    ; Створення реверсованої копії блоку пам'яті
    ; Копіюємо з кінця array_orig на початок array_rev
    xor ecx, ecx        ; ecx = індекс призначення (0..n-1)
    mov edx, [n]
    dec edx             ; edx = вихідний індекс джерела (n-1..0)

.loop_reverse:
    ; loops
    cmp ecx, [n]
    jge .print_orig

    ; memory
    mov eax, [array_orig + edx*4]
    mov [array_rev + ecx*4], eax

    ; loops / math
    inc ecx
    dec edx
    jmp .loop_reverse

.print_orig:
    ; logic
    xor ecx, ecx
.loop_print_orig:
    ; loops
    cmp ecx, [n]
    jge .print_orig_done

    ; memory
    mov eax, [array_orig + ecx*4]
    push ecx
    call _print_numeric_raw
    
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop ecx

    ; loops
    inc ecx
    jmp .loop_print_orig

.print_orig_done:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

.print_rev:
    ; logic
    xor ecx, ecx
.loop_print_rev:
    ; loops
    cmp ecx, [n]
    jge .print_rev_done

    ; memory
    mov eax, [array_rev + ecx*4]
    push ecx
    call _print_numeric_raw
    
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop ecx

    ; loops
    inc ecx
    jmp .loop_print_rev

.print_rev_done:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

.check_palindrome:
    ; logic
    ; Порівнюємо блоки пам'яті оригінального та реверсованого масивів
    xor ecx, ecx        ; ecx = індекс (0..n-1)

.loop_cmp:
    ; loops
    cmp ecx, [n]
    jge .is_palindrome

    ; memory
    mov eax, [array_orig + ecx*4]
    mov ebx, [array_rev + ecx*4]
    
    ; logic
    cmp eax, ebx
    jne .not_palindrome

    ; loops
    inc ecx
    jmp .loop_cmp

.is_palindrome:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_yes
    mov edx, len_yes
    int 0x80
    jmp .exit

.not_palindrome:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_no
    mov edx, len_no
    int 0x80

.exit:
    ; logic: exit
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
