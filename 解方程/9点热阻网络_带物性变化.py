from scipy.optimize import fsolve
from scipy.interpolate import interp1d
import math
import numpy as np


# 定义方程组
def equations(vars):
    x, y = vars
    eq1 = x**2 + y**2 - 4  # x² + y² = 4
    eq2 = x - y - 1         # x - y = 1
    return [eq1, eq2]

# 初始猜测值
initial_guess = [1, 0]

# 求解
solution = fsolve(equations, initial_guess)
print(f"解: x = {solution[0]:.6f}, y = {solution[1]:.6f}")

# 验证
result = equations(solution)
print(f"验证: {result}")
print(result)
# p - 热管壁; w - 吸液芯; v - 蒸汽区
# e - 蒸发段; i - 绝热段; c - 冷凝段
Q_in = 1000000/570
R = 8.314; M = 0.023
L_e = 1.55; L_i = 0.45; L_c = 2.0
d_p = 0.019; d_w = 0.017; d_v = 0.015
r_p = 0.019/2; r_w = 0.017/2; r_v = 0.015/2
A_c = math.pi*d_p*L_c; h_c = 254; T_f = 563 + 273.15
epsilon = 0.84

def k_p(T_oper):
    return -7.301e-6 * T_oper**2 + 2.716e-2 * T_oper + 6.308

def k_na_l(T_oper):
    return 124.67 - 0.11381*T_oper + 5.5226e-5*T_oper*T_oper - 1.1842e-8*T_oper*T_oper*T_oper

def k_w(T_oper):
    return ((k_na_l(T_oper) + k_p(T_oper)) - (1 - epsilon) * (k_na_l(T_oper) - k_p(T_oper))) / ((k_na_l(T_oper) + k_p(T_oper)) + (1 - epsilon) * (k_na_l(T_oper) - k_p(T_oper))) * k_na_l(T_oper)

T_hfg_table = [371,  400,  500,  600,  700,  800,  900,  1000, 1100, 1200,\
               1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2100, 2200,\
               2300, 2400, 2500, 2503.7]
hfg_table   = [4532, 4510, 4435, 4358, 4279, 4197, 4112, 4024, 3933, 3838,\
               3738, 3633, 3523, 3405, 3279, 3143, 2994, 2829, 2640, 2418,\
               2141, 1747, 652, 0]
hfg_table   = [x*1000 for x in hfg_table]
hfg = interp1d(T_hfg_table,hfg_table,kind='linear')

T_p_v_table = [370.98,  394, 400, 425, 461, 500, 504,  555.5, 600,    620,\
                  700,  701, 800, 808, 900, 954, 1000, 1100,  1156.2, 1200,\
                 1300, 1400]
p_v_table   = [1.37e-11,1.01e-10,1.61e-10,1.01e-09,1.01e-08,8.54e-08,1.01e-07,1.01e-06,5.26e-06,1.01e-05,\
               9.87e-05,1.01e-04,8.71e-04,1.01e-03,4.74e-03,1.01e-02,1.85e-02,5.77e-02,1.01e-01,1.52e-01,\
               3.37e-01,5.93e-01]
p_v_table   = [x*1000000 for x in p_v_table]
p_v = interp1d(T_p_v_table,p_v_table,kind='linear')

T_miu_table  = [400.0, 500.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1100.0, 1200.0, 1300.0,\
            1400.0, 1500.0, 1600.0, 1700.0, 1800.0, 1900.0, 2000.0, 2100.0, 2200.0, 2300.0, \
            2400.0, 2500.0, 2503.7]
miu_table = [137.40, 143.69, 149.97, 156.26, 162.55, 168.84, 175.15, 181.51, 187.96, 194.57,\
             201.44, 208.68, 216.43, 224.85, 234.12, 244.45, 256.10, 269.45, 285.06, 304.11,\
             330.04, 414.31, 580.00]
miu_table = [x/10000000.0 for x in miu_table]
miu_v = interp1d(T_miu_table,miu_table,kind='linear',fill_value='extrapolate')

T_rho_v_table = [800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, \
                 1800, 1900, 2000]
rho_v_table   = [0.003, 0.017, 0.059, 0.163, 0.381, 0.779, 1.433, 2.433, 3.874, 5.857,\
                 8.485, 11.850, 16.040]
rho_v = interp1d(T_rho_v_table,rho_v_table,kind='linear')

def equations(vars):
    T_v_e, T_v_i, T_v_c, T_w_e, T_w_i, T_w_c, T_p_e, T_p_i, T_p_c, T_wallc = vars
    R_p_to_w_e_r = math.log( (d_w+d_p)/2/d_w )   / (2*math.pi*k_p(T_p_e)*L_e) + \
             math.log( d_w/((d_v+d_w)/2) ) / (2*math.pi*k_w(T_w_e)*L_e)
    R_p_e_to_i_a = (L_e / 2) / (math.pi * k_p(T_p_e) * (r_p ** 2 - r_w ** 2)) + \
                   (L_i / 2) / (math.pi * k_p(T_p_i) * (r_p ** 2 - r_w ** 2))
    R_p_i_to_c_a = (L_i/2) / (math.pi*k_p(T_p_i)*(r_p**2 - r_w**2)) +\
                   (L_c/2) / (math.pi*k_p(T_p_c)*(r_p**2 - r_w**2))
    R_w_to_p_c_r = math.log((d_w + d_p) / 2 / d_w) / (2 * math.pi * k_p(T_p_c) * L_c) + \
                   math.log(d_w / ((d_v + d_w) / 2)) / (2 * math.pi * k_w(T_w_c) * L_c)
    R_w_e_to_i_a = (L_e / 2) / (math.pi * k_w(T_w_e) * (r_w ** 2 - r_v ** 2)) + \
                   (L_i / 2) / (math.pi * k_w(T_w_i) * (r_w ** 2 - r_v ** 2))
    R_w_to_v_e_r = math.log(((d_v + d_w) / 2) / d_v) / (2 * math.pi * k_w(T_w_e) * L_e) + \
                   math.sqrt(2 * math.pi * R * T_v_e) * R * T_v_e ** 2 / (\
                               hfg(T_v_e) ** 2 * p_v(T_v_e) * M * math.sqrt(M) * math.pi * d_v * L_e)
    R_w_i_to_c_a = (L_i / 2) / (math.pi * k_w(T_w_i) * (r_w ** 2 - r_v ** 2)) + \
                   (L_c / 2) / (math.pi * k_w(T_w_c) * (r_w ** 2 - r_v ** 2))
    R_v_to_w_c_r = math.sqrt(2 * math.pi * R * T_v_c) * R * T_v_c ** 2 / (\
                hfg(T_v_c) ** 2 * p_v(T_v_c) * M * math.sqrt(M) * math.pi * d_v * L_c) + \
                   math.log(((d_w + d_v) / 2) / d_v) / (2 * math.pi * k_w(T_w_c) * L_c)
    R_v_e_to_i_a = 8 * R * T_v_e ** 2 * miu_v(T_v_e) * (L_e) / 2 / \
                   (math.pi * rho_v(T_v_e) * (r_v ** 4) * (hfg(T_v_e)) ** 2 * p_v(T_v_e) * M) + \
                   8 * R * T_v_i ** 2 * miu_v(T_v_i) * (L_i) / 2 / \
                   (math.pi * rho_v(T_v_i) * (r_v ** 4) * (hfg(T_v_i)) ** 2 * p_v(T_v_i) * M)
    R_v_i_to_c_a = 8 * R * T_v_i ** 2 * miu_v(T_v_i) * (L_i) / 2 / \
                   (math.pi * rho_v(T_v_i) * (r_v ** 4) * (hfg(T_v_i)) ** 2 * p_v(T_v_i) * M) + \
                   8 * R * T_v_c ** 2 * miu_v(T_v_c) * (L_c) / 2 / \
                   (math.pi * rho_v(T_v_c) * (r_v ** 4) * (hfg(T_v_c)) ** 2 * p_v(T_v_c) * M)

    eq1 = Q_in + T_w_e/R_p_to_w_e_r - T_p_e/R_p_to_w_e_r + T_p_i/R_p_e_to_i_a - T_p_e/R_p_e_to_i_a
    eq2 = T_p_e/R_p_e_to_i_a - T_p_i/R_p_e_to_i_a + T_p_c/R_p_i_to_c_a - T_p_i/R_p_i_to_c_a
    eq3 = T_p_i/R_p_i_to_c_a - T_p_c/R_p_i_to_c_a + T_w_c/R_w_to_p_c_r - T_p_c/R_w_to_p_c_r - h_c*A_c*(T_wallc - T_f)
    eq4 = (T_p_c - T_wallc)/(math.log(r_p/((r_p+r_w)/2))/(2*math.pi*k_p(T_p_c)*L_c)) - h_c*A_c*T_wallc + h_c*A_c*T_f
    eq5 = T_p_e/R_p_to_w_e_r - T_w_e/R_p_to_w_e_r + T_w_i/R_w_e_to_i_a - T_w_e/R_w_e_to_i_a + T_v_e/R_w_to_v_e_r - T_w_e/R_w_to_v_e_r
    eq6 = T_w_e/R_w_e_to_i_a - T_w_i/R_w_e_to_i_a + T_w_c/R_w_i_to_c_a - T_w_i/R_w_i_to_c_a
    eq7 = T_w_i/R_w_i_to_c_a - T_w_c/R_w_i_to_c_a + T_p_c/R_w_to_p_c_r - T_w_c/R_w_to_p_c_r + T_v_c/R_v_to_w_c_r - T_w_c/R_v_to_w_c_r
    eq8 = T_w_e/R_w_to_v_e_r - T_v_e/R_w_to_v_e_r + T_v_i/R_v_e_to_i_a - T_v_e/R_v_e_to_i_a
    eq9 = T_v_e/R_v_e_to_i_a - T_v_i/R_v_e_to_i_a + T_v_c/R_v_i_to_c_a - T_v_i/R_v_i_to_c_a
    eq10= T_v_i/R_v_i_to_c_a - T_v_c/R_v_i_to_c_a + T_w_c/R_v_to_w_c_r - T_v_c/R_v_to_w_c_r
    return [eq1, eq2, eq3, eq4, eq5, eq6, eq7, eq8, eq9, eq10]

# 初始猜测值
initial_guess = [900, 900, 900, 900, 900, 900, 900, 900, 900, 900]

# 求解
solution = fsolve(equations, initial_guess)
# T_v_e, T_v_i, T_v_c, T_w_e, T_w_i, T_w_c, T_p_e, T_p_i, T_p_c, T_wallc
print(solution)
T_v_e = solution[0]
T_v_i = solution[1]
T_v_c = solution[2]
T_w_e = solution[3]
T_w_i = solution[4]
T_w_c = solution[5]
T_p_e = solution[6]
T_p_i = solution[7]
T_p_c = solution[8]
T_wallc = solution[9]

print("T_v_e = ", solution[0])
print("T_v_i = ", solution[1])
print("T_v_c = ", solution[2])
print("T_w_e = ", solution[3])
print("T_w_i = ", solution[4])
print("T_w_c = ", solution[5])
print("T_p_e = ", solution[6])
print("T_p_i = ", solution[7])
print("T_p_c = ", solution[8])
print("T_wallc = ", solution[9])

R_p_to_w_e_r = math.log((d_w + d_p) / 2 / d_w) / (2 * math.pi * k_p(T_p_e) * L_e) + \
               math.log(d_w / ((d_v + d_w) / 2)) / (2 * math.pi * k_w(T_w_e) * L_e)
R_p_e_to_i_a = (L_e / 2) / (math.pi * k_p(T_p_e) * (r_p ** 2 - r_w ** 2)) + \
               (L_i / 2) / (math.pi * k_p(T_p_i) * (r_p ** 2 - r_w ** 2))
R_p_i_to_c_a = (L_i / 2) / (math.pi * k_p(T_p_i) * (r_p ** 2 - r_w ** 2)) + \
               (L_c / 2) / (math.pi * k_p(T_p_c) * (r_p ** 2 - r_w ** 2))
R_w_to_p_c_r = math.log((d_w + d_p) / 2 / d_w) / (2 * math.pi * k_p(T_p_c) * L_c) + \
               math.log(d_w / ((d_v + d_w) / 2)) / (2 * math.pi * k_w(T_w_c) * L_c)
R_w_e_to_i_a = (L_e / 2) / (math.pi * k_w(T_w_e) * (r_w ** 2 - r_v ** 2)) + \
               (L_i / 2) / (math.pi * k_w(T_w_i) * (r_w ** 2 - r_v ** 2))
R_w_to_v_e_r = math.log(((d_v + d_w) / 2) / d_v) / (2 * math.pi * k_w(T_w_e) * L_e) + \
               math.sqrt(2 * math.pi * R * T_v_e) * R * T_v_e ** 2 / ( \
                           hfg(T_v_e) ** 2 * p_v(T_v_e) * M * math.sqrt(M) * math.pi * d_v * L_e)
R_w_i_to_c_a = (L_i / 2) / (math.pi * k_w(T_w_i) * (r_w ** 2 - r_v ** 2)) + \
               (L_c / 2) / (math.pi * k_w(T_w_c) * (r_w ** 2 - r_v ** 2))
R_v_to_w_c_r = math.sqrt(2 * math.pi * R * T_v_c) * R * T_v_c ** 2 / ( \
            hfg(T_v_c) ** 2 * p_v(T_v_c) * M * math.sqrt(M) * math.pi * d_v * L_c) + \
               math.log(((d_w + d_v) / 2) / d_v) / (2 * math.pi * k_w(T_w_c) * L_c)
R_v_e_to_i_a = 8 * R * T_v_e ** 2 * miu_v(T_v_e) * (L_e) / 2 / \
               (math.pi * rho_v(T_v_e) * (r_v ** 4) * (hfg(T_v_e)) ** 2 * p_v(T_v_e) * M) + \
               8 * R * T_v_i ** 2 * miu_v(T_v_i) * (L_i) / 2 / \
               (math.pi * rho_v(T_v_i) * (r_v ** 4) * (hfg(T_v_i)) ** 2 * p_v(T_v_i) * M)
R_v_i_to_c_a = 8 * R * T_v_i ** 2 * miu_v(T_v_i) * (L_i) / 2 / \
               (math.pi * rho_v(T_v_i) * (r_v ** 4) * (hfg(T_v_i)) ** 2 * p_v(T_v_i) * M) + \
               8 * R * T_v_c ** 2 * miu_v(T_v_c) * (L_c) / 2 / \
               (math.pi * rho_v(T_v_c) * (r_v ** 4) * (hfg(T_v_c)) ** 2 * p_v(T_v_c) * M)

print("R_p_e_to_i_a = ", R_p_e_to_i_a)
print("R_p_i_to_c_a = ", R_p_i_to_c_a)
print("R_w_e_to_i_a = ", R_w_e_to_i_a)
print("R_w_i_to_c_a = ", R_w_i_to_c_a)
print("R_v_e_to_i_a = ", R_v_e_to_i_a)
print("R_v_i_to_c_a = ", R_v_i_to_c_a)
print("R_p_to_w_e_r = ", R_p_to_w_e_r)
print("R_w_to_v_e_r = ", R_w_to_v_e_r)
print("R_v_to_w_c_r = ", R_v_to_w_c_r)
print("R_w_to_p_c_r = ", R_w_to_p_c_r)

Q_in
Q_p_a_1 = (T_p_e - T_p_i)/R_p_e_to_i_a
Q_p_a_2 = (T_p_i - T_p_c)/R_p_i_to_c_a
Q_p_to_w_e = (T_p_e - T_w_e)/R_p_to_w_e_r
Q_w_a_1 = (T_w_e - T_w_i)/R_w_e_to_i_a
Q_w_a_2 = (T_w_i - T_w_c)/R_w_i_to_c_a



