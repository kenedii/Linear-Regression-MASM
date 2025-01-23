; After forward passing every training example for the epoch,
; Every example will be run through model again with newest w,b to find MSE

.data

Yhats  REAL4 ? ; Buffer to store predictions


index  DWORD 0                    ; Index to track the position in the X array

nanValue SDWORD -1

.code

create_yhat_array PROC
    ; Iterate through X until the end of the array is hit

    fp_loop: ; Forward pass loop
        ; Load the current element of X based on the index
        lea eax, X               ; Load the base address of X
        add eax, index           ; Offset eax by index
        fld DWORD PTR [eax]      ; Load X[index] into FPU stack
        fistp DWORD PTR nanValue ; Check if the value is -1 (NaN equivalent)
        cmp DWORD PTR nanValue, -1 ; Compare with termination value
        je return_yhat_array     ; If end of array, jump to return_yhat_array

        ; Prepare parameters for the feedforward procedure
        ; Address of current element of X should already be in eax
        lea ebx, w               ; Address of weight w
        lea ecx, b               ; Address of bias b

        ; Call the feedforward procedure
        call feedforward         ; feedforward computes and stores result in yhat

        ; Move the result from yhat to Yhats
        lea esi, yhat            ; Address of yhat
        lea edi, Yhats           ; Address of Yhats buffer
        add edi, index           ; Offset edi by index (corresponding Yhats position)
        mov eax, DWORD PTR [esi] ; Load the value from yhat
        mov DWORD PTR [edi], eax ; Store the value into Yhats

        ; Increment index to move to the next element (size of REAL4 = 4 bytes)
        add index, 4             ; Increment index by 4
        jmp fp_loop              ; Continue the loop

    return_yhat_array:
        ; NaN terminate the Yhats buffer
        lea edx, Yhats           ; Load the address of Yhats
        add edx, index           ; Offset to the end of the Yhats array
        mov DWORD PTR [edx], -1  ; Terminate with NaN
        ret
create_yhat_array ENDP