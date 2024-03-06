.model tiny
.code
.286
org 100h


Start:
    mov ax, cs
    call PutCsValue

    mov ah, 09h
    mov dx, offset CsStr
    int 21h

Loop:
    mov ax, 1111h
    mov bx, 2222h
    mov cx, 3333h
    mov dx, 4444h
    mov si, 5555h
    mov di, 6666h

    in al, 60h
    cmp al, 10d        ;9 button
    jne Loop
    ret
    include dosfunc.asm

;-------------------------
; PutCsValue
;
; Put the cs register value to be printed into an CsStr array 
;
; Entry: AX - CS value
; Destr: DL - Digits ASCII code
;        BX - Address of elements in CsStr array
;        CX - Number of repetitions
; Exit:  CsStr
;-------------------------

PutCsValue proc
    push bx
    mov cx, 0d

@@get_digs:
    call HexToStr
    push dx
    inc cx
    cmp cx, 4h
    jne @@get_digs

    mov bx, offset CsStr
    add bx, 4
@@print_digs:
    pop dx
    mov [bx], dl
    
    inc bx
    sub cx, 1
    cmp cx, 0h
    jne @@print_digs

    pop bx
    ret
    endp


CsStr db 'cs: 0000$'

end Start