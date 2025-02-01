# Linear-Regression-MASM

Simple linear regression model using Stochastic Gradient Descent and training with 1 X feature (independent variable) made using MASM32 x86 assembly.

Minimum processor Pentium Pro or better [(.686p)](https://learn.microsoft.com/en-us/cpp/assembler/masm/dot-686p?view=msvc-170)

To do:

- Batch Gradient Descent

- Logistic Regression w/ Sigmoid

Files:

**train.asm**

Specify X, Y, num_epochs, learning_rate, num_examples and train a LR model by calling train_model PROC.

**feedforward.asm**

feed_forward PROC: ;Computes yhat = wx + b for a training example x

**mse.asm**

compute_se PROC      ; compute squared error  =  [y-yhat]^2 

compute_dse PROC ; Computes the derivative of the squared error function with respect to weight or bias

compute_mse PROC ; Computes the MSE over all training examples using array of Yhats.

**updateparam.asm**

; update_bias PROC and update_weight PROC Updates parameters w and b By using learning rate and gradient.

**val.asm**

create_yhat_array PROC  ; After forward passing every training example for the epoch, every example will be run through model again with newest w,b to find MSE

**utils.asm**

; Procedures irrelevant to the Linear Regression algorithm (int to ascii, print float)
