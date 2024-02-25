
;------------------------
;MACROS
;------------------------
NewLineFrame macro reg
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

;-------------------------
;CONSTANTS
;-------------------------

VIDEOSEG   = 0b800h     ; -  VIDEOSEG textmode
CMDARGS    = 80h        ; - syms in cmd line , 82h - first symbol in cmd params
STARTPOINT = 320d       ; - upper left frame corner
EROORPOINT = 3052d      ; - upper left error frame corner
ONE        = 31h        ; - '1' ASCII 
TWO        = 32h        ; - '2' ASCII 
SHADOWSym  = 20h        ; - (' ' ASCII)
SHADOWclr  = 70h
USERARRAY  = 2ah        ; - start sym of user array

;------------------------
