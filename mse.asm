; Procedures to compute:
; - Squared error for a single feed forward
; - Derivative of squared error (gradient)
; - Mean Squared Error

.data

flzero  REAL4 0.0
flone   REAL4 1.0
fltwo   REAL4 -2.0        

sse REAL4 0.0   
gradient REAL4 0.0   

destination REAL4 0.0
current_sum REAL4 0.0

twom  DWORD 0
currentIndex DWORD 0
endIndex DWORD 0
example_x DWORD 0



.code



compute_se PROC      ; compute se  =  [y-yhat]^2 
 ; esi <- y
 ; edi <- yhat
 ; SE -> current_sum memory buffer 


 fld flzero           ; Clear memory buffers in case they have been set already
 fstp destination
 fld flzero
 fstp current_sum
 fld flzero
 fstp sse
 fld flzero
 fstp currentIndex

 ; Load y and yhat for current index
 fld REAL4 PTR [esi]
 fld REAL4 PTR [edi]
 fsub                 ; compute y-yhat
 fstp sse
 fld sse
 fld st(0)            ; duplicate the result on the FPU stack
 fmul                 ; compute (y-yhat)^2

 ; Add the se for current training example to sum
 fadd current_sum
 fstp current_sum
 
ret
compute_se ENDP

compute_dse PROC
 ; eax <-- Value of x[i] (current training example)
 ; ebx <-- are we calcing deriv w.r.t bias or weight? 0 = bias 1 = weight
 ; gradient --> gradient memory buffer
 

 fld flzero
 fstp gradient    ; reset gradient memory buf

 fld fltwo
 fld sse          ; -2*squared_error
 fmul
 fstp gradient

 cmp ebx, 0       ; If we are computing deriv w.r.t
 je fin           ; bias, we skip the next steps

 fld gradient
 fld REAL4 PTR [eax]
 fmul
 fstp gradient

fin:
 
 ret
compute_dse ENDP

compute_mse PROC          ; compute (1/2m)*(sse) where sse = sum( [y-yhat]^2 ) over all examples
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

  imul ebx, ebx, 2    ; compute 2m
  mov twom, ebx

  finit
  fld flone
  fild twom
  fdiv                ; compute 1/2m
  fld current_sum
  fmul                ; compute (1/2m)*(sse) where sse = sum( [y-yhat]^2 ) over all examples
  fstp current_sum    ; store the final MSE
  

 ret
compute_mse ENDP
