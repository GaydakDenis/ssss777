; practice5.asm
; I/O: int 80h
; blocks: I/O, parse, math, logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
    ; memory
    prompt db "practice5: see README.md", 10
    prompt_len equ $-prompt
    newline db 10

SECTION .bss
    ; memory
    buf resb 256
    out_buf resb 32

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
    mov ebx, 10         

.loop_atoi:
    ; loops
    movzx ecx, byte [esi]
    
    ; logic
    cmp cl, 10          
    je .atoi_done
    cmp cl, 0           
    je .atoi_done
    cmp cl, '0'         
    jb .atoi_done
    cmp cl, '9'         
    ja .atoi_done

    ; math
    mul ebx             
    sub cl, '0'         
    add eax, ecx        
    
    ; loops
    inc esi
    jmp .loop_atoi

.atoi_done:
    ; logic
    xor edi, edi        
    xor ebp, ebp        
    mov ebx, 10         

.loop_calc:
    ; loops / logic
    test eax, eax       
    jz .calc_done

    ; math
    xor edx, edx        
    div ebx             
    
    add ebp, edx        
    inc edi             
    
    ; loops
    jmp .loop_calc

.calc_done:
    ; logic
    push edi            
    mov eax, ebp        
    call _print_numeric

    ; logic
    pop eax             
    call _print_numeric

    ; logic: exit
    mov eax, 1          
    xor ebx, ebx
    int 0x80

_print_numeric:
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
