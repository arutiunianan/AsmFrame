;------------------------
; HexToStr
;
; Converts a number to another containing the color 
; of the symbol and ASCII code of the number
;
; Entry: AX - Hexadecimal number
; Destr: DX - Redesigned symbol for printing
;        BP - Address of the last stack element
; Exit:  DX
;------------------------
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

;------------------------
;MACROS
;------------------------
NewLineFrame macro reg ;len
    add reg, 160
    sub reg, [bp + 8]
    sub reg, [bp + 8]
endm


PrintSyms macro
    lodsb
    rep stosw
endm

PopcxAndCmp  macro
    pop cx
    sub cx, 1
    cmp cx, 0d
endm

ExitDos macro
    mov ax, 4c00h
    int 21h
endm

ErrorExit macro
    call PrintErrorFrame 
    ExitDos
endm

;-------------------------
;CONSTANTS
;-------------------------

VIDEOSEG      = 0b800h     ; - VIDEOSEG textmode
CMDARGS       = 80h        ; - syms in cmd line , 82h - first symbol in cmd params
STARTPOINT    = 880d       ; - upper left frame corner
STARTREGPOINT = STARTPOINT + 164d
EROORPOINT    = 3052d      ; - upper left error frame corner
ONE           = 31h        ; - '1' ASCII 
TWO           = 32h        ; - '2' ASCII 
SHADOWSYM     = 20h        ; - (' ' ASCII)
SHADOWCLR     = 70h        ; - (GREY)
USERARRAY     = 2ah        ; - start sym of user array
INT08H        = 08h
INT09H        = 09h
NUMOFREGS     = 13d        ; Number of registers

;------------------------
