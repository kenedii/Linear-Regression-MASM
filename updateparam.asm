; Updates parameters w and b
; By using learning rate and gradient

.data

update_size REAL4 0.0
new_w REAL4 0.0
new_b REAL4 0.0

zeroe REAL4 0.0

.code

update_weight PROC
    ; eax = current weight address
    ; ebx = gradient address
    ; ecx = learning rate address

 fld zeroe
 fstp update_size ; Reset update size to 0 incase it has been set
 fld zeroe
 fstp new_w

    fld real4 ptr [ecx]     ; Load learning rate (lr)
    fmul real4 ptr [ebx]    ; Multiply by gradient (update_size = lr * gradient)
    fstp update_size
    
    fld real4 ptr [eax]     ; Load current weight (w)
    fsub update_size        ; w - update_size
    
    fstp new_w              ; Clean up FPU stack (remove update_size)

    ret
update_weight ENDP

update_bias PROC
; lea eax <-- current bias
; lea ebx <-- gradient
; lea ecx <-- learning rate
; updated bias --> new_b

 fld zeroe
 fstp update_size ; Reset update size to 0 incase it has been set
 fld zeroe
 fstp new_b

 fld real4 ptr [ebx]
 fmul real4 ptr [ecx] 
 fstp update_size

 fld real4 ptr [eax]
 fsub update_size
 fstp new_b
 
 ret
update_bias ENDP
