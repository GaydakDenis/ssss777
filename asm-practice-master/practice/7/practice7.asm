; practice7.asm
; I/O: int 80h
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    ; memory
    prompt db "practice7: see README.md", 10
    prompt_len equ $-prompt
    
    txt_min db "min: ", 0
    len_min equ $-txt_min
    txt_max db "max: ", 0
    len_max equ $-txt_max
    txt_idx db " index: ", 0
    len_idx equ $-txt_idx
    
    space db " ", 0
    newline db 10

SECTION .bss
    ; memory
    buf resb 256
    out_buf resb 32
    array resd 50
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
    mov edx, 255
    int 0x80

    ; parse
    mov esi, buf
    xor eax, eax
    mov edi, 10
.loop_atoi:
    ; loops
    movzx ebx, byte [esi]
    cmp bl, 10
    je .atoi_done
    cmp bl, 0
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
    mov [n], eax

    ; logic
    xor ecx, ecx        
.loop_fill:
    ; loops
    cmp ecx, [n]
    jge .fill_done
    ; math
    mov eax, ecx
    mov edi, 7
    mul edi
    add eax, 3
    ; memory
    mov [array + ecx*4], eax
    ; loops
    inc ecx
    jmp .loop_fill

.fill_done:
    ; logic
    xor ecx, ecx
.loop_print_arr:
    ; loops
    cmp ecx, [n]
    jge .print_arr_done
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
    ; loops
    pop ecx
    inc ecx
    jmp .loop_print_arr

.print_arr_done:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; logic
    mov eax, [array]     
    xor ebx, ebx        
    mov edx, [array]     
    xor ebp, ebp        
    mov ecx, 1          

.loop_search:
    ; loops
    cmp ecx, [n]
    jge .search_done
    ; memory
    mov edi, [array + ecx*4]
    ; logic
    cmp edi, eax
    jge .check_max
    mov eax, edi
    mov ebx, ecx
    jmp .next_search
.check_max:
    cmp edi, edx
    jle .next_search
    mov edx, edi
    mov ebp, ecx
.next_search:
    ; loops
    inc ecx
    jmp .loop_search

.search_done:
    ; memory
    push ebp
    push edx
    push ebx
    push eax

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_min
    mov edx, len_min
    int 0x80
    ; logic
    pop eax
    call _print_numeric_raw
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_idx
    mov edx, len_idx
    int 0x80
    ; logic
    pop eax
    call _print_numeric

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_max
    mov edx, len_max
    int 0x80
    ; logic
    pop eax
    call _print_numeric_raw
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_idx
    mov edx, len_idx
    int 0x80
    ; logic
    pop eax
    call _print_numeric

    ; exit
    mov eax, 1          
    xor ebx, ebx
    int 0x80

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
