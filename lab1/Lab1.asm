.model small

.stack 100h

.data
    message_in_a        db "Please enter a: $" 
    message_in_b        db "Please enter b: $" 
    message_in_c        db "Please enter c: $" 
    message_in_d        db "Please enter d: $"
    message_res         db "Result: $"
    message_err         db "Input error" 
    crlf                db 0Dh,0Ah,'$'                  ; on next line
    name_a              dw (?)
    name_b              dw (?)
    name_d              dw (?)
    name_c              dw (?)

.code

output_str macro
    push ax
    mov ah,09h
    int 21h
    pop ax
endm

input_char macro
    mov ah,01h
    int 21h
endm

input_proc macro
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
    neg ax                ; ax2al
    jmp END_OF_INPUT_PROC
WHILE_END:
digits_into_a_number
END_OF_INPUT_PROC:
endm

ASCII_to_bin macro
local ERROR_IN_INPUT,PUSH_IN_STACK
    sub al,'0'
    jb ERROR_IN_INPUT
    cmp al,9
    ja ERROR_IN_INPUT
    xor bl,bl
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

bin_to_ASCII macro
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

output_char macro
    push ax
    mov ah,02h
    int 21h
    pop ax
endm

digits_into_a_number macro
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

    ;entering the value of variable a

    lea dx, message_in_a
    output_str

    input_proc

    lea dx,crlf
    output_str

    mov word ptr [name_a],ax

    ;end of entering the value of variable a

    xor ax,ax
    add ax,[name_a]

    ;entering the value of variable b

    lea dx,message_in_b
    output_str

    input_proc

    lea dx,crlf
    output_str

    mov word ptr [name_b],ax

    ;end of entering the value of variable b

    ;entering the value of variable c

    lea dx,message_in_c
    output_str

    input_proc

    lea dx,crlf
    output_str

    mov word ptr [name_c],ax

    ;end of entering the value of variable a

    ;entering the value of variable d

    lea dx,message_in_d
    output_str

    input_proc

    lea dx,crlf
    output_str

    mov word ptr [name_d],ax

    ;end of entering the value of variable d

    mov ax,word ptr [name_a]
    mov bx,word ptr [name_b]

    cmp ax,bx                         ; if(a >= b) then goto LABEL3
    jge LABEL3
    mov ax, word ptr [name_c]
    mov bx, word ptr [name_d]
    cmp ax, bx                        ; if(c >= d) then goto LABEL3
    jge LABEL3
    xor ax,ax
    add ax,[name_c]                   ; ax = c
    add ax,[name_d]                   ; ax = c + d
    mov bx,word ptr [name_b]          ; bx = b
    imul bx                           ; ax = b * (c + d)
    mov bx,ax                         ; bx = b * (c + d)
    mov ax,word ptr [name_a]          ; ax = a
    sub ax,bx                         ; ax = ax - b * (c + d)
    jmp PRINT_RES

LABEL3:

    sub bx,[name_c]                   ; bx = b - c
    add ax,[name_d]                   ; ax = a + d
    cmp bx,ax
    jle LABEL4

SECOND_CONDITION:

    mov ax,word ptr [name_a]          ; ax = a
    neg ax                            ; ax = -a
    mov bx,word ptr [name_d]          ; bx = d
    imul bx                           ; ax = d * (-a)
    add ax,[name_b]                   ; ax = d * (-a) + b
    add ax,[name_c]                   ; ax = d * (-a) + b + c
    jmp PRINT_RES

LABEL4:

    mov ax,word ptr [name_c]          ; ax = c
    mov bx,word ptr [name_d]          ; bx = d
    cmp ax,bx                         ; if(c != d) then goto SECOND_CONDITION
    jne SECOND_CONDITION       

    mov ax,word ptr [name_a]          ; ax = a
    add ax,[name_b]                   ; ax = a + b
    add ax,[name_c]                   ; ax = a + b + c
    add ax,[name_d]                   ; ax = a + b + c + d
    sub ax,3                          ; ax = a + b + c + d - 3

PRINT_RES:
    lea dx,message_res
    output_str
    bin_to_ASCII
END_OF_PR:
    MOV ax,4C00h
    INT 21h
END START

