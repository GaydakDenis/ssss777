; practice12.asm
; I/O: int 80h
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    ; memory
    prompt_text db "Enter text: ", 0
    len_text equ $-prompt_text
    prompt_pat db "Enter pattern: ", 0
    len_pat equ $-prompt_pat
    
    txt_not_found db "-1", 10, 0
    len_not_found equ $-txt_not_found
    newline db 10

SECTION .bss
    ; memory
    buf_text resb 256
    buf_pat resb 64
    out_buf resb 32
    len_t resd 1
    len_p resd 1
    first_idx resd 1
    count resd 1

SECTION .text
_start:
    ; I/O
    mov eax, 4          
    mov ebx, 1          
    mov ecx, prompt_text
    mov edx, len_text
    int 0x80

    ; I/O
    mov eax, 3          
    mov ebx, 0          
    mov ecx, buf_text
    mov edx, 255
    int 0x80

    ; parse
    mov esi, buf_text
    call _strip_newline
    mov [len_t], eax

    ; I/O
    mov eax, 4          
    mov ebx, 1          
    mov ecx, prompt_pat
    mov edx, len_pat
    int 0x80

    ; I/O
    mov eax, 3          
    mov ebx, 0          
    mov ecx, buf_pat
    mov edx, 63
    int 0x80

    ; parse
    mov esi, buf_pat
    call _strip_newline
    mov [len_p], eax

    ; logic
    mov dword [first_idx], -1
    mov dword [count], 0

    ; Обробка випадку порожнього патерну (pattern == "")
    cmp dword [len_p], 0
    je .print_results

    xor edi, edi        ; edi = поточний індекс у text (i = 0)

.loop_outer:
    ; loops / math
    mov eax, [len_t]
    sub eax, [len_p]    ; eax = max_i (len_t - len_p)
    cmp edi, eax
    jg .print_results

    ; logic
    xor ecx, ecx        ; ecx = індекс у pattern (j = 0)

.loop_inner:
    ; loops
    cmp ecx, [len_p]
    jge .match_found

    ; memory / logic
    mov ebx, edi
    add ebx, ecx        ; ebx = i + j
    mov dl, [buf_text + ebx]
    mov dh, [buf_pat + ecx]
    cmp dl, dh
    jne .no_match

    ; loops
    inc ecx
    jmp .loop_inner

.match_found:
    ; math
    inc dword [count]
    
    ; logic
    cmp dword [first_idx], -1
    jne .skip_first_save
    mov [first_idx], edi

.skip_first_save:
    ; math / loops
    ; Зсув без перекриття: i = i + len_p - 1 (потім inc edi зробить i = i + len_p)
    add edi, [len_p]
    dec edi

.no_match:
    ; loops
    inc edi
    jmp .loop_outer

.print_results:
    ; logic / I/O
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
    call _print_numeric

.print_count:
    ; logic / I/O
    mov eax, [count]
    call _print_numeric

    ; exit
    mov eax, 1          
    xor ebx, ebx
    int 0x80

_strip_newline:
    ; logic / loops
    xor ecx, ecx
.loop_len:
    mov dl, [esi + ecx]
    cmp dl, 0
    je .len_done
    cmp dl, 10
    je .remove_nl
    cmp dl, 13
    je .remove_nl
    inc ecx
    jmp .loop_len
.remove_nl:
    mov byte [esi + ecx], 0
.len_done:
    mov eax, ecx
    ret

_print_numeric:
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
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret
