# 见20230620-热管堆系统典型设计参数报告.docx
# 没有采信回热器热侧出口温度399.4 ℃
# 各处压损设置为0
# 相关公式见MOOSE Thermal Hydraulic
#https://mooseframework.inl.gov/modules/thermal_hydraulics/examples/recuperated_brayton_cycle/recuperated_brayton_cycle.html
import math
from scipy.optimize import fsolve
from scipy.interpolate import interp1d
########################################################
#          6
#          |
# 1--C--2--R--3--H--4--T
#          |           |
#          5-----------|
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
##################################################
#interpolate_2d_comp(rel_corrected_flow, rel_corrected_speed)
#interpolate_2d_turb(rel_corrected_flow, rel_corrected_speed)
print(  interpolate_2d_comp(1.1632000, 0.9375)  )
print(  interpolate_2d_turb(0.9549200, 0.9375)  )
##################################################
#####################################################################
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
#####################################################################
#Input parameters:
p0_1 = 102923.99667814026; T0_1 = 299.4867957686151; p_6 = 101325.0; omega = 96000 * 2 * math.pi / 60.0
eff_c = 0.79; eff_t = 0.8113204517379417
M = 0.029; R = 8.314; gamma = 1.4; cv = 1/(gamma-1)*R/M; cp = gamma*cv
A_1 = math.pi/4*0.30**2; A_2 = math.pi/4*0.30**2; A_3 = math.pi/4*0.30**2;
A_4 = math.pi/4*0.30**2; A_5 = math.pi/4*0.30**2; A_6 = math.pi/4*0.30**2
A_c = (A_1 + A_2)/2; A_t = (A_4 + A_5)/2
c0_rated_c = 351.6925137; c0_rated_t = 351.6925137
rho0_rated_c = 1.146881112; rho0_rated_t = 1.146881112
m_dot_rated_c = 3.6008383500823133; m_dot_rated_t = 3.113025797482743
omega_rated_c = 96000 * 2 * math.pi / 60.0; omega_rated_t = 96000 * 2 * math.pi / 60.0
Q_in = 1000000
f_generator = -207000.0/omega/omega
last_iteration_results = {}
#####################################################################
#These variables can be got without assumption:
#Eq 7, 6, 5, 8
v0_1 = T0_1*R/p0_1/M; rho_0_1 = 1/v0_1
s_1 = (math.log(v0_1) - math.log(R/M/p0_1)) * gamma*cv - cv*(gamma-1)*math.log(p0_1)
h0_1 = gamma*cv*(  p0_1/math.exp(-s_1/(gamma-1)/cv)  )**((gamma-1)/gamma)
c0_1 = math.sqrt(gamma*R*T0_1/M)
#####################################################################
def equation(vars):
    global last_iteration_results
    m_dot, T_6, T_3, p_1, p_2 = vars
#####################################################################
#Compressor:
#22 variables,18 equations, we also know p0_1, T0_1, omega, and we also assume m_dot
#So in thoery, the result for compressor can be solved
#But we also need to assume p_1 and p_2 to make the solve smooth
#There will be 2 more error equations
# Combine Eq 1, 4, 3, 2
    T_1 = math.exp((s_1 / cv + (gamma - 1) * math.log(p_1)) / gamma)
    u_1 = math.sqrt(2 * (h0_1 - cp * T_1))
    v_1 = u_1 * A_1 / m_dot
    err_1 = p_1 * v_1 - R / M * T_1

    rel_corrected_flow_c = (m_dot / rho_0_1 / c0_1) / (m_dot_rated_c / rho0_rated_c / c0_rated_c)
    rel_corrected_speed_c = (omega / c0_1) / (omega_rated_c / c0_rated_c)
# Combine Eq 9, 10, 11, 12, 13, 14
    p0_2 = p0_1 * interpolate_2d_comp(rel_corrected_flow_c, rel_corrected_speed_c)
    v0_2_is = R / M / p0_2 * math.exp((s_1 + cv * (gamma - 1) * math.log( (p0_2) )) / gamma / cv)
    T0_2_is = p0_2 * v0_2_is * M / R
    h0_2_is = cv * T0_2_is + p0_2 * v0_2_is
    h0_2 = (h0_2_is - h0_1 + eff_c * h0_1) / eff_c
    tau_c = - m_dot/omega * (h0_2 - h0_1)

# Eq 16, and replace u_2 -> Eq 18,and 17
    a_eq_16 = 0.5*m_dot**2*R**2/A_2**2/M**2/p_2**2; b_eq_16 = cp; c_eq_16 = -h0_2
    Delta_16 = b_eq_16**2 - 4*a_eq_16*c_eq_16
    T_2 = (  -b_eq_16 + math.sqrt(Delta_16)  )/2/a_eq_16
    u_2 = math.sqrt(2 * (h0_2 - cp * T_2))
    v_2 = u_2 * A_2 / m_dot
    err_2 = (u_1**2/v_1 + p_1)*A_1 - (u_2**2/v_2 + p_2)*A_2 + (p0_2 - p0_1)*A_c
#####################################################################
# Recuperator:
# 15 variables, 12 equations, and we know p_6
# And we assume T_6, T_3 the beginning
# We do not need extra error equations
# Eq 19, 20,
    p_3 = p_2
    p_5 = p_6
# Eq 24, 30, 27,
    v_6 = R / M * T_6 / p_6
    u_6 = m_dot * v_6 / A_6
    h0_6 = cp * T_6 + 0.5 * u_6**2
# Eq 22, 28, 25
    v_3 = R / M * T_3 / p_3
    u_3 = m_dot * v_3 / A_3
    h0_3 = cp * T_3 + 0.5 * u_3 ** 2
# Eq 21
    h0_5 = h0_3 - h0_2 + h0_6
# Eq 26, and replace u_5 -> Eq 29,and 23
    a_eq_26 = 0.5*m_dot**2*R**2/A_5**2/M**2/p_5**2; b_eq_26 = cp; c_eq_26 = -h0_5
    Delta_26 = b_eq_26**2 - 4 * a_eq_26 * c_eq_26
    T_5 = (-b_eq_26 + math.sqrt(Delta_26)) / 2 / a_eq_26
    u_5 = math.sqrt((2 * (h0_5 - cp * T_5)))
    v_5 = u_5 * A_5 / m_dot
#####################################################################
# Heat Source
# 5 variables, 5 equations
# Eq 31, 32
    p_4 = p_3
    h0_4 = (m_dot * h0_3 + Q_in) / m_dot
# Eq 34, and replace u_4 -> Eq 35, and 33
    a_eq_34 = 0.5*m_dot**2*R**2/A_4**2/M**2/p_4**2; b_eq_34 = cp; c_eq_34 = -h0_4
    Delta_34 = b_eq_34 ** 2 - 4 * a_eq_34 * c_eq_34
    T_4 = (-b_eq_34 + math.sqrt(Delta_34)) / 2 / a_eq_34
    u_4 = math.sqrt(2 * (h0_4 - cp * T_4))
    v_4 = u_4 * A_4 / m_dot
#####################################################################
# Turbine and motor
# 10 variables and 13 equations, so we need to solve 3 error equations
# Eq 36, 37, 38, 39, 40
    s_4 = cv * math.log( abs(T_4)**gamma / abs(p_4)**(gamma-1) )
    p0_4 = (abs(h0_4) / gamma / cv) ** (gamma / (gamma - 1)) * math.exp(-s_4 / (gamma - 1) / cv)
    v0_4 = R / M / p0_4 * math.exp((s_4 + cv * (gamma - 1) * math.log(p0_4)) / gamma / cv); rho_0_4 = 1/v0_4
    T0_4 = p0_4 * v0_4 * M / R
    c0_4 = math.sqrt(gamma * R * T0_4 / M)

    rel_corrected_flow_t = (m_dot / rho_0_4 / c0_4) / (m_dot_rated_t / rho0_rated_t / c0_rated_t)
    rel_corrected_speed_t = (omega / c0_4) / (omega_rated_t / c0_rated_t)
# Eq 41, 42, 43, 44
    p0_5 = p0_4 * interpolate_2d_turb(rel_corrected_flow_t, rel_corrected_speed_t)**(-1)
    v0_5_is = R / M / p0_5 * math.exp((s_4 + cv * (gamma - 1) * math.log((p0_5))) / gamma / cv)
    T0_5_is = p0_5 * v0_5_is * M / R
    h0_5_is = cv * T0_5_is + p0_5 * v0_5_is
# Eq 45
    err_3 = eff_t * h0_5_is - eff_t * h0_4 + h0_4 - h0_5
# Eq 46, 48
    tau_t = -m_dot / omega * (h0_5 - h0_4)
    err_4 = tau_c + tau_t + f_generator*omega
# Eq 47
    err_5 = (u_4 ** 2 / v_4 + p_4) * A_4 - (u_5 ** 2 / v_5 + p_5) * A_5 + (p0_5 - p0_4) * A_t

    last_iteration_results = {
        "T_1":T_1, "p_1":p_1, "v_1":v_1, "u_1":u_1, "h0_1":h0_1,
        "T_2":T_2, "p_2":p_2, "v_2":v_2, "u_2":u_2, "h0_2":h0_2,
        "T_3":T_3, "p_3":p_3, "v_3":v_3, "u_3":u_3, "h0_3":h0_3,
        "T_4":T_4, "p_4":p_4, "v_4":v_4, "u_4":u_4, "h0_4":h0_4,
        "T_5":T_5, "p_5":p_5, "v_5":v_5, "u_5":u_5, "h0_5":h0_5,
        "T_6":T_6, "p_6":p_6, "v_6":v_6, "u_6":u_6, "h0_6":h0_6,
        "m_dot":m_dot, "omega":omega,
        "Rp_c":p0_2/p0_1, "tau_c":tau_c,
        "Rp_t":p0_4/p0_5, "tau_t":tau_t,
        "tau_g":f_generator*omega
    }

    return [err_1, err_2, err_3, err_4, err_5]

result =  fsolve(equation, [4.34, 478.0, 652.0, 100000.0, 360000.0])  # assuming inital value for m_dot, T_6, T_3, p_1, p_2
print(result)
#Print result
#m_dot = result[0]; T_6 = result[1]; T_3 = result[2]; p_1 = result[3]; p_2 = result[4]
print("====================================")
print("T_1 =", last_iteration_results["T_1"], end='; ')
print("p_1 =", last_iteration_results["p_1"], end='; ')
print("h0_1 =", last_iteration_results["h0_1"], end='; ')
print("v_1 =", last_iteration_results["v_1"], end='; ')
print("u_1 =", last_iteration_results["u_1"])
print("====================================")
print("T_2 =", last_iteration_results["T_2"], end='; ')
print("p_2 =", last_iteration_results["p_2"], end='; ')
print("h0_2 =", last_iteration_results["h0_2"], end='; ')
print("v_2 =", last_iteration_results["v_2"], end='; ')
print("u_2 =", last_iteration_results["u_2"])
print("====================================")
print("T_3 =", last_iteration_results["T_3"], end='; ')
print("p_3 =", last_iteration_results["p_3"], end='; ')
print("h0_3 =", last_iteration_results["h0_3"], end='; ')
print("v_3 =", last_iteration_results["v_3"], end='; ')
print("u_3 =", last_iteration_results["u_3"])
print("====================================")
print("T_4 =", last_iteration_results["T_4"], end='; ')
print("p_4 =", last_iteration_results["p_4"], end='; ')
print("h0_4 =", last_iteration_results["h0_4"], end='; ')
print("v_4 =", last_iteration_results["v_4"], end='; ')
print("u_4 =", last_iteration_results["u_4"])
print("====================================")
print("T_5 =", last_iteration_results["T_5"], end='; ')
print("p_5 =", last_iteration_results["p_5"], end='; ')
print("h0_5 =", last_iteration_results["h0_5"], end='; ')
print("v_5 =", last_iteration_results["v_5"], end='; ')
print("u_5 =", last_iteration_results["u_5"])
print("====================================")
print("T_6 =", last_iteration_results["T_6"], end='; ')
print("p_6 =", last_iteration_results["p_6"], end='; ')
print("h0_6 =", last_iteration_results["h0_6"], end='; ')
print("v_6 =", last_iteration_results["v_6"], end='; ')
print("u_6 =", last_iteration_results["u_6"])
print("====================================")
print("m_dot =", last_iteration_results["m_dot"], end='; ')
print("omega =", last_iteration_results["omega"])
print("====================================")
print("Rp_c =", last_iteration_results["Rp_c"], end='; ')
print("tau_c =", last_iteration_results["tau_c"], end='; ')
print("Rp_t =", last_iteration_results["Rp_t"], end='; ')
print("tau_t =", last_iteration_results["tau_t"], end='; ')
print("tau_g =", last_iteration_results["tau_g"])
print("====================================")
print("f_generator = %s"%(f_generator))





