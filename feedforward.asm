; Computes yhat = wx + b for a training example x
include \masm32\include\masm32rt.inc

.data

x REAL4 0.0
w REAL4 0.0
b REAL4 0
yhat REAL4 0 

.code

start:

feedforward PROC ; Feed forward for a single training example
; lea eax <-- x             Memory addresses need to be loaded because registers cannot store REAL4 
; lea ebx <-- w
; lea ecx <-- b
; yhat/ypred --> yhat

 mov x, eax
 mov w, ebx
 mov b, ecx

 fld w
 fld x
 fmul
 fld b
 fadd
 fstp yhat

 ret
feedforward ENDP

end start