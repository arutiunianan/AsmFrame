.model tiny
.code
.386
org 100h

include dosfunc.asm


Start:

    mov ax, 3500h or INT09H
    int 21h

    mov word ptr Old09, bx
    mov bx, es
    mov word ptr Old09 + 2, bx
    push 0
    pop es
    mov bx, 4 * INT09H

    cli

    mov word ptr es:[bx], offset New09
    push cs
    pop ax
    mov word ptr es:[bx + 2], ax

    sti

    mov ax, 3500h or INT08H
    int 21h

    mov word ptr Old08, bx
    mov bx, es
    mov word ptr Old08+ 2, bx
    push 0
    pop es
    mov bx, 4 * INT08H

    cli

    mov word ptr es:[bx], offset New08
    push cs
    pop ax
    mov word ptr es:[bx + 2], ax

    sti

    mov ax, 3100h
    mov dx, offset EOP

    shr dx, 4
    inc dx

    int 21h


ControlStrArray01:
  db 0C9h, 0CDh, 0BBh
  db 0BAh, 020h, 0BAh
  db 0C8h, 0CDh, 0BCh


New09   proc
    push es ds sp bp di si dx cx bx ax

    push cs
	pop ds

    in al, 60h

    cmp al, 11d  ;UPBUTTON
    je @@open_frame

;    cmp al, 10d  ;DOWNBUTTON
;    jne @@close_frame

    jmp @@exit09

@@open_frame:
    not cs:IsFrameOpen 

    in al, 61h
	or al, 80h
	out 61h, al				
	and al, not 80h		
	out 61h, al
	mov al, 20h				
	out 20h, al

    jmp @@exit09

;@@close_frame:
;    not cs:IsFrameOpen

@@exit09:
    pop ax bx cx dx si di bp sp ds es

db  0EAh
Old09    dd 0
    endp


New08   proc
    push es ds sp bp di si dx cx bx ax

    push cs
	pop ds    

    cmp IsFrameOpen, 00h
    je @@exit08

@@print_reg:

    mov bx, VIDEOSEG
	mov es, bx
    mov bx, offset ControlStrArray01  ;---

    push 4d 18d 04eh bx 9d
    call PrintFrame
    add sp, 10

    push 04e03h
    call PrintReg
    add sp, 2

@@exit08:
    
    pop ax bx cx dx si di bp sp ds es
    
db  0EAh
Old08    dd 0
    endp


PrintFrame proc
        push bp
        mov bp, sp

        mov cx, [bp+12]
        sub cx, 1
        push cx

@@print_frame:
        mov si, [bp+6]
        mov ah, [bp+8]
        mov di, STARTPOINT
        mov cx, [bp+12]
        
@@first_line:
        call PrintLine

@@middle_line:
        PopcxAndCmp
        je @@last_line
        push cx

        NewLineFrame di
        call PrintLine

        sub si, 3d
        jmp @@middle_line
        
@@last_line:
        add si, 3d

        NewLineFrame di
        call PrintLine

;----shadow print----
        mov di, STARTPOINT
        add di, [bp + 10]
        add di, [bp + 10]
        mov cx, [bp + 12]
        mov ah, SHADOWclr
        mov al, SHADOWSym

@@print_shadow:
        add di, 160
        mov es:[di], ax
        sub cx, 1

        cmp cx, 0
        jne @@print_shadow
        
        mov di, [bp + 12]
        imul di, 160
        add di, STARTPOINT + 2
        mov cx, [bp + 10]
        rep stosw

        pop bp
        ret
        endp


;-------------------------
; PrintLine
;
; Extract symbols from an array and prints a string of them
;
; Entry: SI - Addr of sym in command line
;        DI - Line start point
; Destr: AX - Symbol for print
;        BP - Addr of last value in stack before func 
;        CX - Number of repetitions of syms
;        DI - Printing point
; Exit:  -
;-------------------------
PrintLine proc
        mov cx, [bp + 10]


@@first_sym:
        mov cx, 1d
        PrintSyms

@@middle_sym:  
        mov cx, [bp + 10]
        cmp cx, 2d
        inc si
        je @@last_sym

        sub cx, 2
        sub si, 1
        cld
        PrintSyms

@@last_sym:
        mov cx, 1d
        PrintSyms

        ret
        endp


PrintReg    proc
    push bp
    mov bp, sp

    mov si, offset RegArray
    mov ah, 04eh
    mov di, STARTREGPOINT
    mov cx, 1d

@@print_regs:
    push cx

    mov cx, 4
@@print_regs_name:
    push cx
    mov cx, 1
    PrintSyms
    PopcxAndCmp
    jne @@print_regs_name

    pop cx
    push cx
    add bp, cx
    add bp, cx
    add bp, 2d
    mov ax, [bp]
    sub bp, cx
    sub bp, cx
    mov cx, 0d
@@get_nums:
    call HexToStr
    push dx
    inc cx
    cmp cx, 4h
    jne @@get_nums
@@print_nums:
    pop dx
    mov es:[di], dx
    add di, 2
    sub cx, 1
    cmp cx, 0h
    jne @@print_nums


    add di, 152d

    PopcxAndCmp
    jne @@print_regs

    pop bp
    ret
    endp 



HexToStr    proc
    push bp
    mov bp, sp
    mov bx, 010h

@@get_num:
    mov dx, 0
    div bx
    cmp dx, 10d
    jb @@if_dec
    jmp @@if_hex

@@if_dec:
	add dl, 30h
	mov dh, 04eh
    pop bp
    ret

@@if_hex:
    add dl, 37h
	mov dh, 04eh
    pop bp
    ret
    endp




IsFrameOpen db 0h



RegArray:	
    db 'AX: '
	db 'BX: '
	db 'CX: '
	db 'DX: '
	db 'SI: '
	db 'DI: '
	db 'BP: '
	db 'SP: '
	db 'DS: '
	db 'ES: '
	db 'SS: '
	db 'IP: '
	db 'CS: '

EOP:
end Start