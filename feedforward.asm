; Computes yhat = wx + b for a training example x
.data

trx REAL4 0.0 ; value of training example x
pw REAL4 0.0  ; Parameter W
pb REAL4 0.0  ; Parameter B
yhat REAL4 0.0  ; Value of wx+b

.code

feed_forward PROC ; Feed forward for a single training example
; lea eax <-- x             Memory addresses need to be loaded because registers cannot store REAL4 
; lea ebx <-- w
; lea ecx <-- b
; yhat/ypred --> yhat

 mov trx, eax
 mov pw, ebx
 mov pb, ecx

 fld pw
 fld trx
 fmul
 fld pb
 fadd
 fstp yhat

 ret
feed_forward ENDP