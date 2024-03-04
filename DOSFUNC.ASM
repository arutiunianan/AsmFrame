
;------------------------
;MACROS
;------------------------
NewLineFrame macro reg ;len
        add reg, 160
        ;sub reg, [bp + 8]
        ;sub reg, [bp + 8]
        sub reg, [bp + 10]
        sub reg, [bp + 10]
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
STARTPOINT    = 800d       ; - upper left frame corner
STARTREGPOINT = STARTPOINT + 160d + 4d
EROORPOINT    = 3052d      ; - upper left error frame corner
ONE           = 31h        ; - '1' ASCII 
TWO           = 32h        ; - '2' ASCII 
SHADOWSym     = 20h        ; - (' ' ASCII)
SHADOWclr     = 70h
USERARRAY     = 2ah        ; - start sym of user array
INT08H        = 08h
INT09H        = 09h

;------------------------
