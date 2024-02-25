.model tiny
.code
.186
org 100h

include dosfunc.asm
;-------------------------
;main
;-------------------------
; Stack in func
; [bp + 10] - height of frame
; [bp + 8]  - width of frame
; [bp + 6]  - color of frame and text syms
; [bp + 4]  - address of array
; [bp + 2]  - address of text first sym
; [bp]      - address for ret
;
;-------------------------
Start:
        mov bx, VIDEOSEG
	mov es, bx

        mov si, CMDARGS
        inc si

;----height of frame----
        call ReadDecNum
        push bx

;----width of frame----
        call ReadDecNum
        push bx

;----color of frame and text syms----
        call ReadHexNum
        push bx

;----address of array----
        push si
        call ReadArr
        pop di

;----address of text first sym----
        add di, ax
        push si
        mov si, di
        push di
        
        call PrintFrame

        call WriteText

        ExitDos


;-------------------------
; ReadDecNum
;
; Calls a function that reads dec digits from the command 
; line and combines them into a number
;
; Entry: SI - Addr of sym in command line
; Destr: AX - Digit from func
;        BX - Dec number
;        DX - Symbol from command line
; Exit:  BX
;-------------------------
ReadDecNum proc
        mov bx, 0
        mov ax, 0

;----while loop----
@@if_dec:
        add bx, ax

        inc si
        mov dx, [si]
        cmp dl, ' '
        jne @@loop_dec

        ret

@@loop_dec:
        mov ax, 10d
	mul bx
	mov bx, ax

        call ReadDecDig

        cmp ax, 10d
        jb @@if_dec

;----error if input value is not dec num----
        ErrorExit 
        
        endp


;-------------------------
; ReadHexNum
;
; Calls a function that reads hex digits from the command 
; line and combines them into a number
;
; Entry: SI - Addr of sym in command line
; Destr: AX - Digit from func
;        BX - Hex number
;        DX - Symbol from command line
; Exit:  BX
;-------------------------
ReadHexNum proc
        mov bx, 0
        mov ax, 0

;----while loop----
@@if_dechex:
        add bx, ax

        inc si
        mov dx, [si]
        cmp dl, ' '
        jne @@loop_dechex

        ret

@@loop_dechex:
        mov ax, 10h
	mul bx
	mov bx, ax

        call ReadDecDig

        cmp ax, 10d
        jb @@if_dechex

        call ReadHexDig

        cmp ax, 16d
        jb @@if_dechex

;----error if input value is not hex num----
        ErrorExit

        endp


;-------------------------
; ReadDecDig
;
; Read a symbol from the command line and turns 
; it into a dec number
;
; Entry: SI - Addr of sym in command line
; Destr: AX - Digit from command line
; Exit:  AX
;-------------------------
ReadDecDig  proc
        mov ax, [si]
	sub al, 30h
	mov ah, 0

        ret
        endp


;-------------------------
; ReadHexDig
;
; Read a symbol from the command line and turns 
; it into a hex number
;
; Entry: SI - Addr of sym in command line
; Destr: AX - Digit from command line
; Exit:  AX
;-------------------------
ReadHexDig  proc
        mov ax, [si]
	sub al, 61h
	mov ah, 0
        add ax, 10d

        ret
        endp


;-------------------------
; ReadArr
;
; Reads from the command line a digit - the array number 
; or a sequence of 9 symbol starting with USERARRAY
;
; Entry: SI - Addr of sym in command line
; Destr: AX - Length of command line of array part
;        DX - Symbol from command line
; Exit:  SI, AX
;-------------------------
ReadArr proc
        inc si
        mov dx, [si]

        cmp dl, USERARRAY
        je @@arr_input

        cmp dl, ONE
        je @@arr_one

        cmp dl, TWO
        je @@arr_two

;----error if input value is not array num or USERARRAY----
        ErrorExit

@@arr_input:
        inc si
        mov ax, 12d

        ret
         
@@arr_one:
        mov si, offset ControlStrArray1
        mov ax, 3d

        ret

@@arr_two:
        mov si, offset ControlStrArray2
        mov ax, 3d

        ret

        endp


;-------------------------
; PrintFrame
;
; Print frame columns using the line symbol print function
; and print shadow
;
; Entry: SI - Addr of syms in array
;        SP - Addr of last value in stack
; Destr: AH - Color of frame symbols
;        BP - Addr of last value in stack
;        CX - Number of repetitions of the line
;        DI - Line printing start point
; Exit:  -
;-------------------------
PrintFrame proc
        mov bp, sp

        mov cx, [bp+10]
        cmp cx, 2d
        sub cx, 1
        push cx
        jg @@print_frame

;----error if height of frame <2----
        ErrorExit

@@print_frame:
        mov si, [bp+4]
        mov ah, [bp+6]
        mov di, STARTPOINT
        mov cx, [bp+10]
        
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
        mov ah, SHADOWclr
        mov al, SHADOWSym

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
        mov cx, [bp + 8]
        cmp cx, 1d
        jg @@first_sym

;----error if width of frame <2----
        ErrorExit

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
; WriteText
;
; Print text into a frame from the command line
;
; Entry: SP - Addr of last value in stack
; Destr: AX - Symbol for print
;        BP - Addr of last value in stack 
;        CX - Text length
;        DI - Printing point
; Exit:  -
;-------------------------
WriteText proc
        mov bp, sp

        mov si, CMDARGS
        mov cx, [si]
        mov ch, 0
        add cx, si
        mov ax, [bp+2]
        sub cx, ax
        inc cx

        mov di, [bp+10]
        imul di, 80d
        add di, STARTPOINT + 2

        mov ah, [bp+6]
        mov si, [bp+2]

        cmp cx, 0ffffh
        jne @@print_loop

        ret

@@print_loop:
        sub cx, 1
        lodsb
        stosw

        cmp cx, 0
        jne @@print_loop

        ret
        endp


;-------------------------
; PrintErrorFrame
;
; Func for printing frame when input error detected
;
; Entry: -
; Destr: SI - Addr of syms in error array
;        AX - Symbol for print
;        BP - Addr of last value in stack 
;        CX - 1. Number of line 2. Number of repetitions of syms
;        DI - Error printing point
; Exit:  -
;-------------------------
PrintErrorFrame proc
        mov di, EROORPOINT
        mov si, offset ErrorStrArray
        mov ah, 0eh
        push 3d

@@print_new_line:
        mov cx, 6d
        add di, 148d

@@error_line:
        push cx

        mov cx, 1d
        PrintSyms

        PopcxAndCmp
        jne @@error_line

        PopcxAndCmp
        push cx
        jne @@print_new_line

        ret
        endp


;-------------------------
;ARRAYS
;-------------------------
ControlStrArray1:
  db 0C9h, 0CDh, 0BBh
  db 0BAh, 020h, 0BAh
  db 0C8h, 0CDh, 0BCh

ControlStrArray2:
  db 0DAh, 0CAh, 0BFh
  db 0C3h, 0C5h, 0B4h
  db 0C0h, 0C1h, 0D9h

ErrorStrArray:
  db 045h, 052h, 052h, 04Fh, 052h, 053h
  db 0B3h, 020h, 03Ah, 028h, 020h, 0B3h
  db 045h, 052h, 052h, 04Fh, 052h, 053h
;-------------------------

end start