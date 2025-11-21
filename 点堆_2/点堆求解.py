# Transient heat pipe failure accident analysis of a megawatt heat pipe cooled reactor
# https://www.sciencedirect.com/science/article/abs/pii/S0149197021002675
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
LAMBDA = 2.6702E-6
beta1 = 0.00020321
beta2 = 0.0011925
beta3 = 0.0011767
beta4 = 0.0034811
beta5 = 0.0011865
beta6 = 0.00038436
lambda1 = 0.0127
lambda2 = 0.0317
lambda3 = 0.115
lambda4 = 0.311
lambda5 = 1.4
lambda6 = 3.87
rho = 0.00075
n0 = 1.0
from scipy.optimize import brentq
def solve_equations(input_omega):
    return rho - LAMBDA*input_omega - input_omega*beta1/(input_omega+lambda1) - \
        input_omega*beta2/(input_omega+lambda2)- \
        input_omega*beta3/(input_omega+lambda3)- \
        input_omega * beta4 / (input_omega + lambda4) - \
        input_omega * beta5 / (input_omega + lambda5) - \
        input_omega * beta6 / (input_omega + lambda6)

#-(1-rho)/LAMBDA, -lambda6, -lambda5, -lambda4, -lambda3, -lambda2, -lambda1

omega_7 = brentq(solve_equations, -(1-rho)/LAMBDA + (-lambda6+(1-rho)/LAMBDA)/10000, -lambda6 - (-lambda6+(1-rho)/LAMBDA)/10000)
omega_6 = brentq(solve_equations, -lambda6 + (-lambda5+lambda6)/10000, -lambda5 - (-lambda5+lambda6)/10000)
omega_5 = brentq(solve_equations, -lambda5 + (-lambda4+lambda5)/10000, -lambda4 - (-lambda4+lambda5)/10000)
omega_4 = brentq(solve_equations, -lambda4 + (-lambda3+lambda4)/10000, -lambda3 - (-lambda3+lambda4)/10000)
omega_3 = brentq(solve_equations, -lambda3 + (-lambda2+lambda3)/10000, -lambda2 - (-lambda2+lambda3)/10000)
omega_2 = brentq(solve_equations, -lambda2 + (-lambda1+lambda2)/10000, -lambda1 - (-lambda1+lambda2)/10000)
omega_1 = brentq(solve_equations, -lambda1 + (0+lambda1)/10000, 1145141919810)

print("omega_1 = %s"%(omega_1))
print("omega_2 = %s"%(omega_2))
print("omega_3 = %s"%(omega_3))
print("omega_4 = %s"%(omega_4))
print("omega_5 = %s"%(omega_5))
print("omega_6 = %s"%(omega_6))
print("omega_7 = %s"%(omega_7))

sum_1 = beta1*lambda1/(omega_1+lambda1)**2+\
        beta2*lambda2/(omega_1+lambda2)**2+\
        beta3*lambda3/(omega_1+lambda3)**2+\
        beta4*lambda4/(omega_1+lambda4)**2+\
        beta5*lambda5/(omega_1+lambda5)**2+\
        beta6*lambda6/(omega_1+lambda6)**2

sum_2 = beta1*lambda1/(omega_2+lambda1)**2+\
        beta2*lambda2/(omega_2+lambda2)**2+\
        beta3*lambda3/(omega_2+lambda3)**2+\
        beta4*lambda4/(omega_2+lambda4)**2+\
        beta5*lambda5/(omega_2+lambda5)**2+\
        beta6*lambda6/(omega_2+lambda6)**2

sum_3 = beta1*lambda1/(omega_3+lambda1)**2+\
        beta2*lambda2/(omega_3+lambda2)**2+\
        beta3*lambda3/(omega_3+lambda3)**2+\
        beta4*lambda4/(omega_3+lambda4)**2+\
        beta5*lambda5/(omega_3+lambda5)**2+\
        beta6*lambda6/(omega_3+lambda6)**2

sum_4 = beta1*lambda1/(omega_4+lambda1)**2+\
        beta2*lambda2/(omega_4+lambda2)**2+\
        beta3*lambda3/(omega_4+lambda3)**2+\
        beta4*lambda4/(omega_4+lambda4)**2+\
        beta5*lambda5/(omega_4+lambda5)**2+\
        beta6*lambda6/(omega_4+lambda6)**2

sum_5 = beta1*lambda1/(omega_5+lambda1)**2+\
        beta2*lambda2/(omega_5+lambda2)**2+\
        beta3*lambda3/(omega_5+lambda3)**2+\
        beta4*lambda4/(omega_5+lambda4)**2+\
        beta5*lambda5/(omega_5+lambda5)**2+\
        beta6*lambda6/(omega_5+lambda6)**2

sum_6 = beta1*lambda1/(omega_6+lambda1)**2+\
        beta2*lambda2/(omega_6+lambda2)**2+\
        beta3*lambda3/(omega_6+lambda3)**2+\
        beta4*lambda4/(omega_6+lambda4)**2+\
        beta5*lambda5/(omega_6+lambda5)**2+\
        beta6*lambda6/(omega_6+lambda6)**2

sum_7 = beta1*lambda1/(omega_7+lambda1)**2+\
        beta2*lambda2/(omega_7+lambda2)**2+\
        beta3*lambda3/(omega_7+lambda3)**2+\
        beta4*lambda4/(omega_7+lambda4)**2+\
        beta5*lambda5/(omega_7+lambda5)**2+\
        beta6*lambda6/(omega_7+lambda6)**2

A_1 = rho*(  omega_1*( LAMBDA + sum_1 )  )**(-1)
A_2 = rho*(  omega_2*( LAMBDA + sum_2 )  )**(-1)
A_3 = rho*(  omega_3*( LAMBDA + sum_3 )  )**(-1)
A_4 = rho*(  omega_4*( LAMBDA + sum_4 )  )**(-1)
A_5 = rho*(  omega_5*( LAMBDA + sum_5 )  )**(-1)
A_6 = rho*(  omega_6*( LAMBDA + sum_6 )  )**(-1)
A_7 = rho*(  omega_7*( LAMBDA + sum_7 )  )**(-1)

print("A_1 = %s"%(A_1))
print("A_2 = %s"%(A_2))
print("A_3 = %s"%(A_3))
print("A_4 = %s"%(A_4))
print("A_5 = %s"%(A_5))
print("A_6 = %s"%(A_6))
print("A_7 = %s"%(A_7))

def nt(time):
    return n0 * (  A_1*math.exp(omega_1*time)+\
        A_2*math.exp(omega_2*time)+\
        A_3*math.exp(omega_3*time)+\
        A_4*math.exp(omega_4*time)+\
        A_5*math.exp(omega_5*time)+\
        A_6*math.exp(omega_6*time)+ \
        A_7 * math.exp(omega_7 * time)  )

delta_i = 1
for i in range(0, 170):
    print("nt(%s) = %s"%(  delta_i*(i+1),nt(delta_i*(i+1))  ))
