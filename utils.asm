; Procedures irrelevant to the Linear Regression algorithm

.data
bufferfloatascii db 256 DUP(0)       ; Buffer to hold formatted string
floatqword QWORD 0
space db " ",0

floattempbuf REAL4 0.0


prng_x  DD 0 ; calculation state
prng_a  DD 1099433 ; current seed
randnum DD 0
randfloat REAL4 0.0

.code

printfloat PROC
; eax <-- float

; Convert REAL4 current_sum to QWORD
    fld real4 ptr [eax]
    fstp floatqword       ; Store the REAL4 value into the QWORD buffer

    ; Use FloatToStr to convert floatqword to a string
    invoke FloatToStr,floatqword , ADDR bufferfloatascii 

    ; Print the ASCII result to stdout
    invoke StdOut, addr bufferfloatascii 
    
    invoke StdOut, offset space
    ret

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

fPrngGet PROC range:DWORD ; Generate a pseudo-random floating point number in range 0,range
    ; Returns eax = memory address of floating point pseudorandom number

    ; count the number of cycles since
    ; the machine has been reset
    invoke GetTickCount

    ; accumulate the value in eax and manage
    ; any carry-spill into the x state var
    adc eax, edx
    adc eax, prng_x

    ; multiply this calculation by the seed
    mul prng_a

    ; manage the spill into the x state var
    adc eax, edx
    mov prng_x, eax

    ; put the calculation in range of what
    ; was requested
    mul range

    ; ranged-random value in eax
    mov eax, edx
    mov randnum, eax
    fild randnum   ; load rand int in range onto fpu
    fstp randfloat ; store it as floating point in memory

    mov eax, prng_a
    inc eax ; increment the seed
    mov prng_a, eax
    
    lea eax, randfloat
    ret

fPrngGet ENDP