; Computes yhat = wx + b for a training example x
.data

yhat REAL4 0.0  ; Value of wx+b

.code

feed_forward PROC ; Feed forward for a single training example
; lea eax <-- x             Memory addresses need to be loaded because registers cannot store REAL4 
; lea ebx <-- w
; lea ecx <-- b
; yhat/ypred --> yhat


 fld real4 ptr [eax]
 fmul real4 ptr [ebx]
 fadd real4 ptr [ecx]
 fstp yhat

 ret
feed_forward ENDP