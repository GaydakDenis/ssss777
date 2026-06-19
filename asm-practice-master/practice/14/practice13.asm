; practice14.asm
; I/O: int 80h
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    ; memory
    prompt db "practice14: see README.md", 10
    prompt_len equ $-prompt
    
    space db " ", 0
    newline db 10

SECTION .bss
    ; memory
    buf resb 2048
    out_buf resb 32
    array resd 100
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
    jge .print_before
    
    push ecx
    call _atoi
    pop ecx
    
    ; memory
    mov [array + ecx*4], eax
    
    ; loops
    inc ecx
    jmp .loop_read_arr

.print_before:
    ; logic
    call _print_array

    ; logic
    ; Алгоритм Selection Sort (Вкладені цикли i та j)
    xor edi, edi        ; edi = i (0..n-2)

.loop_sort_i:
    ; loops / math
    mov eax, [n]
    dec eax             ; eax = n - 1
    cmp edi, eax
    jge .sort_done

    mov esi, edi        ; esi = min_idx = i
    mov ecx, edi
    inc ecx             ; ecx = j = i + 1

.loop_sort_j:
    ; loops
    cmp ecx, [n]
    jge .swap_min

    ; memory
    mov eax, [array + ecx*4]   ; array[j]
    mov ebx, [array + esi*4]   ; array[min_idx]
    
    ; logic
    cmp eax, ebx
    jge .next_j
    mov esi, ecx        ; оновлюємо min_idx = j

.next_j:
    ; loops
    inc ecx
    jmp .loop_sort_j

.swap_min:
    ; logic / memory
    ; Обмін двох dd елементів: array[i] та array[min_idx]
    cmp esi, edi
    je .next_i

    mov eax, [array + edi*4]
    mov ebx, [array + esi*4]
    mov [array + edi*4], ebx
    mov [array + esi*4], eax

.next_i:
    ; loops
    inc edi
    jmp .loop_sort_i

.sort_done:
    ; logic
    call _print_array

    ; logic / math
    ; Обчислення медіани: серединний елемент idx = n / 2.
    ; Для парного n — нижня середня, що еквівалентно звичайному цілочисельному діленню n / 2.
    mov eax, [n]
    xor edx, edx
    mov ebx, 2
    div ebx             ; eax = n / 2

    ; memory
    mov eax, [array + eax*4] ; беремо значення медіани з відсортованого масиву
    
    ; I/O
    call _print_numeric

    ; exit
    mov eax, 1          
    xor ebx, ebx
    int 0x80

_print_array:
    ; logic
    xor ecx, ecx
.loop_p:
    ; loops
    cmp ecx, [n]
    jge .p_done

    ; memory
    mov eax, [array + ecx*4]
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
    jmp .loop_p
.p_done:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret

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
