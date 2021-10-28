.model small

.stack 100h

.data
    message_in_n        db "Please enter a: $" 
    message_err         db "Input error" 
    message_res         db "Result: $"
    crlf                db 0Dh,0Ah,'$'                  ; on next line
    name_n              dw (?)
    divider             dw (?)
    is_prime            dw (?)
.code

output_str macro                                        ; print string(dx) in the console
    push ax
    mov ah,09h
    int 21h
    pop ax
endm

input_char macro                                        ; entering a single character
    mov ah,01h
    int 21h
endm

input_proc macro                                        ; checks if the number is greater than three digits, pressing enter and whether it is negative
local WHILE_START,WHILE_END,FOR_NEG,WHILE_START_NEG,WHILE_END_NEG,END_OF_INPUT_PROC,LABEL1,LABEL2
    xor cx,cx
WHILE_START:
    cmp cx,3
    jne LABEL1
    jmp WHILE_END
LABEL1:
    input_char
    cmp al,13
    jne LABEL2
    jmp WHILE_END
LABEL2:
    cmp al,'-'
    je FOR_NEG
    inc cx
    ASCII_to_bin
    jmp WHILE_START
FOR_NEG:
    WHILE_START_NEG:
        cmp cx,3
        je WHILE_END_NEG
        input_char
        cmp al,13
        je WHILE_END_NEG
        inc cx
        ASCII_to_bin
        jmp WHILE_START_NEG
    WHILE_END_NEG:
    digits_into_a_number
    neg ax                
    jmp END_OF_INPUT_PROC
WHILE_END:
digits_into_a_number
END_OF_INPUT_PROC:
endm

ASCII_to_bin macro                                     ; checks whether the symbol is a number, converts it from ASCII to bin
local ERROR_IN_INPUT,PUSH_IN_STACK
    sub al,'0'
    jb ERROR_IN_INPUT
    cmp al,9
    ja ERROR_IN_INPUT
    mov bl,al
    xor al,al
    xor bh,bh
    jmp PUSH_IN_STACK
ERROR_IN_INPUT:
    lea dx, crlf
    output_str
    lea dx,message_err
    output_str
    jmp END_OF_PR
PUSH_IN_STACK:
    push bx
endm

bin_to_ASCII macro                                     ; by dividing a number by 10, we will translate its individual characters from bin to ascii
local LABEL6,FOR_NEG,END_OF_BIN_TO_DEC
    js FOR_NEG
    xor cx,cx
LABEL6: 
    mov bx,10
    xor dx,dx
    div bx
    add dx,'0'
    push dx
    inc cx
    cmp ax,0
    jne LABEL6
    INVERSE:
        pop dx
        output_char
    loop INVERSE
    jmp END_OF_BIN_TO_DEC
FOR_NEG:
    xor cx,cx
    neg ax
    mov dl,'-'
    output_char
    jmp LABEL6
END_OF_BIN_TO_DEC:
endm

output_char macro                                       ; print a single character
    push ax
    mov ah,02h
    int 21h
    pop ax
endm

digits_into_a_number macro                              ; makes up a number of individual digits
local MUL_LOOP,TEN_DEGREE,AFTER_LOOP
    xor bx,bx
    xor ax,ax
MUL_LOOP:
    pop dx     
    push cx
    push ax
    mov cx,bx
    cmp cx,0
    je AFTER_LOOP
    TEN_DEGREE:
        mov ax,1010b
        mul dx
        mov dx,ax
    loop TEN_DEGREE
AFTER_LOOP:
    pop ax
    add ax,dx
    pop cx
    inc bx
loop MUL_LOOP
endm

START:
    mov ax,@data
    mov ds,ax

    lea dx,message_in_n
    output_str

    input_proc

    lea dx,crlf
    output_str

    mov word ptr [name_n],ax

    mov cx,word ptr [name_n]
    sub cx,1
    mov bx,2                             ; bx = i

    mov ax,word ptr [name_n]             
    cmp ax,1                             ; if(N != 1) then
    jne LOOP1                            ; goto LOOP1
    mov word ptr [divider],1             ; if N == 1 then divider = 1 and print divider
    jmp END_LOOP

LOOP1:
    mov ax,word ptr [name_n]             ; ax = N
    mov word ptr [is_prime],1            ; boolean variable
    xor dx,dx
    div bx                               ; ax = N / i, dx = N % i
    cmp dx,0                             ; if(dx == 0) then 
    jne LABEL3                           ; goto LABEL3
    push cx 
    mov cx,2                             ; cx = j, bx = div
    LOOP_START2:                         ; check wheteher the div is prime
        cmp cx,bx 
        je LOOP_END2
        mov ax,bx
        xor dx,dx
        div cx
        cmp dx,0
        je MAKE_NOT_PRIME
        inc cx
        jmp LOOP_START2
    MAKE_NOT_PRIME:
    mov is_prime,0
    LOOP_END2:
    cmp is_prime,1
    jne LABEL5
    mov word ptr [divider],cx           ; if our number is realy prime then divider = num 
LABEL5:
    pop cx
LABEL3:
    inc bx  
loop LOOP1
END_LOOP:

mov ax,word ptr [divider]

lea dx,message_res
output_str

bin_to_ASCII

END_OF_PR:
    MOV ax,4C00h
    INT 21h
END START

