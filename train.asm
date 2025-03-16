include \masm32\include\masm32rt.inc
include feedforward.asm
include mse.asm
include updateparam.asm
include val.asm
include utils.asm

.686p
.mmx
.xmm

.data
; Training Data
X REAL4 3.0, 2.2, 3.3, 4.4, 5.567, 6.0        ; End of array -> NaN
Y REAL4 2.0, 4.7, 6.3, 8.4, 10.567, 12.2  
; Hyperparameters
num_examples DWORD 6
num_epochs DWORD 25000
learning_rate REAL4 0.01

prompt1 DB "Beginning training. . .",13,10,0
prompt2 DB "Epoch",0
prompt3 DB "w: ",0
prompt4 DB "b: ",0
prompt5 DB "MSE: ",0
prompt6 DB "Best Epoch: ",0
prompt7 DB "Current Epoch: ",0
prompt8 DB "Training complete. num_epochs reached. ",13,10,0
newline DB " ",13,10,0

current_epoch DWORD 0
w REAL4 5.0
b REAL4 5.0
best_w REAL4 0.0
best_b REAL4 0.0
best_mse REAL4 1000000.0
current_mse REAL4 0.0

txIndex DWORD 0                     ; what training example we are on
extrabuffer DB 256 dup(?)
temp_q QWORD 0
exampleX_i REAL4 0.0

.code
start:
 call train_model
 push 256
 push offset extrabuffer
 call StdIn

train_model PROC
 mov txIndex, 0
 invoke fPrngGet, 100              ; floating point pseudo random number in range 0,100
 fld real4 ptr [eax]              ; load random float
 fstp w                           ; store in w

 invoke fPrngGet, 100
 fld real4 ptr [eax]
 fstp b 

 Invoke StdOut, offset prompt1

epoch_loop:
 mov eax, current_epoch 
 cmp eax, num_epochs
 je finish_training

example_loop:                      ; loop through all training examples
 mov eax, txIndex
 cmp eax, num_examples
 je finish_epoch                  ; If end of array, jump to finish_epoch

 ; load a training example X
 lea eax, X                      ; array of real4
 mov ebx, txIndex                ; current index
 imul ebx, ebx, 4               ; 4 bytes for real4
 add eax, ebx                   ; current example
 fld real4 PTR [eax]            ; Load X[index] into FPU stack
 fstp exampleX_i

 lea eax, exampleX_i
 lea ebx, w
 lea ecx, b
 call feed_forward              ; feed forward the example 

 lea eax, Y                     ; array of real4
 mov ebx, txIndex               ; current index
 imul ebx, ebx, 4 
 add eax, ebx  

 ; compute squared error 
 lea esi, [eax]
 lea edi, yhat
 call compute_se

 ; Gradient Descent
 ; Weight gradient:
 lea eax, exampleX_i
 mov ebx, 1                     ; calcing weight gradient
 call compute_dse

 lea eax, w
 lea ebx, gradient
 lea ecx, learning_rate
 call update_weight
 fld new_w
 fstp w                        ; update w

 ; Bias Gradient:
 lea eax, exampleX_i
 mov ebx, 0                    ; computing the bias gradient
 call compute_dse

 lea eax, b
 lea ebx, gradient
 lea ecx, learning_rate
 call update_bias
 fld new_b
 fstp b                       ; update b

 mov eax, txIndex
 add eax, 1
 mov txIndex, eax             ; increment training example index
 jmp example_loop

finish_epoch:
 lea eax, X
 lea ebx, w
 lea ecx, b
 mov edx, num_examples
 call create_yhat_array       ; get predictions for every example with new w,b
 Invoke StdOut, offset prompt2

 lea esi, Y
 lea edi, Yhats
 mov ebx, num_examples
 call compute_mse 

 fld current_sum
 fld best_mse
 fcomi st(0), st(1)          ; Compare ST(0) (best_mse) with ST(1) (current_sum)
 fstp st(0)                  ; Remove ST(0) (best_mse)
 fstp st(0)                  ; Remove ST(0) (current_sum)

 jge update_best_mse         ; Jump if greater (if we got a lower mse this time)
 jmp done                    ; Skip to done

update_best_mse:
 fld current_sum             ; Load current_sum onto the FPU stack
 fstp best_mse              ; Store the value into best_mse
 fld best_mse
 fstp current_mse
 fld w
 fstp best_w
 fld b
 fstp best_b

done:
 fld real4 PTR current_sum   ; Load current_sum onto the FPU stack
 fstp current_mse

 mov eax, 0                  ; zero out the training example index
 mov txIndex, eax
 call print_epoch_stats
 
 mov eax, current_epoch
 inc eax
 mov current_epoch, eax      ; increment the current epoch count
 jmp epoch_loop             ; Start the next epoch

finish_training:
 Invoke StdOut, offset newline
 Invoke StdOut, offset newline
 Invoke StdOut, offset prompt8 ; Training complete. num_epochs reached. 
 Invoke StdOut, offset prompt6 ; Best
 Invoke StdOut, offset prompt5 ; MSE:
 lea eax, best_mse
 call printfloat
 Invoke StdOut, offset prompt3 ; w:
 lea eax, best_w
 call printfloat
 Invoke StdOut, offset prompt4 ; b:
 lea eax, best_b
 call printfloat
 Invoke StdOut, offset newline
 ret
train_model ENDP

print_epoch_stats PROC
 Invoke StdOut, offset prompt2 ; Epoch
 mov eax, current_epoch
 add eax, 1
 lea edi, extrabuffer 
 call to_string
 Invoke StdOut, offset extrabuffer ; #
 Invoke StdOut, offset newline
 Invoke StdOut, offset prompt7 ; Current
 Invoke StdOut, offset prompt5 ; MSE:
 lea eax, current_mse
 call printfloat
 Invoke StdOut, offset prompt3 ; w:
 lea eax, w
 call printfloat
 Invoke StdOut, offset prompt4 ; b:
 lea eax, b
 call printfloat
 Invoke StdOut, offset prompt6 ; Best
 Invoke StdOut, offset prompt5 ; MSE:
 lea eax, best_mse
 call printfloat
 Invoke StdOut, offset prompt3 ; w:
 lea eax, best_w
 call printfloat
 Invoke StdOut, offset prompt4 ; b:
 lea eax, best_b
 call printfloat
 Invoke StdOut, offset newline
 ret
print_epoch_stats ENDP

end start
