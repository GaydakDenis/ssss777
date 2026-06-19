; practice11.asm
; I/O: int 80h
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    ; memory
    prompt db "practice11: see README.md", 10
    prompt_len equ $-prompt
    
    char_space equ ' '
    char_star  equ '*'
    char_nl    equ 10

SECTION .bss
    ; memory
    buf resb 256
    line_buf resb 512
    h resd 1

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
    mov [h], eax

    ; logic
    xor edi, edi        ; edi = поточний рядок i (0..h-1)

.loop_rows:
    ; loops
    mov eax, [h]
    cmp edi, eax
    jge .exit

    ; math
    ; Кількість пробілів: spaces = h - i - 1
    mov ebx, eax
    sub ebx, edi
    dec ebx             ; ebx = spaces count

    ; Кількість зірочок: stars = 2 * i + 1
    mov ecx, edi
    shl ecx, 1          ; ecx = 2 * i
    inc ecx             ; ecx = stars count

    ; memory
    mov edx, line_buf   ; edx = вказівник на поточну позицію в буфері рядка

.loop_spaces:
    ; loops / logic
    test ebx, ebx
    jz .stars_init
    
    ; memory
    mov byte [edx], char_space
    inc edx
    dec ebx
    jmp .loop_spaces

.stars_init:
    ; logic
    xor ebp, ebp        ; ebp = лічильник зірочок

.loop_stars:
    ; loops / logic
    cmp ebp, ecx
    jge .row_done

    ; memory
    mov byte [edx], char_star
    inc edx
    inc ebp
    jmp .loop_stars

.row_done:
    ; memory
    mov byte [edx], char_nl
    inc edx

    ; math / logic
    ; Обчислюємо загальну довжину сформованого рядка
    mov eax, edx
    sub eax, line_buf   ; eax = довжина рядка в байтах

    ; I/O
    ; Передаємо параметри у підпрограму print_line
    push eax            ; len
    push line_buf       ; buf
    call _print_line
    add esp, 8          ; очищення стеку

    ; loops
    inc edi             ; перехід до наступного рядка
    jmp .loop_rows

.exit:
    ; logic: exit
    mov eax, 1          
    xor ebx, ebx
    int 0x80

_print_line:
    ; logic
    push ebp
    mov ebp, esp
    
    ; I/O
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, [ebp + 8]  ; buf address
    mov edx, [ebp + 12] ; len
    int 0x80
    
    ; logic
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
