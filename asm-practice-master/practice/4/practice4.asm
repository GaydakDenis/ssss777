BITS 32
GLOBAL _start

SECTION .data
    prompt db "practice3: see README.md", 10
    prompt_len equ $-prompt
    newline db 10

SECTION .bss
    buf resb 256
    out_buf resb 16

SECTION .text
_start:
    mov eax, 4          
    mov ebx, 1          
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    mov eax, 3          
    mov ebx, 0          
    mov ecx, buf
    mov edx, 255
    int 0x80

    mov esi, buf
    xor eax, eax        
    mov ebx, 10         

.loop_parse:
    movzx ecx, byte [esi]
    
    cmp cl, 10          
    je .parse_done
    cmp cl, 0           
    je .parse_done
    cmp cl, '0'         
    jb .parse_done
    cmp cl, '9'         
    ja .parse_done

    sub cl, '0'         
    mul ebx             
    add eax, ecx        
    
    inc esi
    jmp .loop_parse

.parse_done:
    and eax, 0xFFFF     

    mov ecx, out_buf        
    add ecx, 15         
    mov ebx, 10         
    mov edi, 0          

.loop_convert:
    xor edx, edx        
    div ebx             

    add dl, '0'         
    dec ecx             
    mov [ecx], dl       
    inc edi             

    test eax, eax       
    jnz .loop_convert   

    mov eax, 4          
    mov ebx, 1          
    mov edx, edi        
    int 0x80

    mov eax, 4          
    mov ebx, 1          
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1          
    xor ebx, ebx
    int 0x80
