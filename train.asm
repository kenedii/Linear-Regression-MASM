include \masm32\include\masm32rt.inc
include feedforward.asm
include mse.asm
include updateparam.asm
include val.asm
include utils.asm

.data

prompt1 DB "Beginning training. . .",13,10,0
prompt2 DB "Epoch",0
prompt3 DB "w: ",0
prompt4 DB "b: ",0
prompt5 DB "MSE: ",0
prompt6 DB "Best Epoch: ",0
prompt7 DB "Current Epoch: ",0
prompt8 DB "Training complete. num_epochs reached. ",13,10,0
newline " ",13,10,0

num_epochs       DWORD 0
learning_rate    REAL4 0.0

X   REAL4 1.0, 2.2, 3.3, 4.4, 5.567, 6.0
            SDWORD -1        ; End of array -> NaN
Y REAL4 2.0, 4.7, 6.3, 8.4, 10.567, 12.2
            SDWORD -1      
            
num_examples DWORD 0
current_epoch DWORD 0
w REAL4 0.0
b REAL4 0.0
best_w REAL4 0.0
best_b REAL4 0.0
best_mse REAL4 0.0
current_mse REAL4 0.0


txIndex DWORD 0 ; what training example we are on

extrabuffer DB 256dup(?)

.code

start:

call train_model

push 256
push offset extrabuffer
call StdIn


train_model PROC

 ; to do: initialize random parameters w,b
 mov w, 1
 mov b, 1

 Invoke StdOut, offset prompt1

 epoch_loop:
  mov eax, current_epoch 
  cmp eax, num_epochs
  je finish_training


  example_loop: ; loop through all training examples
   ; load a training example X
   lea eax, X         ; array of real4
   mov ebx, txIndex    ; current index
   imul ebx, ebx, 4    ; 4 bytes for real4
   add eax, ebx ; current example
   fld DWORD PTR [eax]      ; Load X[index] into FPU stack
   fistp DWORD PTR nanValue ; Check if the value is -1 (NaN equivalent)
   cmp DWORD PTR nanValue, -1 ; Compare with termination value
   je finish_epoch     ; If end of array, jump to finish_epoch

   lea eax, X         ; array of real4
   mov ebx, txIndex    ; current index
   imul ebx, ebx, 4    ; 4 bytes for real4
   add eax, ebx ; current example
   lea ebx, w
   lea ecx, b
   call feed_forward     ; feed forward the example 

   lea eax, Y         ; array of real4
   mov ebx, txIndex    ; current index
   imul ebx, ebx, 4 
   add eax, ebx  

   ; compute squared error 
   mov esi, eax
   mov edi, yhat

   ; Gradient Descent
   ; Weight gradient:
   lea eax, X         ; array of real4
   mov ebx, txIndex    ; current index
   imul ebx, ebx, 4    ; 4 bytes for real4
   add eax, ebx ; current example
   mov ebx, 1 ; calcing weight gradient
 
   call compute_dse

   lea eax, w
   lea ebx, gradient
   lea ecx, learning_rate
   call update_weight
   fld new_w
   fstp w   ; update w

   ; Bias Gradient:
   lea eax, X         ; array of real4 ; example X is needed for the proc but not the 
   mov ebx, txIndex    ; current index ; computation of bias gradient itself
   imul ebx, ebx, 4    ; 4 bytes for real4 ; need to fix this!!
   add eax, ebx ; current example
   mov ebx, 0 ; computing the bias gradient
 
   call compute_dse

   lea eax, b
   lea ebx, gradient
   lea ecx, learning_rate
   call update_weight
   fld new_b
   fstp b  ; update b


   mov eax, txIndex
   inc eax
   mov txIndex, eax ; increment training example index
   jmp example_loop



 finish_epoch:
 ; compare mse with best
 ; print to stdout MSE, This epoch's weights, Best epochs weights
  call create_yhat_array ; get predictions for every example with new w,b
  lea esi, Y
  lea edi, Yhats
  mov ebx, num_examples
  call compute_mse

   ; Load current_sum onto the FPU stack
    fld DWORD PTR [current_sum]

    ; Load best_mse onto the FPU stack
    fld DWORD PTR [best_mse]

    ; Compare the two values on the FPU stack
    ; FPU stack: ST(0) = best_mse, ST(1) = current_sum
    fcomi st(0), st(1)  ; Compare ST(0) (best_mse) with ST(1) (current_sum)
                        ; Sets EFLAGS based on the result

    ; Pop the FPU stack twice to clean up (we don't need the values on the stack)
    fstp st(0)          ; Remove ST(0) (best_mse)
    fstp st(0)          ; Remove ST(0) (current_sum)

    ; Check if current_sum > best_mse
    ja update_best_mse   ; Jump if above (greater)

    ; If current_sum <= best_mse, skip updating
    jmp done             ; Skip to done

   update_best_mse:
    ; Update best_mse with the value of current_sum
    fld DWORD PTR [current_sum] ; Load current_sum onto the FPU stack
    fstp DWORD PTR [best_mse]   ; Store the value into best_mse
    fld best_mse
    fstp current_mse
    fld w
    fstp best_w
    fld b
    fstp best_b

   done:
    fld DWORD PTR [current_sum] ; Load current_sum onto the FPU stack
    fstp current_mse

    call print_epoch_stats
    jmp epoch_loop   ; Start the next epoch

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
  


train_model ENDP

print_epoch_stats PROC

 Invoke StdOut, offset prompt2 ; Epoch
 mov eax, current_epoch
 add eax, 1
 lea edi extrabuffer
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