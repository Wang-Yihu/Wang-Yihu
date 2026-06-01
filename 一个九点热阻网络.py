# Sodium Coolant Handbook: Physical and Chemical Properties IAEA–TECDOC–XXXX
# IAEA PROJECT ON SODIUM PROPERTIES AND SAFE OPERATION OF EXPERIMENTAL FACILITIES IN SUPPORT OF THE DEVELOPMENT AND DEPLOYMENT OF SODIUM–COOLED FAST REACTORS (NAPRO)
# https://mooseframework.inl.gov/bison/source/materials/SS316Thermal.html
# Thermodynamic and transport properties of sodium liquid and vapor
# THE THERMODYNAMIC AND TRANSPORT PROPERTIES OF SODIUM AND SODIUM VAPOR by E. L. Dunning
import math
from scipy.interpolate import interp1d
import numpy as np
Q_in = 1000000/570
R = 8.314; M = 0.023
L_e = 1.55; L_i = 0.45; L_c = 2.0
d_p = 0.019; d_w = 0.017; d_v = 0.015
A_c = math.pi*d_p*L_c; h_c = 254; T_f = 298.15
T_oper = 873.15; epsilon = 0.84; k_p = 24.66238342
k_l = 124.67 - 0.11381*T_oper + 5.5226e-5*T_oper**2 - 1.1842e-8*T_oper**3
print(k_l)
k_w = (  (k_l + k_p) - (1 - epsilon)*(k_l - k_p)  ) / (  (k_l + k_p) + (1 - epsilon)*(k_l - k_p)  ) * k_l
print(k_w)
######################################
T_miu_table  = [400.0, 500.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1100.0, 1200.0, 1300.0,\
            1400.0, 1500.0, 1600.0, 1700.0, 1800.0, 1900.0, 2000.0, 2100.0, 2200.0, 2300.0, \
            2400.0, 2500.0, 2503.7]
miu_table = [137.40, 143.69, 149.97, 156.26, 162.55, 168.84, 175.15, 181.51, 187.96, 194.57,\
             201.44, 208.68, 216.43, 224.85, 234.12, 244.45, 256.10, 269.45, 285.06, 304.11,\
             330.04, 414.31, 580.00]
miu_table = [x/10000000.0 for x in miu_table]
miu_v = interp1d(T_miu_table,miu_table,kind='linear',fill_value='extrapolate')
######################################
T_hfg_table = [371,  400,  500,  600,  700,  800,  900,  1000, 1100, 1200,\
               1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 2100, 2200,\
               2300, 2400, 2500, 2503.7]
hfg_table   = [4532, 4510, 4435, 4358, 4279, 4197, 4112, 4024, 3933, 3838,\
               3738, 3633, 3523, 3405, 3279, 3143, 2994, 2829, 2640, 2418,\
               2141, 1747, 652, 0]
hfg_table   = [x*1000 for x in hfg_table]
hfg = interp1d(T_hfg_table,hfg_table,kind='linear')
######################################
T_p_v_table = [370.98,  394, 400, 425, 461, 500, 504,  555.5, 600,    620,\
                  700,  701, 800, 808, 900, 954, 1000, 1100,  1156.2, 1200,\
                 1300, 1400]
p_v_table   = [1.37e-11,1.01e-10,1.61e-10,1.01e-09,1.01e-08,8.54e-08,1.01e-07,1.01e-06,5.26e-06,1.01e-05,\
               9.87e-05,1.01e-04,8.71e-04,1.01e-03,4.74e-03,1.01e-02,1.85e-02,5.77e-02,1.01e-01,1.52e-01,\
               3.37e-01,5.93e-01]
p_v_table   = [x*1000000 for x in p_v_table]
p_v = interp1d(T_p_v_table,p_v_table,kind='linear')
######################################
T_rho_v_table = [800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, \
                 1800, 1900, 2000]
rho_v_table   = [0.003, 0.017, 0.059, 0.163, 0.381, 0.779, 1.433, 2.433, 3.874, 5.857,\
                 8.485, 11.850, 16.040]
rho_v = interp1d(T_rho_v_table,rho_v_table,kind='linear')
######################################
print(rho_v(T_oper))
######################################
# p - 热管壁; w - 吸液芯; v - 蒸汽区
# e - 蒸发段; a -
r_p = d_p/2; r_w = d_w/2; r_v = d_v/2
R_p_to_w_e_r = math.log( (d_w+d_p)/2/d_w )   / (2*math.pi*k_p*L_e) + \
             math.log( d_w/((d_v+d_w)/2) ) / (2*math.pi*k_w*L_e)
R_p_i_to_c_a = (L_i/2) / (math.pi*k_p*(r_p**2 - r_w**2)) +\
             (L_c/2) / (math.pi*k_p*(r_p**2 - r_w**2))
R_w_to_p_c_r = math.log( (d_w+d_p)/2/d_w )   / (2*math.pi*k_p*L_c) + \
             math.log( d_w/((d_v+d_w)/2) ) / (2*math.pi*k_w*L_c)
R_w_e_to_i_a = (L_e/2) / (math.pi*k_w*(r_w**2 - r_v**2)) +\
             (L_i/2) / (math.pi*k_w*(r_w**2 - r_v**2))
R_w_to_v_e_r = math.log( ((d_v+d_w)/2)/d_v ) / (2*math.pi*k_w*L_e) + \
             math.sqrt( 2*math.pi*R*T_oper )*R*T_oper**2/(hfg(T_oper)**2*p_v(T_oper)*M*math.sqrt(M)*math.pi*d_v*L_e)

print("R = ",R)
print("T_oper = ",T_oper)
print("miu_v(T_oper) = ", miu_v(T_oper))
print("rho_v(T_oper) = ", rho_v(T_oper))
print("hfg(T_oper) = ",hfg(T_oper))
print("p_v(T_oper) = ",p_v(T_oper))
print("(L_e+L_i)/2 = ",(L_e+L_i)/2)
print("r_v = ",r_v)
print("M = ", M)
R_v_e_to_i_a = 8*R*T_oper**2*miu_v(T_oper)*(L_e+L_i)/2/\
             (math.pi*rho_v(T_oper)*(r_v**4)*(hfg(T_oper))**2*p_v(T_oper)*M)
R_v_i_to_c_a = 8*R*T_oper**2*miu_v(T_oper)*(L_i+L_c)/2/\
             (math.pi*rho_v(T_oper)*(r_v**4)*(hfg(T_oper))**2*p_v(T_oper)*M)
R_w_i_to_c_a = (L_i/2) / (math.pi*k_w*(r_w**2 - r_v**2)) +\
             (L_c/2) / (math.pi*k_w*(r_w**2 - r_v**2))
R_v_to_w_c_r =  math.sqrt( 2*math.pi*R*T_oper )*R*T_oper**2/(hfg(T_oper)**2*p_v(T_oper)*M*math.sqrt(M)*math.pi*d_v*L_c) +\
                math.log( ((d_w+d_v)/2)/d_v ) / (2*math.pi*k_w*L_c)
R_p_e_to_i_a = (L_e/2) / (math.pi*k_p*(r_p**2 - r_w**2)) +\
               (L_i/2) / (math.pi*k_p*(r_p**2 - r_w**2))

# //p_v(T_oper)

print("R_p_to_w_e_r = ",R_p_to_w_e_r)
print("R_p_i_to_c_a = ",R_p_i_to_c_a)
print("R_w_to_p_c_r = ",R_w_to_p_c_r)
print("R_w_e_to_i_a = ",R_w_e_to_i_a)
print("R_w_to_v_e_r = ",R_w_to_v_e_r)
print("R_v_e_to_i_a = ",R_v_e_to_i_a)
print("R_v_i_to_c_a = ",R_v_i_to_c_a)
print("R_w_i_to_c_a = ",R_w_i_to_c_a)
print("R_v_to_w_c_r = ",R_v_to_w_c_r)
print("R_p_e_to_i_a = ",R_p_e_to_i_a)

######################################
# 代数方程组例子
# 2*x + y = 5
#   x - y = 1
A = np.array([[2, 1],
              [1,-1]])

b = np.array([5, 1])

x = np.linalg.solve(A, b)

print(x)
# 太长了！不适合在矩阵里写原式！
C_1_T_w_e = 1/R_p_to_w_e_r; C_1_T_p_e = -1/R_p_to_w_e_r - 1/R_p_e_to_i_a; C_1_T_p_i = 1/R_p_e_to_i_a
C_2_T_p_e = 1/R_p_e_to_i_a; C_2_T_p_i = -1/R_p_e_to_i_a - 1/R_p_i_to_c_a; C_2_T_p_c = 1/R_p_i_to_c_a
C_3_T_w_c = 1/R_w_to_p_c_r; C_3_T_p_i = 1/R_p_i_to_c_a; C_3_T_p_c = -1/R_p_i_to_c_a - 1/R_w_to_p_c_r; C_3_T_wallc = -h_c*A_c
C_4_T_p_c = 1/(math.log(r_p/((r_p+r_w)/2))/(2*math.pi*k_p*L_c)); C_4_T_wallc = -1/(math.log(r_p/((r_p+r_w)/2))/(2*math.pi*k_p*L_c)) - h_c*A_c
C_5_T_v_e = 1/R_w_to_v_e_r; C_5_T_w_e = -1/R_p_to_w_e_r - 1/R_w_e_to_i_a - 1/R_w_to_v_e_r; C_5_T_w_i = 1/R_w_e_to_i_a; C_5_T_p_e = 1/R_p_to_w_e_r
C_6_T_w_e = 1/R_w_e_to_i_a; C_6_T_w_i = -1/R_w_e_to_i_a - 1/R_w_i_to_c_a; C_6_T_w_c = 1/R_w_i_to_c_a
C_7_T_v_c = 1/R_v_to_w_c_r; C_7_T_w_i =  1/R_w_i_to_c_a; C_7_T_w_c = -1/R_w_i_to_c_a - 1/R_w_to_p_c_r - 1/R_v_to_w_c_r; C_7_T_p_c = 1/R_w_to_p_c_r
C_8_T_v_e = -1/R_w_to_v_e_r - 1/R_v_e_to_i_a; C_8_T_v_i = 1/R_v_e_to_i_a; C_8_T_w_e = 1/R_w_to_v_e_r
C_9_T_v_e = 1/R_v_e_to_i_a; C_9_T_v_i = -1/R_v_e_to_i_a - 1/R_v_i_to_c_a; C_9_T_v_c = 1/R_v_i_to_c_a
C_10_T_v_i = 1/R_v_i_to_c_a; C_10_T_v_c = -1/R_v_i_to_c_a-1/R_v_to_w_c_r; C_10_T_w_c = 1/R_v_to_w_c_r

#                T_v_e,        T_v_i,       T_v_c,       T_w_e,     T_w_i,     T_w_c,     T_p_e,     T_p_i,     T_p_c,     T_wallc
matrix_A = [[        0,            0,           0,   C_1_T_w_e,         0,         0, C_1_T_p_e, C_1_T_p_i,         0,           0],
            [        0,            0,           0,           0,         0,         0, C_2_T_p_e, C_2_T_p_i, C_2_T_p_c,           0],
            [        0,            0,           0,           0,         0, C_3_T_w_c,         0, C_3_T_p_i, C_3_T_p_c, C_3_T_wallc],
            [        0,            0,           0,           0,         0,         0,         0,         0, C_4_T_p_c, C_4_T_wallc],
            [C_5_T_v_e,            0,           0,   C_5_T_w_e, C_5_T_w_i,         0, C_5_T_p_e,         0,         0,           0],
            [        0,            0,           0,   C_6_T_w_e, C_6_T_w_i, C_6_T_w_c,         0,         0,         0,           0],
            [        0,            0,   C_7_T_v_c,           0, C_7_T_w_i, C_7_T_w_c,         0,         0, C_7_T_p_c,           0],
            [C_8_T_v_e,    C_8_T_v_i,           0,   C_8_T_w_e,         0,         0,         0,         0,         0,           0],
            [C_9_T_v_e,    C_9_T_v_i,   C_9_T_v_c,           0,         0,         0,         0,         0,         0,           0],
            [        0,   C_10_T_v_i,  C_10_T_v_c,           0,         0,C_10_T_w_c,         0,         0,         0,           0]]
matrix_b =  [   -Q_in,             0,-h_c*A_c*T_f,-h_c*A_c*T_f,         0,         0,         0,         0,         0,           0]

T_vector = np.linalg.solve( np.array(matrix_A), np.array(matrix_b))

print("T_vector = ", T_vector)
T_v_e = T_vector[0]
T_v_i = T_vector[1]
T_v_c = T_vector[2]

T_w_e = T_vector[3]
T_w_i = T_vector[4]
T_w_c = T_vector[5]

T_p_e = T_vector[6]
T_p_i = T_vector[7]
T_p_c = T_vector[8]
T_wallc = T_vector[9]
print("T_v_e = ",T_v_e)
print("T_v_i = ",T_v_i)
print("T_v_c = ",T_v_c)
print("T_w_e = ",T_w_e)
print("T_w_i = ",T_w_i)
print("T_w_c = ",T_w_c)
print("T_p_e = ",T_p_e)
print("T_p_i = ",T_p_i)
print("T_p_c = ",T_p_c)
print("T_wallc = ",T_wallc)

# 1
print(Q_in + T_w_e/R_p_to_w_e_r - T_p_e/R_p_to_w_e_r + T_p_i/R_p_e_to_i_a - T_p_e/R_p_e_to_i_a)
# 2
print(T_p_e/R_p_e_to_i_a - T_p_i/R_p_e_to_i_a + T_p_c/R_p_i_to_c_a - T_p_i/R_p_i_to_c_a)
# 3
print(T_p_i/R_p_i_to_c_a - T_p_c/R_p_i_to_c_a + T_w_c/R_w_to_p_c_r - T_p_c/R_w_to_p_c_r - h_c*A_c*(T_wallc-T_f))
# 4
print(h_c*A_c*(T_wallc - T_f))
print( - (T_p_c-T_wallc)/(  math.log( r_p/((r_p+r_w)/2) )/(2*math.pi*k_p*L_c))  )
# 5
print(T_p_e/R_p_to_w_e_r - T_w_e/R_p_to_w_e_r + T_w_i/R_w_e_to_i_a - T_w_e/R_w_e_to_i_a + T_v_e/R_w_to_v_e_r - T_w_e/R_w_to_v_e_r)
# 6
print(T_w_e/R_w_e_to_i_a - T_w_i/R_w_e_to_i_a + T_w_c/R_w_i_to_c_a - T_w_i/R_w_i_to_c_a)
# 7
print(T_w_i/R_w_i_to_c_a - T_w_c/R_w_i_to_c_a + T_p_c/R_w_to_p_c_r - T_w_c/R_w_to_p_c_r + T_v_c/R_v_to_w_c_r - T_w_c/R_v_to_w_c_r)
# 8
print(T_w_e/R_w_to_v_e_r - T_v_e/R_w_to_v_e_r + T_v_i/R_v_e_to_i_a - T_v_e/R_v_e_to_i_a)
# 9
print(T_v_e/R_v_e_to_i_a - T_v_i/R_v_e_to_i_a + T_v_c/R_v_i_to_c_a - T_v_i/R_v_i_to_c_a)
print(C_9_T_v_e*T_v_e+C_9_T_v_i*T_v_i+C_9_T_v_c*T_v_c)
######################################
print("Q_in = ", Q_in)

print("Q_p_a_1 = ", (T_p_e - T_p_i)/R_p_e_to_i_a)
print("Q_p_a_2 = ", (T_p_i - T_p_c)/R_p_i_to_c_a)

print("Q_w_a_1 = ", (T_w_e - T_w_i)/R_w_e_to_i_a)
print("Q_w_a_2 = ", (T_w_i - T_w_c)/R_w_i_to_c_a)

print("Q_w_e_1 = ", (T_v_e - T_v_i)/R_v_e_to_i_a)
print("Q_w_e_2 = ", (T_v_i - T_v_c)/R_v_i_to_c_a)

print("Q_p_to_w_e_r = ", (T_p_e - T_w_e)/R_p_to_w_e_r)
print("Q_w_to_p_c_r = ", (T_w_c - T_p_c)/R_w_to_p_c_r)
print(Q_in - (T_p_e - T_w_e)/R_p_to_w_e_r - (T_p_e - T_p_i)/R_p_e_to_i_a)
