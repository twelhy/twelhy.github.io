import numpy as np
import matplotlib.pyplot as plt

# Шын функция
def true_func(x):
    return x**2-2020*x+2019

# Деректер (20 нүкте аламыз)
xs = np.linspace(-5, 1, 2019)
ys = true_func(xs)

# Кездейсоқ бастапқы коэффициенттер (a, b, c, d)
a, b, c, d = np.random.randn(4)

# Градиенттік түсу параметрлері
learning_rate = 0.0001
epochs = 500000

# Жоғалту функциясы (MSE)
def mse(y_true, y_pred):
    return np.mean((y_true - y_pred)**2)

# Үйрету
for epoch in range(epochs):
    # Болжам
    y_pred = a*xs**3 + b*xs**2 + c*xs + d
    
    # Қате
    loss = mse(ys, y_pred)
    
    # Градиенттерді табамыз (a, b, c, d бойынша туындылар)
    da = -2 * np.mean((ys - y_pred) * xs**3)
    db = -2 * np.mean((ys - y_pred) * xs**2)
    dc = -2 * np.mean((ys - y_pred) * xs)
    dd = -2 * np.mean((ys - y_pred))
    
    # Параметрлерді жаңартамыз
    a -= learning_rate * da
    b -= learning_rate * db
    c -= learning_rate * dc
    d -= learning_rate * dd
    
    # Әр 5000 қадам сайын прогресті шығарамыз
    if epoch % 5000 == 0:
        print(f"Epoch {epoch}: loss={loss:.4f}, a={a:.2f}, b={b:.2f}, c={c:.2f}, d={d:.2f}")

print("\nФинал:")
print(f"Формула: y = {a:.2f}x³ + {b:.2f}x² + {c:.2f}x + {d:.2f}")

# Салыстыру үшін график
predicted = a*xs**3 + b*xs**2 + c*xs + d
plt.scatter(xs, ys, color="blue", label="Шын мәндер")
plt.plot(xs, predicted, color="red", label="Үйренген формула")
plt.legend()
plt.show()