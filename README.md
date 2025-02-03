# 📊 Linear-Regression-MASM

A **simple linear regression model** built using **Stochastic Gradient Descent** (SGD) and trained with a single **X feature** (independent variable), developed in **MASM32 x86 assembly**.

🔧 **Minimum Processor**: Pentium Pro or better [(.686p)](https://learn.microsoft.com/en-us/cpp/assembler/masm/dot-686p?view=msvc-170)

---

## 🚧 To-Do:
- Implement **Batch Gradient Descent**
- Implement **Logistic Regression** with **Sigmoid** activation

---

## 🗂 Files

### **train.asm**
- Specify the following parameters:
  - **X** (input feature)
  - **Y** (target output)
  - **num_epochs** (epochs to train)
  - **learning_rate** (the rate at which the model learns)
  - **num_examples** (the number of training examples)

- Call the `train_model` procedure to train the model.

---

### **feedforward.asm**
- **feed_forward PROC**: Computes the model prediction (`yhat = wx + b`) for a single training example `x`.

---

### **mse.asm**
- **compute_se PROC**: Calculates the squared error, `se = (y - yhat)^2`.
- **compute_dse PROC**: Computes the derivative of the squared error function with respect to weight or bias.
- **compute_mse PROC**: Calculates the **Mean Squared Error (MSE)** over all training examples using the array of `Yhats`.

---

### **updateparam.asm**
- **update_bias PROC**: Updates the **bias parameter** (`b`).
- **update_weight PROC**: Updates the **weight parameter** (`w`) using the learning rate and gradient.

---

### **val.asm**
- **create_yhat_array PROC**: After completing forward pass for every training example, this procedure runs each example through the model again with the latest weight (`w`) and bias (`b`) to compute the updated MSE.

---

### **utils.asm**
- Contains miscellaneous procedures that are not directly related to the linear regression algorithm, including:
  - **Int to ASCII conversion**
  - **Float printing**
