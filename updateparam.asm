; Updates parameters w and b
; By using learning rate and gradient
include \masm32\include\masm32rt.inc

.data

x DWORD 0
w DWORD 0
b DWORD 0


update_size REAL4 0.0
flzero REAL4 0.0
new_w REAL4 0.0
new_b REAL4 0.0


.code

start:

update_weight PROC
; lea eax <-- current weight
; lea ebx <-- gradient
; lea ecx <-- learning rate
; updated weight --> new_w

 fld flzero
 fstp update_size ; Reset update size to 0 incase it has been set

 fld real4 ptr [ebx]
 fld real4 ptr [ecx]
 fmul 
 fstp update_size

 fld real4 ptr [eax]
 fld update_size
 fsub
 fstp new_w
 
 ret
update_weight ENDP

update_bias PROC
; lea eax <-- current bias
; lea ebx <-- gradient
; lea ecx <-- learning rate
; updated bias --> new_b

 fld flzero
 fstp update_size ; Reset update size to 0 incase it has been set

 fld real4 ptr [ebx]
 fld real4 ptr [ecx]
 fmul 
 fstp update_size

 fld real4 ptr [eax]
 fld update_size
 fsub
 fstp new_b
 
 ret
update_bias ENDP

end start