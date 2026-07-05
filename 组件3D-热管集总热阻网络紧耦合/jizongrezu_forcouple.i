initial_temp = 900
[GlobalParams]
#  Q_in = ${fparse 1000000/570}
  Q_in = Q_in
  d_p = 0.019
  d_w = 0.017
  d_v = 0.015
  T_f = ${fparse 563 + 273.15}
  M = 0.023
  h_c = 254
  epsilon = 0.84
  L_e = 1.55
  L_i = 0.45
  L_c = 2.0

  T_p_e = T_p_e
  T_p_i = T_p_i 
  T_p_c = T_p_c
  T_w_e = T_w_e 
  T_w_i = T_w_i
  T_w_c = T_w_c 
  T_v_e = T_v_e 
  T_v_i = T_v_i
  T_v_c = T_v_c
  T_wallc = T_wallc 

  k_p = k_p
  k_l = k_l
  hfg = hfg
  p_v = p_v
  miu_v = miu_v
  rho_v = rho_v
[]

[Mesh/generate]
  type = GeneratedMeshGenerator
  dim = 1
[]

[Debug]
  show_var_residual_norms = true
[]

[Functions]
# Sodium Coolant Handbook: Physical and Chemical Properties
# “IAEA PROJECT ON SODIUM PROPERTIES AND SAFE OPERATION OF EXPERIMENTAL FACILITIES IN SUPPORT OF THE DEVELOPMENT AND DEPLOYMENT OF SODIUM–COOLED FAST REACTORS (NAPRO)
# https://mooseframework.inl.gov/bison/source/materials/SS316Thermal.html
  [k_p]
    type = ParsedFunction
    expression = '-7.301e-6*t*t + 2.716e-2*t + 6.308'
  []
  [k_l]
    type = ParsedFunction
    expression = '124.67 - 0.11381*t + 5.5226e-5*t*t - 1.1842e-8*t*t*t'
  []
  [miu_v]
    type = PiecewiseLinear
    x = '400.0     500.0     600.0     700.0     800.0     900.0     1000.0    1100.0    1200.0       1300.0    1400.0    1500.0    1600.0    1700.0    1800.0    1900.0    2000.0    2100.0   2200.0 2300.0    2400.0    2500.0    2503.7'
    
#    y = '1.417e-05 1.462e-05 1.507e-05 1.551e-05 1.596e-05 1.641e-05 1.686e-05 1.732e-05 1.778e-05 1.827e-05 1.878e-05 1.934e-05 1.997e-05 2.068e-05 2.152e-05 2.252e-05 2.374e-05 2.531e-05 2.744e-05 3.064e-05 3.631e-05 5.398e-05 5.800e-05'
     y = '137.40 143.69 149.97 156.26 162.55 168.84 175.15 181.51 187.96 194.57
             201.44 208.68 216.43 224.85 234.12 244.45 256.10 269.45 285.06 304.11
             330.04 414.31 580.00'
    extrap = true
    scale_factor = 1e-7
  []
  [hfg]
    type = PiecewiseLinear
    x = '  371     400    500    600    700    800    900   1000   1100   1200   1300   1400 1500     1600   1700   1800   1900   2000   2100   2200   2300   2400   2500   2503.7'
    y = '4532e3 4510e3 4435e3 4358e3 4279e3 4197e3 4112e3 4024e3 3933e3 3838e3 3738e3 3633e3 3523e3 3405e3 3279e3 3143e3 2994e3 2829e3 2640e3 2418e3 2141e3 1747e3 652e3 0e3'
  []
  [rho_v]
    type = PiecewiseLinear
    x = '  800   900  1000  1100  1200  1300  1400  1500  1600  1700  1800   1900   2000'
    y = '0.003 0.017 0.059 0.163 0.381 0.779 1.433 2.433 3.874 5.857 8.485 11.850 16.040'
  []
  [p_v]
    type = PiecewiseLinear
    x = '370.98   394      400      425      461      500      504      555.5    600      620      700      701      800      808      900      954      1000     1100     1156.2   1200     1300     1400'
    y = '1.37e-05 1.01e-04 1.61e-04 1.01e-03 1.01e-02 8.54e-02 1.01e-01 1.01e+00 5.26e+00 1.01e+01 9.87e+01 1.01e+02 8.71e+02 1.01e+03 4.74e+03 1.01e+04 1.85e+04 5.77e+04 1.01e+05 1.52e+05 3.37e+05 5.93e+05'
  []
[]

[Variables]
  [./T_v_e]
    family = SCALAR
    order  = FIRST
    initial_condition = ${initial_temp}
#    initial_condition = 905.86278377415
  [../]
  [./T_v_i]
    family = SCALAR
    order  = FIRST
    initial_condition = ${initial_temp}
#    initial_condition = 901.6426743781489
  [../]
  [./T_v_c]
    family = SCALAR
    order  = FIRST
    initial_condition = ${initial_temp}
#    initial_condition = 895.0741537513825
  [../]
  [./T_w_e]
    family = SCALAR
    order  = FIRST
    initial_condition = ${initial_temp}
#    initial_condition = 906.204156099112
  [../]
  [./T_w_i]
    family = SCALAR
    order  = FIRST
    initial_condition = ${initial_temp}
#    initial_condition = 901.0637651078512
  [../]
  [./T_w_c]
    family = SCALAR
    order  = FIRST
    initial_condition = ${initial_temp}
#    initial_condition = 894.7990388251707
  [../]
  [./T_p_e]
    family = SCALAR
    order  = FIRST
    initial_condition = ${initial_temp}
#    initial_condition = 906.8308413645815
  [../]
  [./T_p_i]
    family = SCALAR
    order  = FIRST
    initial_condition = ${initial_temp}
#    initial_condition = 901.2219080045885
  [../]
  [./T_p_c]
    family = SCALAR
    order  = FIRST
    initial_condition = ${initial_temp}
#    initial_condition = 894.3121534543553
  [../]
  [./T_wallc]
    family = SCALAR
    order  = FIRST
    initial_condition = ${initial_temp}
#    initial_condition = 894.0072727739056
  [../]
[]

[AuxVariables]
  [./Q_in]
    family = SCALAR
    order = FIRST
    initial_condition = ${fparse 1000000/570}
  [../]
  [T_walle]
    family = SCALAR
    order = FIRST
    initial_condition = ${initial_temp}
  []
[]

[Functions]
  [receive_hp_flux_f]
    type = ParsedFunction
    expression = receive_hp_flux
    symbol_names = 'receive_hp_flux'
    symbol_values = 'receive_hp_flux'
  []
[]

[AuxScalarKernels]
  [cal_Q_in]
    type = FunctionScalarAux
    function = receive_hp_flux_f
    variable = Q_in
  []
  [cal_T_walle]
    type = CalTwalle
    variable = T_walle
  []
[]

[ScalarKernels]
  [./eq1]
    type = ADHeatPipeNetworkEqForCouple
    variable = T_p_e
    equation = 1
  [../]
  [./eq2]
    type = ADHeatPipeNetworkEqForCouple
    variable = T_p_i
    equation = 2
  [../]
  [./eq3]
    type = ADHeatPipeNetworkEqForCouple
    variable = T_p_c
    equation = 3
  [../]
  [./eq4]
    type = ADHeatPipeNetworkEqForCouple
    variable = T_wallc
    equation = 4
  [../]
  [./eq5]
    type = ADHeatPipeNetworkEqForCouple
    variable = T_w_e
    equation = 5
  [../]
  [./eq6]
    type = ADHeatPipeNetworkEqForCouple
    variable = T_w_i
    equation = 6
  [../]
  [./eq7]
    type = ADHeatPipeNetworkEqForCouple
    variable = T_w_c
    equation = 7
  [../]
  [./eq8]
    type = ADHeatPipeNetworkEqForCouple
    variable = T_v_e
    equation = 8
  [../]
  [./eq9]
    type = ADHeatPipeNetworkEqForCouple
    variable = T_v_i
    equation = 9
  [../]
  [./eq10]
    type = ADHeatPipeNetworkEqForCouple
    variable = T_v_c
    equation = 10
  [../]
[]

[Postprocessors]
  [receive_hp_flux]
    type = Receiver
  []
  [get_T_walle]
    type = ScalarVariable
    variable = T_walle
  []
[]

[Executioner]
  type = Steady
#  type = Transient
  solve_type = NEWTON
[]

[Outputs]
  exodus = false
  csv = true
[]
