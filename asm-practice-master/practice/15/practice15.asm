; practice15.asm
; I/O: int 80h
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    ; memory
    prompt db "practice15: see README.md", 10
    prompt_len equ $-prompt
    
    txt_calls db "calls = ", 0
    len_calls equ $-txt_calls
    newline db 10

SECTION .bss
    ; memory
    buf resb 256
    out_buf resb 32
    calls resd 1

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

    ; logic
    mov dword [calls], 0

    ; Передаємо параметр у eax та викликаємо рекурсивну функцію
    call _factorial

    ; I/O: вивід результату fact(n)
    call _print_numeric

    ; I/O: вивід префіксу "calls = "
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_calls
    mov edx, len_calls
    int 0x80

    ; logic / I/O: вивід кількості викликів
    mov eax, [calls]
    call _print_numeric

    ; exit
    mov eax, 1          
    xor ebx, ebx
    int 0x80

_factorial:
    ; logic
    ; Пролог рекурсивної функції
    push ebp
    mov ebp, esp

    ; math
    inc dword [calls]   ; збільшуємо глобальний лічильник викликів

    ; logic
    ; Базовий випадок: якщо n <= 1, повертаємо 1
    cmp eax, 1
    jbe .base_case

    ; Рекурсивний крок
    push eax            ; зберігаємо поточне значення n у стеку
    dec eax             ; обчислюємо n - 1
    call _factorial     ; рекурсивний виклик, результат повертається в eax
    pop ebx             ; відновлюємо оригінальне n у ebx

    ; math
    mul ebx             ; eax = eax * ebx (тобто fact(n-1) * n)
    jmp .epilogue

.base_case:
    ; logic
    mov eax, 1          ; 0! = 1 та 1! = 1

.epilogue:
    ; logic
    ; Епілог функції
    mov esp, ebp
    pop ebp
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
