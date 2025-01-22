include \masm32\include\masm32rt.inc

.data
 twom  DWORD 0
 flzero  REAL4 0.0
 flone   REAL4 1.0
 X   REAL4 -1.0, 1.2, 2.3, 3.4, 4.567, 0.0
            SDWORD -1        ; End of array -> NaN
 Y REAL4 -3.0, 1.7, 2.3, 13.4, 4.567, 0.2
            SDWORD -1        
 Yhat REAL4 -6.0, -1.9, 12.3, 3.4, 4.564, 0.5
            SDWORD -1          

sse REAL4 0.0      

destination REAL4 0.0
current_sum REAL4 0.0

currentIndex DWORD 0
endIndex DWORD 0

formatString BYTE "%f", 0    ; Format string for floating-point output
buffer db 256 DUP(0)       ; Buffer to hold formatted string

current_sum_qword QWORD 0 ; QWORD buffer for FloatToStr

newline db " ",13,10,0

.code

start:

 mov esi, OFFSET Y           ; true y
 mov edi, OFFSET Yhat        ; pred y
 mov ebx, 6                  ; # of elements in array-1
 call compute_mse

; Convert REAL4 current_sum to QWORD
    fld current_sum
    fstp current_sum_qword      ; Store the REAL4 value into the QWORD buffer


    ; Use FloatToStr to convert current_sum to a string
    invoke FloatToStr, current_sum_qword, ADDR buffer

    ; Print the ASCII result to stdout
    invoke StdOut, ADDR buffer

; Convert REAL4 current_sum to QWORD
    fld sse
    fstp current_sum_qword      ; Store the REAL4 value into the QWORD buffer


    ; Use FloatToStr to convert current_sum to a string
    invoke FloatToStr, current_sum_qword, ADDR buffer

    ; Print the ASCII result to stdout
    invoke StdOut, ADDR buffer

    ; Wait for user input before exiting
    invoke StdIn, OFFSET buffer, 256
    ret



compute_mse PROC
 ; esi <- pointer to y
 ; edi <- pointer to yhat
 ; ebx <- # of training examples (m)
 ; MSE -> current_sum memory buffer 

 fld flzero           ; Clear memory buffers in case they have been set already
 fstp destination
 fld flzero
 fstp current_sum
 fld flzero
 fstp sse
 fld flzero
 fstp currentIndex

 mov endIndex, ebx


loopy:                ; compute squared error for every item in the array
 mov eax, currentIndex
 mov ebx, endIndex
 cmp eax, ebx         ; check if we reached the end of array
 jge finish_mse       ; if we did, finish up the mse computation

 ; Load y and yhat for current index
 fld REAL4 PTR [esi + eax*4]
 fld REAL4 PTR [edi + eax*4]
 fsub                 ; compute y-yhat
 fld st(0)            ; duplicate the result on the FPU stack
 fmul                 ; compute (y-yhat)^2

 ; Add the se for current training example to sum
 fadd current_sum
 fstp current_sum

 mov eax, currentIndex
 inc eax              ; Increment the current index by one
 mov currentIndex, eax
 jmp loopy            ; Continue the loop
 
 

 finish_mse:          ; Multiply 1/2m by the sse
  fld current_sum
  fstp sse            ; Store the sse in memory (we need it for Derivative during Gradient Descent)

  imul ebx, ebx, 2    ; compute 2m
  mov twom, ebx

  finit
  fld flone
  fild twom
  fdiv                ; compute 1/2m
  fld current_sum
  fmul                ; compute (1/2m)*(sse) where sse = sum( [y-yhat]^2 ) over all examples
  fstp current_sum    ; store the final SSE
  

 ret
compute_mse ENDP

end start