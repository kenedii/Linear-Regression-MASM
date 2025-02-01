; After forward passing every training example for the epoch,
; Every example will be run through model again with newest w,b to find MSE


.data
X_ REAL4 256 dup(?)
w__ REAL4 0.0
b__ REAL4 0.0
Yhats REAL4 256 dup(?) ; Buffer to store predictions
index DWORD 0          ; Index to track the position in the X array
current_ex REAL4 0.0
n_e DWORD 0


.code
create_yhat_array PROC
; eax <-- X array
; ebx <-- w
; ecx <-- b
; edx <-- num_examples
; Yhat array --> Yhats memory buffer
; Iterate through X until the end of the array is hit
 mov n_e, edx
 push ecx             ; preserve ecx
 push esi             ; preserve esi
 push edi             ; preserve edi
 mov ecx, n_e         ; counter for number of elements
 mov esi, eax         ; source array (X)
 lea edi, X_          ; destination array (X_)
copy_loop:
 fld REAL4 PTR [esi]  ; load value from X
 fstp REAL4 PTR [edi] ; store value into X_
 add esi, 4           ; move to next REAL4 in source
 add edi, 4           ; move to next REAL4 in destination
 loop copy_loop       ; decrement ecx and continue if not zero
 pop edi              ; restore edi
 pop esi              ; restore esi
 pop ecx              ; restore ecx
 fld real4 ptr [ebx]
 fstp w__
 fld real4 ptr [ecx]
 fstp b__
fp_loop:              ; Forward pass loop
 mov eax, index
 cmp eax, n_e
 je return_yhat_array
 ; Load the current element of X based on the index
 lea eax, X_          ; Load the base address of X
 mov ebx, index
 imul ebx, ebx, 4     ; 4 bytes for real4
 add eax, ebx         ; Offset eax by index
 fld real4 PTR [eax]  ; Load X[index] into FPU stack
 fstp current_ex
 ; Prepare parameters for the feedforward procedure
 ; Address of current element of X should already be in eax
 lea eax, current_ex
 lea ebx, w__         ; Address of weight w
 lea ecx, b__         ; Address of bias b
 ; Call the feedforward procedure
 call feed_forward    ; feedforward computes and stores result in yhat
 ; Move the result from yhat to Yhats
 lea esi, yhat        ; Address of yhat
 lea edi, Yhats       ; Address of Yhats buffer
 mov edx, index
 imul edx, edx, 4
 add edi, edx         ; Offset edi by index (corresponding Yhats position)
 mov eax, real4 PTR [esi] ; Load the value from yhat
 mov real4 PTR [edi], eax ; Store the value into Yhats
 ; Increment index to move to the next element (size of REAL4 = 4 bytes)
 mov eax, index
 add eax, 1           ; Increment index by 1
 mov index, eax       ; Increment index by 1
 jmp fp_loop         ; Continue the loop
return_yhat_array:
 mov index, 0
 ret
create_yhat_array ENDP