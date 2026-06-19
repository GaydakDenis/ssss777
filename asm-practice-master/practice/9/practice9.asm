; practice9.asm
; I/O: int 80h
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    ; memory
    prompt db "practice9: see README.md", 10
    prompt_len equ $-prompt
    
    separator db ": ", 0
    hash db "#", 0
    open_paren db " (", 0
    close_paren db ")", 10, 0
    newline db 10

    ; LCG константи
    lcg_m dd 1103515245
    lcg_c dd 12345

SECTION .bss
    ; memory
    buf resb 256
    out_buf resb 32
    freq resd 10
    n resd 1
    seed resd 1

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
    mov [n], eax

    ; logic
    ; Початкове значення для LCG (seed) можна взяти рівним n
    mov [seed], eax
    
    ; Обнуляємо масив частот freq
    xor ecx, ecx
.loop_clear:
    ; loops
    cmp ecx, 10
    jge .generation_start
    mov dword [freq + ecx*4], 0
    inc ecx
    jmp .loop_clear

.generation_start:
    ; logic
    xor ecx, ecx        ; ecx = лічильник ітерацій генерації (0..n-1)

.loop_generate:
    ; loops
    cmp ecx, [n]
    jge .print_histogram

    ; math
    ; LCG: x = (1103515245 * x + 12345) mod 2^31
    mov eax, [seed]
    mov edx, [lcg_m]
    mul edx             ; EDX:EAX = EAX * lcg_m
    add eax, [lcg_c]    ; EAX = EAX + 12345
    and eax, 0x7FFFFFFF ; mod 2^31 (скидаємо старший біт)
    mov [seed], eax     ; зберігаємо новий seed

    ; Отримуємо індекс кошика від 0 до 9: (x % 10)
    xor edx, edx
    mov edi, 10
    div edi             ; EDX = eax % 10
    
    ; memory / logic
    inc dword [freq + edx*4]

    ; loops
    inc ecx
    jmp .loop_generate

.print_histogram:
    ; logic
    xor ecx, ecx        ; ecx = поточний кошик (0..9)

.loop_buckets:
    ; loops
    cmp ecx, 10
    jge .exit

    ; I/O: вивід номеру кошика (0..9)
    push ecx
    mov eax, ecx
    call _print_numeric_raw
    
    mov eax, 4
    mov ebx, 1
    mov ecx, separator
    mov edx, 2
    int 0x80
    pop ecx

    ; memory / logic
    mov ebp, [freq + ecx*4] ; ebp = count (скільки знаків # малювати)
    push ecx
    xor esi, esi        ; esi = лічильник надрукованих #

.loop_hashes:
    ; loops
    cmp esi, ebp
    jge .hashes_done

    ; I/O: друк символу '#'
    push esi
    push ebp
    mov eax, 4
    mov ebx, 1
    mov ecx, hash
    mov edx, 1
    int 0x80
    pop ebp
    pop esi

    ; loops
    inc esi
    jmp .loop_hashes

.hashes_done:
    ; I/O: друк " (count)"
    mov eax, 4
    mov ebx, 1
    mov ecx, open_paren
    mov edx, 2
    int 0x80

    mov eax, ebp
    call _print_numeric_raw

    mov eax, 4
    mov ebx, 1
    mov ecx, close_paren
    mov edx, 2
    int 0x80

    ; loops
    pop ecx
    inc ecx
    jmp .loop_buckets

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
    ; logic
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
