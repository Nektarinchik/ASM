.model small

.stack 100h

.data
    message_err         db "Bad input$" 
    crlf                db 0Ah,'$'                      ; on next line
    b_max_size          db 200                          ; max size of input buf
    b_length            db (?)                          ; real buffer size after input proc
    buff                db 200 dup (?)
.code

output_str macro                                        ; print string(dx) in the console
    push ax
    mov ah,09h
    int 21h
    pop ax
endm

output_char macro
    push ax
    mov ah,02h
    int 21h
    pop ax
endm

input_char macro                                        ; entering a single character
    mov ah,01h
    int 21h
endm

input_string proc        
    push bp              
    mov bp, sp

    push cx
    push ax
    push bx

    mov bx, [bp + 4]
    xor cx, cx       

INPUT:
    input_char

    cmp al, 13
    jne  LABEL2
    jmp END_OF_INPUT

LABEL2:

    cmp al, 41h                                         ; if(char < 'A') then goto ERROR
    jb ERROR

    cmp al, 7ah                                         ; if(char > 'z') then goto ERROR
    ja ERROR   

    cmp al, 5ah                                         ; if(char < 'Z') then goto LABEL1
    jbe LABEL1

    cmp al, 61h                                         ; if(char < 'a') then goto ERROR
    jb ERROR

LABEL1:
    mov byte ptr [bx], al
    inc bx
    inc cl
    jmp INPUT
END_OF_INPUT:

    jmp END_OF_INPUT_STRING

ERROR:
    lea dx, crlf 
    output_str 
    
    lea dx, message_err
    output_str
    jmp END_OF_PR

END_OF_INPUT_STRING:
    mov byte ptr [b_length], cl

    pop bx
    pop ax
    pop cx

    mov sp,bp
    pop bp      
    ret 2
endp input_string

print_string proc
    push bp              
    mov bp, sp
    push cx
    push dx

    mov bx, [bp + 4]
    xor cx, cx   
    mov cl, [b_length]        

PRINT:
    mov dl, byte ptr [bx] 
    output_char
    inc bx
loop PRINT

    pop dx
    pop cx
    mov sp,bp
    pop bp      
    ret 2
endp print_string


q_sort proc
    push bp                                             ; create stack frame
    mov bp, sp   
    push ax                                             ; push all used registers
    push bx
    push cx 
    push di   
    push dx   
    mov bx, [bp + 6]                                    ; get pointers to func arguments
    mov di, [bp + 4]
    cmp bx, di                                          ; if size of sorted segment is 1 then exit recursion
    jae RETURN                                             
    push bx   
    push di   
    call pick_pivot
    pop ax                                              ; value of pivot
    push bx                                             ; push args for func split
    push di  
    push ax    
    call split
    pop dx                                              ; dx = new r_border
    push bx           
    push dx 
    call q_sort                                         ; q_sort(old_l_border, new r_border)
    pop dx                                              ; dx = new l_border
    push dx  
    push di   
    call q_sort                                         ; q_sort(new_l_border, old_r_border)
RETURN:
    pop dx
    pop di      
    pop cx   
    pop bx      
    pop ax 
    mov sp,bp
    pop bp      
    ret 4
endp q_sort

pick_pivot proc
    push bp                                             ; create stack frame
    mov bp, sp 
    push bx                                             ; push all used registers
    push di   
    push ax
    mov bx, [bp + 6]                                    ; get ptrs to func args
    mov di, [bp + 4]                
    add bx, di                                          ; calculate index of pivot
    shr bx, 1
    xor ax, ax
    mov al, byte ptr [bx]
    mov [bp + 6], ax                                    ; push return value
    pop ax
    pop di   
    pop bx 
    mov sp, bp
    pop bp    
    ret 2                                               ; callee cleans up
endp pick_pivot

split proc    
    push bp  
    mov bp,sp   
    push ax 
    push bx  
    push cx 
    push dx 
    push di  
    mov bx, [bp + 8]                                    ; start of the buf
    mov di, [bp + 6]                                    ; end of the buf
    mov ax, [bp + 4]                                    ; pivot 
WHILE_ONE_START:                                        ; bx = index of l_border; di = index of r_border
    cmp bx, di                                          ; if (L > R) then goto WHILE_ONE_END
    ja WHILE_ONE_END
    WHILE_TWO_START:
        mov dh, byte ptr [bx]
        mov dl, al
        cmp dh, dl                                      ; if(buf[L] < pivot) then ++L
        jae WHILE_TWO_END 
        inc bx
        jmp WHILE_TWO_START
    WHILE_TWO_END:

    WHILE_THREE_START:
        mov dh, byte ptr [di]                   
        cmp dh, al                                      ; if(buf[R] > pivot) then --R
        jbe WHILE_THREE_END
        dec di
        jmp WHILE_THREE_START
    WHILE_THREE_END:

    cmp bx, di      
    ja WHILE_ONE_END
    push bx            
    push di    
    call swap  
    inc bx           
    dec di     
    jmp WHILE_ONE_START
WHILE_ONE_END:
    mov [bp + 6], di
    mov [bp + 8], bx       
    pop di     
    pop dx    
    pop cx   
    pop bx   
    pop ax 
    mov sp, bp
    pop bp   
    ret 2 
endp split

swap proc    
    push bp      
    mov bp, sp     

    push ax   
    push bx 
    push di 

    mov bx, [bp + 6]                                       ; bx = L
    mov di, [bp + 4]                                       ; di = R

    mov al, [byte ptr bx]                                  ; al = A[L]
    xchg byte ptr [di], al                                 ; al = A[R], *di = A[L]
    mov byte ptr [bx], al                                  ; *bx = A[R]

    pop di
    pop bx  
    pop ax 

    mov sp, bp
    pop bp
    ret 4
endp swap

START:
    mov ax,@data
    mov ds,ax

    lea bx, byte ptr[buff]                                ; load effective adress of buf
    push bx                                                   
    call input_string

    lea bx, byte ptr[buff]
    xor ax, ax
    mov al, byte ptr [b_length]  
    push bx                                               ; load effective adress of end of buf in di
    add bx, ax
    dec bx 
    mov di, bx
    pop bx

    push bx                                               ; push pointers to func arguments
    push di
    call q_sort

    push bx
    call print_string

END_OF_PR:
    MOV ax, 4C00h
    INT 21h
END START
