from scipy.integrate import solve_ivp
import math
import numpy as np

# 定义方程组
def f(t, XY):
    X, Y = XY  # 解包
    dXdt = 3*X + 2*Y
    dYdt = 4*X + Y
    return [dXdt, dYdt]

# 初始条件
X0, Y0 = 1, 2

# 理论解
# X = -1/3*exp(-t) + 4/3*exp(5*t)
# Y =  2/3*exp(-t) + 4/3*exp(5*t)

def analytical_x(t):
    return -1/3*math.exp(-t) + 4/3*math.exp(5*t)

def analytical_y(t):
    return 2/3*math.exp(-t) + 4/3*math.exp(5*t)

t_span = (0, 2)  # 积分时间范围
t_eval = np.linspace(0, 2, 9)  # 输出时间点

# 调用求解器
sol = solve_ivp(f, t_span, [X0, Y0], t_eval=t_eval)

# 输出数值结果
print("t 值：", sol.t)
print("X(t)：", sol.y[0])
print("Y(t)：", sol.y[1])

X_analytical = [analytical_x(t) for t in t_eval]
Y_analytical = [analytical_y(t) for t in t_eval]

print("X_analytical：", X_analytical)
print("Y_analytical：", Y_analytical)

error_X = X_analytical - sol.y[0]
error_Y = Y_analytical - sol.y[1]
print("X误差：", error_X)
print("Y误差：", error_Y)
