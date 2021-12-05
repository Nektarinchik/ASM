.model small

.stack 100h

.data
    message_in_rows        db "Please enter amount of rows: $" 
    message_err            db "Bad input$" 
    message_in_cols        db "Please enter amount of cols: $"
    message_res            db "Result: $"
    crlf                   db 0Dh,0Ah,'$'               ; on next line
    rows                   db (?)
    cols                   db (?)
    greatest_element       db (?)
    sum                    db (?)
    matrix                 db 100 dup(100 dup (?))      ; allocate memory for matrix
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

    push cx   
    push bx    
    push dx     

    xor cx,cx
WHILE_START:
LABEL1:
    input_char
    cmp al,32
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
        input_char
        cmp al,32
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

    pop dx
    pop bx    
    pop cx

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

check_for_illegal_rows macro 
    cmp byte ptr [rows],0
    jl ILLEGAL_ROWS_AMOUNT
    jmp END_OF_CHECK_ROWS
ILLEGAL_ROWS_AMOUNT:
    lea dx, crlf
    output_str
    lea dx,message_err
    output_str
    jmp END_OF_PR
END_OF_CHECK_ROWS:
endm

check_for_illegal_cols macro 
    cmp byte ptr [cols],0
    jl ILLEGAL_COLS_AMOUNT
    jmp END_OF_CHECK_COLS
ILLEGAL_COLS_AMOUNT:
    lea dx, crlf
    output_str
    lea dx,message_err
    output_str
    jmp END_OF_PR
END_OF_CHECK_COLS:
endm

bin_to_ASCII macro                                     ; by dividing a number by 10, we will translate its individual characters from bin to ascii
local LABEL6,FOR_NEG,END_OF_BIN_TO_DEC,INVERSE

    push cx  
    push bx                               
    push dx                     

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

    pop dx            
    pop bx             
    pop cx
endm

filling_of_matrix proc         
    push bp                   
    mov bp,sp

    push bx     
    push si           
    push cx   
    push ax    

    xor si,si                   ; si - cols
    xor bx,bx                   ; bx - rows

    xor cx,cx
    mov cl,byte ptr [rows]      ; EXTERNAL loop : for i in range (0, rows_amount)

EXTERNAL:
    push cx 
    xor cx,cx
    mov cl,byte ptr [cols]

    INTERNAL:                   ; INTERNAL loop : for j in range (0, cols_amount)
        input_proc
        mov byte ptr matrix[bx][si], al
        inc si
    loop LABEL4
    jmp LABEL3
LABEL4:
    jmp INTERNAL
LABEL3:
    inc bx
    pop cx
loop LABEL5
    jmp LABEL7
LABEL5:
    jmp EXTERNAL
LABEL7:

    pop ax
    pop cx 
    pop si 
    pop dx

    mov sp,bp
    pop bp 
    ret
endp filling_of_matrix

print_string proc               
    push bp                    ; using registers: bx,si,cx,al
    mov bp,sp

    push bx     
    push si           
    push cx   
    push ax    

    xor si,si                   ; si - cols
    xor bx,bx                   ; bx - rows

    xor cx,cx
    mov cl,byte ptr [rows]      ; EXTERNAL loop : for i in range (0, rows_amount)

EXTERNAL_FOR_PRINT:
    push cx 
    xor cx,cx
    mov cl,byte ptr [cols]
    
    INTERNAL_FOR_PRINT:         ; INTERNAL loop : for j in range (0, cols_amount)
        mov al, byte ptr matrix[bx][si]
        bin_to_ASCII
        inc si
    loop LABEL8
    jmp LABEL9
LABEL8:
    jmp INTERNAL_FOR_PRINT
LABEL9:
    inc bx
    pop cx
loop LABEL10
    jmp LABEL11
LABEL10:
    jmp EXTERNAL_FOR_PRINT
LABEL11:

    pop ax
    pop cx 
    pop si 
    pop dx

    mov sp,bp
    pop bp 
    ret
endp print_string

search proc                          
    push bp                    
    mov bp,sp

    push bx     
    push si           
    push cx   
    push ax    

    xor si,si                   ; si - cols
    xor bx,bx                   ; bx - rows

    xor cx,cx
    mov cl,byte ptr [rows]      ; EXTERNAL loop : for i in range (0, rows_amount)
    mov al, matrix[bx][si]
    mov byte ptr [greatest_element], al ; greatest_element = matrix[0][0]
    mov byte ptr [sum], 2h              ; sum = 2

EXTERNAL_FOR_SEARCH:
    push cx 
    xor cx,cx
    mov cl,byte ptr [cols]
    
    INTERNAL_FOR_SEARCH:         ; INTERNAL loop : for j in range (0, cols_amount)
        mov al,byte ptr [greatest_element]
        cmp byte ptr matrix[bx][si],al ; if(matrix[i][j] >= greatest_element) then goto SUM_CMP
        jg NEW_SUM_FOR_NOT_EQUALS
        cmp byte ptr matrix[bx][si],al  
        je SUM_CMP
        jmp END_OF_SUM_CMP
    SUM_CMP:
        xor ax,ax
        mov ax,si
        div byte ptr [rows]           
        shr ax,8
        add ax,bx                                 
        add ax,2h
        cmp al,byte ptr [sum]
        jl NEW_SUM_FOR_EQUALS      
        jmp END_OF_SUM_CMP
    NEW_SUM_FOR_EQUALS:
        mov byte ptr [sum],al
        jmp END_OF_SUM_CMP
    NEW_SUM_FOR_NOT_EQUALS:
        xor ax,ax
        mov ax,si
        div byte ptr [rows]           
        shr ax,8
        add ax,bx                                 
        add ax,2h
        mov byte ptr [sum],al
        mov al, byte ptr matrix[bx][si] 
        mov byte ptr [greatest_element], al
    END_OF_SUM_CMP:
        inc si
    loop LABEL12
    jmp LABEL13
LABEL12:
    jmp INTERNAL_FOR_SEARCH
LABEL13:
    inc bx
    pop cx
loop LABEL14
    jmp LABEL15
LABEL14:
    jmp EXTERNAL_FOR_SEARCH
LABEL15:

    pop ax
    pop cx 
    pop si 
    pop dx

    mov sp,bp
    pop bp 
    ret
endp search

START:
    mov ax,@data
    mov ds,ax

    lea dx,message_in_rows
    output_str

    input_proc

    lea dx,crlf
    output_str

    mov byte ptr [rows],al

    check_for_illegal_rows

    lea dx,message_in_cols
    output_str

    input_proc

    lea dx,crlf
    output_str

    mov byte ptr [cols],al    

    check_for_illegal_cols 

    call filling_of_matrix     

    call search

    lea dx,message_res
    output_str

    mov al,byte ptr [sum]
    bin_to_ASCII
    

END_OF_PR:
    MOV ax,4C00h
    INT 21h
END START