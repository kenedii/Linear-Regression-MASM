include \masm32\include\masm32rt.inc

.data
 result  REAL8 0.0
 X   REAL4 -1.0, 1.2, 2.3, 3.4, 4.567, 0.0
            SDWORD -1               ; End of array -> NaN
 Y REAL4 -3.0, 1.7, 2.3, 13.4, 4.567, 0.2
            SDWORD -1               ; End of array -> NaN
 Yhat REAL4 -6.0, -1.9, 12.3, 3.4, 4.564, 0.5
            SDWORD -1               ; End of array -> NaN         

hi  REAL4 3.14
bye REAL4 2.71

destination REAL4 0.0
current_sum REAL4 0.0

currentIndex dd 0
endIndex dd 0

formatString BYTE "%f", 0    ; Format string for floating-point output
buffer BYTE 256 DUP(0)       ; Buffer to hold formatted string


.code

start:

 mov esi, OFFSET Y    ; true y
 mov edi, OFFSET Yhat ; pred y
 mov ebx, 5           ; # of elements in array
 call compute_mse

 ; Convert REAL4 to string
 invoke sprintf, ADDR current_sum, ADDR formatString, current_sum

 ; Print the string to stdout
 invoke StdOut, ADDR buffer



compute_mse PROC
 ; esi <- pointer to y[0]
 ; edi <- pointer to yhat[0]
 ; ebx <- # of training examples (m)
 ; MSE -> current_sum memory buffer 

 mov endIndex, ebx


loopy: ; compute squared error for every item in the array
 mov eax, currentIndex
 mov ebx, endIndex
 cmp eax, ebx ; check if we reached the end of array
 jge finish_mse ; if we did, finish up the mse computation

 ; Load y and yhat for current index
 fld REAL4 PTR [esi + eax*4]
 fld REAL4 PTR [edi + eax*4]
 fsub                 ; compute y-yhat
 fld st(0)            ; duplicate the result on the FPU stack
 fmul                 ; compute (y-yhat)^2

 ; Add the se for current training example to sum
 fadd current_sum
 fstp current_sum

 inc currentIndex     ; Increment the current index by one
 jmp loopy            ; Continue the loop
 
 

 finish_mse: ; Multiply 1/2m by the sse
  mov ebx, endIndex

  imul ebx, 2 ; compute 2m

  finit
  fld ebx
  fld 1.0
  fdiv ; compute 1/2m
  fld current_sum
  fmul ; compute (1/2m)*(sse) where sse = sum( [y-yhat]^2 ) over all examples
  fstp current_sum ; store the final SSE
  

 ret
compute_mse ENDP

end start