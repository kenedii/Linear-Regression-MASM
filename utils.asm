; Procedures irrelevant to the Linear Regression algorithm

.data
bufferfloatascii db 256 DUP(0)       ; Buffer to hold formatted string
floatqword QWORD 0
space db " ",0

.code

printfloat PROC
; eax <-- float

; Convert REAL4 current_sum to QWORD
    fld [eax]
    fstp floatqword       ; Store the REAL4 value into the QWORD buffer


    ; Use FloatToStr to convert current_sum to a string
    invoke FloatToStr,floatqword , ADDR bufferfloatascii 

    ; Print the ASCII result to stdout
    invoke StdOut, ADDR buffer
    
    invoke StdOut, offset space

printfloat ENDP

to_string PROC
; eax <-- integer
; lea edi <-- buffer to store ascii in

 mov ebx, 10
 xor ecx, ecx

repeated_division:
 xor edx, edx
 div ebx
 push dx
 add cl,1
 or eax,eax
 jnz repeated_division

load_digits:
 pop ax
 or al, 00110000b ; transforms to ascii
 stosb  ; store al into edi. edi = pointer to buffer
 loop load_digits
 mov byte ptr [edi], 0
 ret

to_string ENDP