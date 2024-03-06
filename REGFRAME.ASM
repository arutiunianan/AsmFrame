.model tiny
.code
.386
org 100h

FRAMEHEIGHT = 15d
FRAMEWIDTH  = 28d
FRAMECOLOR  = 04eh

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

include dosfunc.asm

;-------------------------
;
; Stack in func
; [bp + 10] - height of frame                   
; [bp + 8]  - width of frame                    
; [bp + 6]  - color of frame and text syms      
; [bp + 4]  - Addressess of array                
; [bp + 2]  - Saved bp value     
; [bp]      - Addressess for ret
;
;-------------------------

New09   proc
    push es ds sp bp di si dx cx bx ax

    push cs
	pop ds

    in al, 60h

    cmp al, 11d         ;0 button
    je @@open_frame

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
@@exit09:
    pop ax bx cx dx si di bp sp ds es

db  0EAh
Old09    dd 0
    endp

;-------------------------
;
; Stack in func
; [bp + 28] - CS            
; [bp + 26] - IP              
; [bp + 24] - SS 
; [bp + 22] - ES   
; [bp + 20] - DS
; [bp + 18] - SP            
; [bp + 16] - BP              
; [bp + 14] - DI 
; [bp + 12] - SI   
; [bp + 10] - DX                   
; [bp + 8]  - CX                    
; [bp + 6]  - BX      
; [bp + 4]  - AX                
; [bp + 2]  - Saved bp value    
; [bp]      - Addressess for ret
;
;-------------------------

New08   proc
    push ss es ds sp bp di si dx cx bx ax

    push cs
	pop ds

    cmp IsFrameOpen, 00h
    je @@exit08

@@print_reg:
    mov bx, VIDEOSEG
	mov es, bx
    mov bx, offset ControlStrArray01  ;---

    push FRAMEHEIGHT FRAMEWIDTH FRAMECOLOR bx
    call PrintFrame
    add sp, 8

    call PrintReg

@@exit08:
    
    pop ax bx cx dx si di bp sp ds es
    add sp, 2
    
db  0EAh
Old08    dd 0
    endp

;-------------------------
; PrintFrame
;
; Print frame columns using the line symbol print function
; and print shadow
;
; Entry: SI - Address of syms in array
;        SP - Address of last value in stack
; Destr: AH - Color of frame symbols
;        BP - Addressуыы of last value in stack
;        CX - Number of repetitions of the line
;        DI - Line printing start point
; Exit:  -
;-------------------------

PrintFrame proc
        push bp
        mov bp, sp

        mov cx, [bp + 10]
        sub cx, 1
        push cx

@@print_frame:
        mov si, [bp + 4]
        mov ah, [bp + 6]
        mov di, STARTPOINT
        mov cx, [bp + 10]
        
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
        add di, [bp + 8]
        add di, [bp + 8]
        mov cx, [bp + 10]
        mov ah, SHADOWCLR
        mov al, SHADOWSYM

@@print_shadow:
        add di, 160
        mov es:[di], ax
        sub cx, 1

        cmp cx, 0
        jne @@print_shadow
        
        mov di, [bp + 10]
        imul di, 160
        add di, STARTPOINT + 2
        mov cx, [bp + 8]
        rep stosw

        pop bp
        ret
        endp

;-------------------------
; PrintLine
;
; Extract symbols from an array and prints a string of them
;
; Entry: SI - Addressess of sym in command line
;        DI - Line start point
; Destr: AX - Symbol for print
;        BP - Addressess of last value in stack before func 
;        CX - Number of repetitions of syms
;        DI - Printing point
; Exit:  -
;-------------------------
PrintLine proc
        mov cx, [bp + 8]


@@first_sym:
        mov cx, 1d
        PrintSyms

@@middle_sym:  
        mov cx, [bp + 8]
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

;-------------------------
; PrintReg
;
; Print the register name and its value to the
;
; Entry: SP - Addressess of last value in stack
;        DI - Line start point
;        SI - Address of syms in array
; Destr: DX - Symbol for print
;        BP - Address of last value in stack before func 
;        CX - Number of repetitions
;        DI - Printing point
; Exit:  -
;-------------------------

PrintReg    proc
    push bp
    mov bp, sp
    add bp, 2d

    mov si, offset RegArray
    mov di, STARTREGPOINT
    mov cx, 0d

@@print_regs:
    mov ah, 04eh
    push cx

    mov cx, 4
@@print_regs_name:
    push cx
    mov cx, 1
    PrintSyms
    PopcxAndCmp
    jne @@print_regs_name

    add bp, 2d
    mov ax, [bp]
    
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

    add di, 144d

    pop cx
    add cx, 1
    cmp cx, NUMOFREGS
    jne @@print_regs

    pop bp
    ret
    endp 



; If the frame is open meaning   - 0FFh
; if the frame is closed meaning - 00h
IsFrameOpen db 0h 


ControlStrArray01:
  db 0C9h, 0CDh, 0BBh
  db 0BAh, 020h, 0BAh
  db 0C8h, 0CDh, 0BCh

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