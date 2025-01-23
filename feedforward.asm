; Computes yhat = wx + b for a training example x
include \masm32\include\masm32rt.inc

.data

x DWORD 0
w DWORD 0
b DWORD 0
yhat DWORD 0 

.code

start:

feedforward PROC ; Feed forward for a single training example
; eax <-- x
; ebx <-- w
; ecx <-- b
; yhat/ypred --> yhat

 mov x, eax
 mov w, ebx
 mov b, ecx

 fild w
 fild w
 fmul
 fild b
 fadd
 fstp yhat

 ret
feedforward ENDP

end start