; practice8.asm
; I/O: int 80h
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    ; memory
    prompt db "practice8: see README.md", 10
    prompt_len equ $-prompt
    
    txt_not_found db "-1", 10, 0
    len_not_found equ $-txt_not_found
    
    space db " ", 0
    newline db 10

SECTION .bss
    ; memory
    buf resb 1024
    out_buf resb 32
    array resd 100
    n resd 1
    target resd 1
    first_idx resd 1
    count resd 1

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
    mov edx, 1023
    int 0x80

    ; parse
    mov esi, buf
    
    ; Зчитуємо n
    call _atoi
    mov [n], eax

    ; Зчитуємо масив n чисел
    xor ecx, ecx
.loop_read_arr:
    ; loops
    cmp ecx, [n]
    jge .read_target
    
    push ecx
    call _atoi
    pop ecx
    
    ; memory
    mov [array + ecx*4], eax
    
    ; loops
    inc ecx
    jmp .loop_read_arr

.read_target:
    ; parse
    call _atoi
    mov [target], eax

    ; logic
    mov dword [first_idx], -1
    mov dword [count], 0
    xor ecx, ecx        ; ecx = поточний індекс i = 0

.loop_search:
    ; loops
    cmp ecx, [n]
    jge .search_done

    ; memory
    mov eax, [array + ecx*4]
    
    ; logic
    cmp eax, [target]
    jne .next_item

    ; math
    inc dword [count]
    
    ; logic
    cmp dword [first_idx], -1
    jne .next_item
    mov [first_idx], ecx

.next_item:
    ; loops
    inc ecx
    jmp .loop_search

.search_done:
    ; logic / I/O: вивід першого індексу або -1
    mov eax, [first_idx]
    cmp eax, -1
    jne .print_first
    
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_not_found
    mov edx, len_not_found
    int 0x80
    jmp .print_count

.print_first:
    ; logic
    call _print_numeric
    jmp .print_count

.print_count:
    ; logic / I/O: вивід кількості входжень
    mov eax, [count]
    call _print_numeric

    ; logic / I/O: вивід списку всіх індексів
    xor ecx, ecx
.loop_print_indices:
    ; loops
    cmp ecx, [n]
    jge .indices_done

    ; memory
    mov eax, [array + ecx*4]
    
    ; logic
    cmp eax, [target]
    jne .next_index

    mov eax, ecx
    push ecx
    call _print_numeric_raw
    
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop ecx

.next_index:
    ; loops
    inc ecx
    jmp .loop_print_indices

.indices_done:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

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
    ; logic
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
