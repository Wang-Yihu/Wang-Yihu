#Solving nuclear reactor physics point reactor problem
# [dnt/dt] = (rhot-beta)/LAMBDA * nt +lambda1*C1 + ... + lambda6*C6
# [dC1/dt] = beta1/LAMBDA * nt - lambda1*C1
# ......
# [dC6/dt] = beta6/LAMBDA * nt - lambda6*C6
# n0 = 1.0
# C10 = ${fparse beta1*n0/lambda1/LAMBDA }
# C20 = ${fparse beta2*n0/lambda2/LAMBDA }
# C30 = ${fparse beta3*n0/lambda3/LAMBDA }
# C40 = ${fparse beta4*n0/lambda4/LAMBDA }
# C50 = ${fparse beta5*n0/lambda5/LAMBDA }
# C60 = ${fparse beta6*n0/lambda6/LAMBDA }
# t<0, rhot = 0, t>=0, rhot = 0.003
# The solution is of the form n(t) = n0*(A_1*exp(omega_1*t)+...+A_7*exp(omega_7*t))
# The derivation of A_1, ..., A_7 and omega_1,...,omega_7 can be found in the relevant textbooks.
import math
import numpy as np
from scipy.integrate import solve_ivp
LAMBDA = 2E-5
beta1 = 0.000266
beta2 = 0.001491
beta3 = 0.001316
beta4 = 0.002849
beta5 = 0.000896
beta6 = 0.000182
beta = beta1+beta2+beta3+beta4+beta5+beta6
lambda1 = 0.0127
lambda2 = 0.0317
lambda3 = 0.115
lambda4 = 0.311
lambda5 = 1.4
lambda6 = 3.87
rho = 0.003
n0 = 1.0
C10 = beta1*n0/lambda1/LAMBDA
C20 = beta2*n0/lambda2/LAMBDA
C30 = beta3*n0/lambda3/LAMBDA
C40 = beta4*n0/lambda4/LAMBDA
C50 = beta5*n0/lambda5/LAMBDA
C60 = beta6*n0/lambda6/LAMBDA
def f(t, vars):
   nt, C1, C2, C3, C4, C5, C6 = vars
   dn_dt = (rho-beta)/LAMBDA * nt + lambda1*C1 + \
           lambda2*C2 + lambda3*C3 + lambda4*C4 + \
           lambda5*C5 + lambda6*C6
   dC1_dt = beta1 / LAMBDA * nt - lambda1 * C1
   dC2_dt = beta2 / LAMBDA * nt - lambda2 * C2
   dC3_dt = beta3 / LAMBDA * nt - lambda3 * C3
   dC4_dt = beta4 / LAMBDA * nt - lambda4 * C4
   dC5_dt = beta5 / LAMBDA * nt - lambda5 * C5
   dC6_dt = beta6 / LAMBDA * nt - lambda6 * C6
   return [dn_dt, dC1_dt, dC2_dt, dC3_dt, dC4_dt, dC5_dt, dC6_dt]


t_span = (0, 1)  # 积分时间范围
t_eval = np.linspace(0, 1, 11)  # 输出时间点

# 调用求解器
# rtol=1e-8, atol=1e-11 is necessary!
sol = solve_ivp(f, t_span, [n0, C10, C20, C30, C40, C50, C60], t_eval=t_eval,rtol=1e-8, atol=1e-11)

print("t 值：", sol.t)
print("n(t)：", sol.y[0])
