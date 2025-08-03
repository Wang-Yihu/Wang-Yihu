# 见20230620-热管堆系统典型设计参数报告.docx
# 没有采信回热器热侧出口温度399.4 ℃
# 各处压损设置为0
# 相关公式见MOOSE Thermal Hydraulic
import math
from scipy.optimize import fsolve
from scipy.interpolate import interp1d
from scipy.optimize import brentq

#          6
#          |
# 1--C--2--R--3--H--4--T
#          |           |
#          5-----------|
# Input parameters
#In fact, 48 variables and 52 equations, we need to add 4 variables' condition to solve them!
#For MOOSE, we always know p0_1, T0_1, p_6, and ω.
#compressor, 22 variables,18 equations
#variables: (1~22)
#s_1, h0_1, T_1, p_1, v_1, u_1
#p0_1, v0_1, T0_1, c0_1
#p0_2, v0_2_is, T0_2_is, h0_2_is
#h0_2, T_2, p_2, v_2, u_2
#τ_c
#ω, m_dot
#Equations：
#Eq 1: s_1 = cv * ln( T_1^γ / p_1^(γ-1) )
#Eq 2: p_1 * v_1 = R/M * T_1
#Eq 3: u_1 = m_dot * v_1 / A_1
#Eq 4: h0_1 = cp * T_1 + 0.5 * u_1^2
#Eq 5: p0_1 = (h0_1 / γ / cv)^(γ / (γ-1)) * exp(-s_1 / (γ-1) /cv)
#Eq 6: v0_1 = R / M / p0_1 * exp( (s_1+cv * (γ-1) * lnp0_1) / γ / cv )
#Eq 7: T0_1 = p0_1 * v0_1 * M / R
#Eq 8: c0_1 = sqrt(γ * R * T0_1 / M)
#Eq 9: p0_2 = p0_1 * Rp_c( m_dot * v0_1 / c0_1 / (rated), ω / c0_1 / (rated) )
#Eq 10: v0_2_is = R / M / p0_2 * exp( (s_1 + cv * (γ-1) * lnp0_2) / γ / cv )
#Eq 11: T0_2_is = p0_2 * v0_2_is * M / R
#Eq 12: h0_2_is = cv * T0_2_is + p0_2 * v0_2_is
#Eq 13: h0_2 = (h0_2_is - h0_1 +ηc * h0_1) / ηc
#Eq 14: τ_c = -m_dot / ω * (h0_2 - h0_1)
#Eq 15: (u_1^2 / v_1 + p_1) * A_1 - (u_2^2 / v_2 + p_2) * A_2 + (p0_2 - p0_1) *A_refc = 0
#Eq 16: h0_2 = cp * T_2 + 0.5 * u_2^2
#Eq 17: p_2 * v_2 = R/M * T_2
#Eq 18: u_2 = m_dot * v_2/A_2
#####################################################################
#recuperator, add 15 variables, 12 equations
#variables:(23~37)
#h0_3, T_3, p_3, v_3, u_3
#h0_5, T_5, p_5, v_5, u_5
#h0_6, T_6, p_6, v_6, u_6
#Equations：
#Eq 19: p_3 = p_2
#Eq 20: p_5 = p_6
#Eq 21: h0_3 - h0_2 = h0_5 - h0_6
#Eq 22: p_3 * v_3 = R/M * T_3
#Eq 23: p_5 * v_5 = R/M * T_5
#Eq 24: p_6 * v_6 = R/M * T_6
#Eq 25: h0_3 = cp * T_3 + 0.5 * u_3^2
#Eq 26: h0_5 = cp * T_5 + 0.5 * u_5^2
#Eq 27: h0_6 = cp * T_6 + 0.5 * u_6^2
#Eq 28: u_3 = m_dot * v_3/A_3
#Eq 29: u_5 = m_dot * v_5/A_5
#Eq 30: u_6 = m_dot * v_6/A_6
#####################################################################
#Heat Source, add 5 variables，5 equations
#variables: (38~42)
#h0_4, T_4, p_4, v_4, u_4
#equations：
#Eq 31: p_4 = p_3
#Eq 32: h0_4 = (m_dot * h0_3 + Q) / m_dot
#Eq 33: p_4 * v_4 = R/M * T_4
#Eq 34: h0_4 = cp * T_4 + 0.5 * u_4^2
#Eq 35: u_4 = m_dot * v_4/A_4
#####################################################################
#Turbine, add 10 variables, 12 equations
#variables：(43~52)
#s_4
#p0_4, v0_4, T0_4, c0_4
#p0_5, v0_5_is, T0_5_is, h0_5_is
#τ_t
#equations：
#Eq 36: s_4 = cv * ln( T_4^γ / p_4^(γ-1) )
#Eq 37: p0_4 = (h0_4 / γ / cv)^(γ / (γ-1)) * exp(-s_4 / (γ-1) /cv)
#Eq 38: v0_4 = R / M / p0_4 * exp( (s_4+cv * (γ-1) * lnp0_4) / γ / cv )
#Eq 39: T0_4 = p0_4 * v0_4 * M / R
#Eq 40: c0_4 = sqrt(γ * R * T0_4 / M)
#Eq 41: p0_5 = p0_4 * (  Rp_t( m_dot * v0_4 / c0_4 / (rated), ω / c0_4 / (rated) )  )^(-1)
#Eq 42: v0_5_is = R / M / p0_5 * exp( (s_4 + cv * (γ-1) * lnp0_5) / γ / cv )
#Eq 43: T0_5_is = p0_5 * v0_5_is * M / R
#Eq 44: h0_5_is = cv * T0_5_is + p0_5 * v0_5_is
#Eq 45: h0_5 = ηt * h0_5_is - ηt * h0_4 + h0_4
#Eq 46: τ_t = -m_dot / ω * (h0_5 - h0_4)
#Eq 47: (u_4^2 / v_4 + p_4) * A_4 - (u_5^2 / v_5 + p_5) * A_5 + (p0_5 - p0_4) *A_reft = 0
#####################################################################
#shaft, add 1 equation
#Eq 48: τ_c + τ_t + fω = 0
# compressor curve
def interpolate_2d_comp(x_input, y_input):
    # Table data: y: ([x values], [z values])
    # y for omega, x for mdot, z for Rp
    table = {
        0.5208: (
        [0.2868480, 0.3084640, 0.3300760, 0.3516920, 0.3733040, 0.3949200, 0.4165200, 0.4381600, 0.4597600, 0.4813600,
         0.5030000, 0.5187200],
        [1.5153000, 1.5088000, 1.5032000, 1.4984000, 1.4914000, 1.4863000, 1.4846000, 1.4756000, 1.4540000, 1.4237000,
         1.3856000, 1.3506000]),

        0.6250: (
        [0.3674120, 0.3890240, 0.4106400, 0.4322400, 0.4523200, 0.4754800, 0.4970800, 0.5177200, 0.5442400, 0.5658800,
         0.5874800, 0.6090800, 0.6307200, 0.6484000, 0.6621600, 0.6759200, 0.6886800, 0.6994800, 0.7093200, 0.7181600,
         0.7253600, 0.7338800, 0.7407600, 0.7466400, 0.7517600, 0.7595600, 0.7633600],
        [1.7741000, 1.7626000, 1.7550000, 1.7536000, 1.7497000, 1.7455000, 1.7376000, 1.7276000, 1.7026000, 1.6780000,
         1.6405000, 1.5914000, 1.5233000, 1.4564000, 1.3890000, 1.3187000, 1.2318000, 1.1631000, 1.0851000, 1.0143000,
         0.9425300, 0.8601900, 0.7844300, 0.7160400, 0.6450700, 0.5733400, 0.5341100]),

        0.7292: (
        [0.4067200, 0.4283200, 0.4499200, 0.4715600, 0.4931600, 0.5147600, 0.5364000, 0.5580000, 0.5796400, 0.6012400,
         0.6228400, 0.6444800, 0.6660800, 0.6872000, 0.7093200, 0.7299200, 0.7476400, 0.7643200, 0.7800400, 0.7928000,
         0.8036400, 0.8134400, 0.8222800, 0.8301600, 0.8380000, 0.8448800, 0.8507600, 0.8566800, 0.8635600, 0.8704400,
         0.8782800],
        [2.1535000, 2.1352000, 2.1251000, 2.1192000, 2.1135000, 2.1088000, 2.1071000, 2.1068000, 2.1043000, 2.0975000,
         2.0877000, 2.0742000, 2.0539000, 2.0272000, 1.9813000, 1.9245000, 1.8643000, 1.7959000, 1.7227000, 1.6551000,
         1.5896000, 1.5110000, 1.4403000, 1.3714000, 1.2969000, 1.2326000, 1.1655000, 1.0985000, 1.0177000, 0.9385600,
         0.8578700]),

        0.8333: (
        [0.4872800, 0.5088800, 0.5304800, 0.5521200, 0.5737200, 0.5953600, 0.6169600, 0.6385600, 0.6602000, 0.6818000,
         0.7034000, 0.7250400, 0.7466400, 0.7682400, 0.7898800, 0.8114800, 0.8330800, 0.8547200, 0.8753600, 0.8940000,
         0.9097200, 0.9224800, 0.9342800, 0.9450800, 0.9568800],
        [2.6634000, 2.6485000, 2.6366000, 2.6248000, 2.6184000, 2.6124000, 2.6110000, 2.6102000, 2.6110000, 2.6102000,
         2.6110000, 2.6099000, 2.6060000, 2.5989000, 2.5874000, 2.5642000, 2.5309000, 2.4824000, 2.4202000, 2.3500000,
         2.2832000, 2.2195000, 2.1437000, 2.0706000, 1.9947000]),

        0.9375: (
        [0.5658800, 0.5874800, 0.6090800, 0.6307200, 0.6523200, 0.6739200, 0.6955600, 0.7171600, 0.7387600, 0.7604000,
         0.7820000, 0.8036400, 0.8252400, 0.8468400, 0.8684800, 0.8900800, 0.9116800, 0.9333200, 0.9549200, 0.9765200,
         0.9981600, 1.0197600, 1.0413600, 1.0600400, 1.0757600, 1.0904800, 1.1032800, 1.1150800, 1.1248800, 1.1327600,
         1.1406000, 1.1484800, 1.1563200, 1.1632000, 1.1690800, 1.1750000, 1.1808800, 1.1867600, 1.1916800, 1.1976000],
        [3.4718000, 3.4428000, 3.4189000, 3.3970000, 3.3728000, 3.3455000, 3.3249000, 3.3106000, 3.2976000, 3.2886000,
         3.2819000, 3.2799000, 3.2844000, 3.2892000, 3.2898000, 3.2892000, 3.2889000, 3.2830000, 3.2703000, 3.2551000,
         3.2281000, 3.1873000, 3.1291000, 3.0660000, 2.9999000, 2.9281000, 2.8556000, 2.7823000, 2.7101000, 2.6451000,
         2.5778000, 2.5099000, 2.4280000, 2.3562000, 2.2850000, 2.2128000, 2.1344000, 2.0580000, 1.9920000, 1.9198000]),
    }

    y_list = sorted(table.keys())
    z_y_interp = []

    for y in y_list:
        x_vals, z_vals = table[y]
        f = interp1d(x_vals, z_vals, kind='linear', fill_value='extrapolate')
        z_y_interp.append(f(x_input))

    f_y = interp1d(y_list, z_y_interp, kind='linear', fill_value='extrapolate')
    return float(f_y(y_input))
########################################################
# turbine curve
def interpolate_2d_turb(x_input, y_input):
    # Table data:y: ([x values], [z values])
    # y for omega, x for mdot, z for Rp
    table = {
        0.0: ([0.0000000, 1.000000],
              [1.0000000, 1.000000]),

        0.5208: (
        [0.2082520, 0.2298640, 0.2514800, 0.2730960, 0.2947080, 0.3163240, 0.3385240, 0.3595520, 0.3811640, 0.4018000,
         0.4188400, 0.4327600, 0.4434800, 0.4511200, 0.4578000, 0.4648800, 0.4676400, 0.4794000],
        [1.1197000, 1.1292000, 1.1423000, 1.1599000, 1.1751000, 1.1934000, 1.2179000, 1.2523000, 1.2972000, 1.3575000,
         1.4183000, 1.4967000, 1.5555000, 1.6311000, 1.7075000, 1.7896000, 1.8465000, 1.9957000]),

        0.6250: (
        [0.3674120, 0.3890240, 0.4106400, 0.4322400, 0.4538800, 0.4705600, 0.4922000, 0.5079200, 0.5196800, 0.5275600,
         0.5354000, 0.5422800, 0.5491600, 0.5590000],
        [1.2029000, 1.2314000, 1.2615000, 1.2993000, 1.3482000, 1.3956000, 1.4717000, 1.5365000, 1.6164000, 1.6763000,
         1.7622000, 1.8331000, 1.9107000, 1.9973000]),

        0.7292: (
        [0.4894400, 0.5080800, 0.5342000, 0.5514400, 0.5776400, 0.5953600, 0.6161200, 0.6299200, 0.6395600, 0.6503600,
         0.6592000, 0.6660800, 0.6700000, 0.6778800, 0.6818000, 0.6876800, 0.6916400, 0.6960400, 0.6994800, 0.7034000,
         0.7102800, 0.7112800, 0.7132400, 0.7171600],
        [1.2856000, 1.3172000, 1.3532000, 1.3853000, 1.4625000, 1.5312000, 1.6149000, 1.6750000, 1.7413000, 1.8149000,
         1.8875000, 1.9559000, 2.0013000, 2.1282000, 2.2221000, 2.3390000, 2.4564000, 2.6010000, 2.7379000, 2.8729000,
         3.1802000, 3.2705000, 3.3605000, 3.4468000]),

        0.8333: (
        [0.6071200, 0.6287600, 0.6493600, 0.6759200, 0.6975200, 0.7191200, 0.7407600, 0.7604000, 0.7741600, 0.7888800,
         0.7996800, 0.8085200, 0.8164000, 0.8232800, 0.8291600, 0.8350800, 0.8390000, 0.8422800, 0.8478400, 0.8511600,
         0.8547200, 0.8586400, 0.8635600, 0.8664800, 0.8684800, 0.8694400, 0.8724000, 0.8733600, 0.8763200, 0.8792800],
        [1.3228000, 1.3484000, 1.3735000, 1.4176000, 1.4604000, 1.5073000, 1.5648000, 1.6329000, 1.6868000, 1.7667000,
         1.8383000, 1.9146000, 1.9866000, 2.0642000, 2.1375000, 2.2102000, 2.2992000, 2.3995000, 2.5516000, 2.6760000,
         2.8060000, 2.9616000, 3.1321000, 3.2404000, 3.3299000, 3.4034000, 3.4827000, 3.5489000, 3.6441000, 3.7392000]),

        0.9375: (
        [0.6975200, 0.7191200, 0.7407600, 0.7623600, 0.7839600, 0.8056000, 0.8304800, 0.8488000, 0.8704400, 0.8920400,
         0.9136400, 0.9352800, 0.9549200, 0.9716400, 0.9853600, 0.9971600, 1.0079600, 1.0168000, 1.0244800, 1.0296000,
         1.0364800, 1.0404000, 1.0443200, 1.0459600, 1.0480400, 1.0492400, 1.0531600, 1.0576400, 1.0610400, 1.0639600,
         1.0669200, 1.0705600, 1.0736000, 1.0755600, 1.0787200],
        [1.2932000, 1.3060000, 1.3271000, 1.3501000, 1.3780000, 1.4050000, 1.4415000, 1.4684000, 1.5015000, 1.5409000,
         1.5900000, 1.6541000, 1.7158000, 1.7865000, 1.8472000, 1.9161000, 1.9997000, 2.0694000, 2.1477000, 2.2175000,
         2.2945000, 2.3562000, 2.4547000, 2.5110000, 2.5962000, 2.6544000, 2.8277000, 2.9733000, 3.1269000, 3.1945000,
         3.3560000, 3.4621000, 3.5716000, 3.6771000, 3.8214000]),
    }

    y_list = sorted(table.keys())
    z_y_interp = []

    for y in y_list:
        x_vals, z_vals = table[y]
        f = interp1d(x_vals, z_vals, kind='linear', fill_value='extrapolate')
        z_y_interp.append(f(x_input))

    f_y = interp1d(y_list, z_y_interp, kind='linear', fill_value='extrapolate')
    return float(f_y(y_input))
#####################################################################
Q_reactor = 1000000; W_generator = 207000
M = 0.029; R = 8.314; gamma = 1.4; cv = 1/(gamma-1)*R/M; cp = gamma*cv
m_dot = 4.34; omega = 96000 * 2 * math.pi / 60.0
A_1 = math.pi/4*0.3**2; A_2 = math.pi/4*0.3**2; A_3 = math.pi/4*0.3**2
A_4 = math.pi/4*0.3**2; A_5 = math.pi/4*0.3**2; A_6 = math.pi/4*0.3**2
A_c = (A_1+A_2)/2; A_t = (A_4+A_5)/2
eff_c = 0.79
T_1 = 25.0+273.15; p_1 = 101325.0
p_3 = 360000.0
#T_4 = 610 + 273.15
T_4 = 610 + 273.15
p_6 = 101325.0
f_generator = -W_generator/omega/omega
c0_rated_c = 351.6925137; c0_rated_t = 351.6925137
rho0_rated_c = 1.146881112; rho0_rated_t = 1.146881112
omega_rated_c = 96000 * 2 * math.pi / 60.0; omega_rated_t = 96000 * 2 * math.pi / 60.0
#print(f_generator)
####################################################################
# Eq 1 ~ Eq 8
s_1 = cv * math.log( T_1**gamma / p_1**(gamma-1) )
v_1 = R/M * T_1/p_1
u_1 = m_dot * v_1 / A_1
h0_1 = cp * T_1 + 0.5 * u_1**2
p0_1 = (h0_1 / gamma / cv)**(gamma / (gamma-1)) * math.exp(-s_1 / (gamma-1) /cv)
v0_1 = R / M / p0_1 * math.exp( (s_1+cv * (gamma-1) * math.log(p0_1)) / gamma / cv ); rho0_1 = 1/v0_1
T0_1 = p0_1 * v0_1 * M / R
c0_1 = math.sqrt(gamma * R * T0_1 / M)
# Eq 19
p_2 = p_3

last_iteration_results_assume_p0_2 = {}
def assume_p0_2(vars):
    global last_iteration_results_assume_p0_2
    p0_2 = vars[0]
    # Eq 10 ~ Eq 14
    v0_2_is = R / M / p0_2 * math.exp((s_1 + cv * (gamma - 1) * math.log(p0_2)) / gamma / cv)
    T0_2_is = p0_2 * v0_2_is * M / R
    h0_2_is = cv * T0_2_is + p0_2 * v0_2_is
    h0_2 = (h0_2_is - h0_1 + eff_c * h0_1) / eff_c
    tau_c = -m_dot/omega*(h0_2 - h0_1)
    # Eq 16 ~ Eq 18
    a_eq_16 = 0.5 * m_dot ** 2 * R ** 2 / A_2 ** 2 / M ** 2 / p_2 ** 2
    b_eq_16 = cp
    c_eq_16 = -h0_2
    delta_eq_16 = b_eq_16**2 - 4*a_eq_16*c_eq_16
    T_2 = (-b_eq_16 + math.sqrt(delta_eq_16)) / 2 / a_eq_16
    u_2 = math.sqrt(2 * (h0_2 - cp * T_2))
    v_2 = u_2 * A_2 / m_dot
    # Eq 15
    err = (u_1 ** 2 / v_1 + p_1) * A_1 - (u_2 ** 2 / v_2 + p_2) * A_2 + (p0_2 - p0_1) * A_c
    last_iteration_results_assume_p0_2 = {
        "v0_2_is":v0_2_is, "T0_2_is":T0_2_is, "h0_2_is":h0_2_is, "h0_2":h0_2, "tau_c":tau_c,
        "T_2":T_2, "u_2":u_2, "v_2":v_2, "tau_c":tau_c
    }
    return [err]


result =  fsolve(assume_p0_2, [p_2])
p0_2 = result[0]
v0_2_is = last_iteration_results_assume_p0_2["v0_2_is"]
T0_2_is = last_iteration_results_assume_p0_2["T0_2_is"]
h0_2_is = last_iteration_results_assume_p0_2["h0_2_is"]
h0_2 = last_iteration_results_assume_p0_2["h0_2"]
T_2 = last_iteration_results_assume_p0_2["T_2"]
u_2 = last_iteration_results_assume_p0_2["u_2"]
v_2 = last_iteration_results_assume_p0_2["v_2"]
tau_c = last_iteration_results_assume_p0_2["tau_c"]

# Eq 31
p_4 = p_3

# Eq 31 ~ 35
v_4 = R/M*T_4/p_4
u_4 = m_dot*v_4/A_4
h0_4 = cp*T_4 + 0.5*u_4**2
h0_3 = (m_dot*h0_4 - Q_reactor)/m_dot
p_4 = p_3

# Eq 22, 25, 28
a_eq_25 = 0.5 * m_dot ** 2 * R ** 2 / A_3 ** 2 / M ** 2 / p_3 ** 2
b_eq_25 = cp
c_eq_25 = -h0_3
delta_eq_25 = b_eq_25 ** 2 - 4 * a_eq_25 * c_eq_25
T_3 = (-b_eq_25 + math.sqrt(delta_eq_25)) / 2 / a_eq_25
u_3 = math.sqrt(2 * (h0_3 - cp * T_3))
v_3 = u_3 * A_2 / m_dot

# Eq 48, Eq 46
tau_t = -tau_c - f_generator*omega
h0_5 = -omega/m_dot*tau_t + h0_4

#Eq 20
p_5 = p_6

#Eq 23, 26, 29
a_eq_26 = 0.5 * m_dot ** 2 * R ** 2 / A_5 ** 2 / M ** 2 / p_5 ** 2
b_eq_26 = cp
c_eq_26 = -h0_5
delta_eq_26 = b_eq_26 ** 2 - 4 * a_eq_26 * c_eq_26
T_5 = (-b_eq_26 + math.sqrt(delta_eq_26)) / 2 / a_eq_26
u_5 = math.sqrt(2 * (h0_5 - cp * T_5))
v_5 = u_5 * A_5 / m_dot

# Eq 36 ~ 40
s_4 = cv * math.log( T_4**gamma / p_4**(gamma-1) )
p0_4 = (h0_4 / gamma / cv)**(gamma / (gamma-1)) * math.exp(-s_4 / (gamma-1) /cv)
v0_4 = R / M / p0_4 * math.exp( (s_4+cv * (gamma-1) * math.log(p0_4)) / gamma / cv ); rho0_4 = 1/v0_4
T0_4 = p0_4 * v0_4 * M / R
c0_4 = math.sqrt(gamma * R * T0_4 / M)

# Eq 47
p0_5 = (  (u_5**2 / v_5 + p_5) * A_5 - (u_4**2 / v_4 + p_4) * A_4  )/A_t + p0_4

# Eq 42 ~ 45
v0_5_is = R / M / p0_5 * math.exp((s_4 + cv * (gamma - 1) * math.log(p0_5)) / gamma / cv)
T0_5_is = p0_5 * v0_5_is * M / R
h0_5_is = cv * T0_5_is + p0_5 * v0_5_is
eff_t = (h0_5-h0_4)/(h0_5_is-h0_4)

# Eq 21
h0_6 = h0_5 - h0_3 + h0_2

# Eq 24, 27, 30
a_eq_27 = 0.5 * m_dot ** 2 * R ** 2 / A_6 ** 2 / M ** 2 / p_6 ** 2
b_eq_27 = cp
c_eq_27 = -h0_6
delta_eq_27 = b_eq_27 ** 2 - 4 * a_eq_27 * c_eq_27
T_6 = (-b_eq_27 + math.sqrt(delta_eq_27)) / 2 / a_eq_27
u_6 = math.sqrt(2 * (h0_6 - cp * T_6))
v_6 = u_6 * A_6 / m_dot

print("====================================")
print("T_1 = %s"%(T_1), end='; ')
print("p_1 = %s"%(p_1), end='; ')
print("h0_1 = %s"%(h0_1), end='; ')
print("v_1 = %s"%(v_1), end='; ')
print("u_1 = %s"%(u_1), )
print("====================================")
print("T_2 = %s"%(T_2), end='; ')
print("p_2 = %s"%(p_2), end='; ')
print("h0_2 = %s"%(h0_2), end='; ')
print("v_2 = %s"%(v_2), end='; ')
print("u_2 = %s"%(u_2))
print("====================================")
print("T_3 = %s"%(T_3), end='; ')
print("p_3 = %s"%(p_3), end='; ')
print("h0_3 = %s"%(h0_3), end='; ')
print("v_3 = %s"%(v_3), end='; ')
print("u_3 = %s"%(u_3))
print("====================================")
print("T_4 = %s"%(T_4), end='; ')
print("p_4 = %s"%(p_4), end='; ')
print("h0_4 = %s"%(h0_4), end='; ')
print("v_4 = %s"%(v_4), end='; ')
print("u_4 = %s"%(u_4))
print("====================================")
print("T_5 = %s"%(T_5), end='; ')
print("p_5 = %s"%(p_5), end='; ')
print("h0_5 = %s"%(h0_5), end='; ')
print("v_5 = %s"%(v_5), end='; ')
print("u_5 = %s"%(u_5))
print("====================================")
print("T_6 = %s"%(T_6), end='; ')
print("p_6 = %s"%(p_6), end='; ')
print("h0_6 = %s"%(h0_6), end='; ')
print("v_6 = %s"%(v_6), end='; ')
print("u_6 = %s"%(u_6))
print("====================================")
print("T0_1 = %s"%(T0_1), end='; ')
print("p0_1 = %s"%(p0_1), end='; ')
print("eff_t = %s"%(eff_t))
####################################################################
c0_rated_c = 351.6925137; c0_rated_t = 351.6925137
rho0_rated_c = 1.146881112; rho0_rated_t = 1.146881112
omega_rated_c = 96000 * 2 * math.pi / 60.0; omega_rated_t = 96000 * 2 * math.pi / 60.0
# m_dot_rated_c = 0.25; m_dot_rated_t = 0.25
def assume_m_dot_rated_c(m_dot_rated_c):
    rel_corrected_flow_c = (m_dot / rho0_1 / c0_1) / (m_dot_rated_c / rho0_rated_c / c0_rated_c)
    rel_corrected_speed_c = (omega / c0_1) / (omega_rated_c / c0_rated_c)
    return p0_2/p0_1 - interpolate_2d_comp(rel_corrected_flow_c, rel_corrected_speed_c)

m_dot_rated_c = brentq(assume_m_dot_rated_c, 0.01*m_dot, 100*m_dot)
print("m_dot_rated_c = %s"%(m_dot_rated_c))

def assume_m_dot_rated_t(m_dot_rated_t):
    rel_corrected_flow_t = (m_dot / rho0_4 / c0_4) / (m_dot_rated_t / rho0_rated_t / c0_rated_t)
    rel_corrected_speed_t = (omega / c0_4) / (omega_rated_t / c0_rated_t)
    return p0_4/p0_5 - interpolate_2d_turb(rel_corrected_flow_t, rel_corrected_speed_t)

m_dot_rated_t = brentq(assume_m_dot_rated_t, 0.01*m_dot, 100*m_dot)
print("m_dot_rated_t = %s"%(m_dot_rated_t))
print("tau_c = %s"%(tau_c),end='; ');print("tau_t = %s"%(tau_t))
####################################################################


# Checking equations
error_1 = (  s_1 - cv * math.log( T_1**gamma / p_1**(gamma-1) )  )/s_1
error_2 = (p_1 - R/M * T_1/v_1)/p_1
error_3 = (u_1 - m_dot * v_1 / A_1)/u_1
error_4 = (  h0_1 - (cp * T_1 + 0.5 * u_1**2)  )/h0_1
error_5 = (  p0_1 - (h0_1 / gamma / cv)**(gamma / (gamma-1)) * math.exp(-s_1 / (gamma-1) /cv)  )/p0_1
error_6 = (  v0_1 - R / M / p0_1 * math.exp( (s_1+cv * (gamma-1) * math.log(p0_1)) / gamma / cv )  )/v0_1
error_7 = (  T0_1 - p0_1 * v0_1 * M / R  )/T0_1
error_8 = (  c0_1 - math.sqrt(gamma * R * T0_1 / M)  )/c0_1
error_9 = (p0_2/p0_1 - interpolate_2d_comp((m_dot / rho0_1 / c0_1) / (m_dot_rated_c / rho0_rated_c / c0_rated_c), \
(omega / c0_1) / (omega_rated_c / c0_rated_c))) /(p0_2/p0_1)
error_10 = v0_2_is - R / M / p0_2 * math.exp( (s_1 + cv * (gamma-1) * math.log(p0_2)) / gamma / cv )
error_11 = (T0_2_is - p0_2 * v0_2_is * M / R)/T0_2_is
error_12 = (h0_2_is - (cv * T0_2_is + p0_2 * v0_2_is))/h0_2_is
error_13 = (  h0_2 - (h0_2_is - h0_1 +eff_c * h0_1) / eff_c  )
error_14 = (  tau_c - (-m_dot / omega * (h0_2 - h0_1))  )/tau_c
error_15 = (  (u_1**2 / v_1 + p_1) * A_1 - (u_2**2 / v_2 + p_2) * A_2 + (p0_2 - p0_1) *A_c  )/((p0_2 - p0_1) *A_c )
error_16 = (h0_2 - (cp * T_2 + 0.5 * u_2**2))/h0_2
error_17 = (p_2 * v_2 - R/M * T_2)/(p_2 * v_2)
error_18 = (u_2 - m_dot * v_2/A_2)/u_2
error_19 = (p_3 - p_2)/p_3
error_20 = (p_5 - p_6)/p_5
error_21 = (  h0_3 - h0_2 - (h0_5 - h0_6)  )/(h0_5 - h0_6)
error_22 = (p_3 * v_3 - R/M * T_3)/(p_3 * v_3)
error_23 = (p_5 * v_5 - R/M * T_5)/(p_5 * v_5)
error_24 = (p_6 * v_6 - R/M * T_6)/(p_6 * v_6)
error_25 = (h0_3 - (cp * T_3 + 0.5 * u_3**2))/h0_3
error_26 = (h0_5 - (cp * T_5 + 0.5 * u_5**2))/h0_5
error_27 = (h0_6 - (cp * T_6 + 0.5 * u_6**2))/h0_6
error_28 = (u_3 - m_dot * v_3/A_3)/u_3
error_29 = (u_5 - m_dot * v_5/A_5)/u_5
error_30 = (u_6 - m_dot * v_6/A_6)/u_6
error_31 = (p_4 - p_3)/p_4
error_32 = (h0_4 - (m_dot * h0_3 + Q_reactor) / m_dot)/h0_4
error_33 = (p_4 * v_4 - R/M * T_4)/p_4 * v_4
error_34 = (h0_4 - (cp * T_4 + 0.5 * u_4**2))/h0_4
error_35 = (u_4 - m_dot * v_4/A_4)/u_4
error_36 = s_4 - cv * math.log( T_4**gamma / p_4**(gamma-1) )
error_37 = (p0_4 - (h0_4 / gamma / cv)**(gamma / (gamma-1)) * math.exp(-s_4 / (gamma-1) /cv))/p0_4
error_38 = (v0_4 - R / M / p0_4 * math.exp( (s_4+cv * (gamma-1) * math.log(p0_4)) / gamma / cv ))/v0_4
error_39 = (T0_4 - p0_4 * v0_4 * M / R)/T0_4
error_40 = (c0_4 - math.sqrt(gamma * R * T0_4 / M))/c0_4
error_41 =  (p0_4/p0_5 - interpolate_2d_turb((m_dot / rho0_4 / c0_4) / (m_dot_rated_t / rho0_rated_t / c0_rated_t), \
(omega / c0_4) / (omega_rated_t / c0_rated_t))) /(p0_4/p0_5)
error_42 = (v0_5_is - R / M / p0_5 * math.exp( (s_4 + cv * (gamma-1) * math.log(p0_5)) / gamma / cv ))/v0_5_is
error_43 = (T0_5_is - p0_5 * v0_5_is * M / R)/T0_5_is
error_44 = (h0_5_is - (cv * T0_5_is + p0_5 * v0_5_is))/h0_5_is
error_45 = (h0_5 - (eff_t * h0_5_is - eff_t * h0_4 + h0_4))/h0_5
error_46 = (tau_t - (-m_dot / omega * (h0_5 - h0_4)))/tau_t
error_47 = ((u_4**2 / v_4 + p_4) * A_4 - (u_5**2 / v_5 + p_5) * A_5 + (p0_5 - p0_4) *A_t)/((p0_5 - p0_4) *A_t)
error_48 = (tau_c + tau_t + f_generator*omega )/f_generator*omega
print("=======output errors=============")
print("error_1 = %s"%(error_1))
print("error_2 = %s"%(error_2))
print("error_3 = %s"%(error_3))
print("error_4 = %s"%(error_4))
print("error_5 = %s"%(error_5))
print("error_6 = %s"%(error_6))
print("error_7 = %s"%(error_7))
print("error_8 = %s"%(error_8))
print("error_9 = %s"%(error_9))
print("error_10 = %s"%(error_10))
print("error_11 = %s"%(error_11))
print("error_12 = %s"%(error_12))
print("error_13 = %s"%(error_13))
print("error_14 = %s"%(error_14))
print("error_15 = %s"%(error_15))
print("error_16 = %s"%(error_16))
print("error_17 = %s"%(error_17))
print("error_18 = %s"%(error_18))
print("error_19 = %s"%(error_19))
print("error_20 = %s"%(error_20))
print("error_21 = %s"%(error_21))
print("error_22 = %s"%(error_22))
print("error_23 = %s"%(error_23))
print("error_24 = %s"%(error_24))
print("error_25 = %s"%(error_25))
print("error_26 = %s"%(error_26))
print("error_27 = %s"%(error_27))
print("error_28 = %s"%(error_28))
print("error_29 = %s"%(error_29))
print("error_30 = %s"%(error_30))
print("error_31 = %s"%(error_31))
print("error_32 = %s"%(error_32))
print("error_33 = %s"%(error_33))
print("error_34 = %s"%(error_34))
print("error_35 = %s"%(error_35))
print("error_36 = %s"%(error_36))
print("error_37 = %s"%(error_37))
print("error_38 = %s"%(error_38))
print("error_39 = %s"%(error_39))
print("error_40 = %s"%(error_40))
print("error_41 = %s"%(error_41))
print("error_42 = %s"%(error_42))
print("error_43 = %s"%(error_43))
print("error_44 = %s"%(error_44))
print("error_45 = %s"%(error_45))
print("error_46 = %s"%(error_46))
print("error_47 = %s"%(error_47))






