# number of fuel rods: 30*36 = 1080
# total power = 1000000 MW
# length of fuel rods: 1200 mm
# diameter of fuel rods: 16.38 mm
h_monolith_hp = 3693.0
L_e = 1.2
[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = '../shuruka_wangge_xiaomoxing/snerdi_mesh_xiao_in.e'
  []
[]

[Functions]
  [k_ss316]
    type = ParsedFunction
    expression = '-7.301e-6*t*t + 2.716e-2*t + 6.308'
  []
  [k_uo2]
    type = PiecewiseLinear
    x = '${fparse 499+273.15} ${fparse 1093+273.15} ${fparse 1699+273.15} ${fparse 2204+273.15}'
    y = '                4.33                  2.60                 2.16                   4.33'
  []
  [k_he]
    type = PiecewiseLinear
    x = '275     300     350     400     450     500     600     700     800     900     1000     1100     1200     1300     1400     1500'
    y = '0.147   0.156   0.173   0.190   0.206   0.221   0.251   0.280   0.308   0.334   0.360    0.385    0.410    0.434    0.457    0.480'
  []
[]

[Variables]
  [temp]
    order = FIRST
    family = LAGRANGE
    initial_condition = ${fparse  600+273.15}
  []
[]

[Kernels]
  [heat_1]
    type = HeatConduction
    variable = temp
  []
  [heat_2]
    type = HeatSource
    variable = temp
    function = ${fparse 1000000/(pi/4*16.38e-3^2*L_e)/(30*36)}
    block = 'fuel_tri fuel'
  []
[]

[BCs]
  [reguanbi]
    type = ADConvectiveHeatFluxScalarTfBC
    boundary = 'hp_bc_1'
    variable = temp
    heat_transfer_coefficient = ${h_monolith_hp}
    T_infinity = T_walle
  []
[]

[Materials]
  [daore_ss316]
    type = HeatConductionMaterial
    block = 'monolith clad'
    temp = temp
    thermal_conductivity_temperature_function = k_ss316
  []
  [daore_uo2]
    type = HeatConductionMaterial
    block = 'fuel fuel_tri'
    temp = temp
    thermal_conductivity_temperature_function = k_uo2
  []
  [daore_he]
    type = HeatConductionMaterial
    block = 'gap'
    temp = temp
    thermal_conductivity_temperature_function = k_he
  []
[]

[Postprocessors]
  [adrsuop]
    type = ADHeatRateSideUserObjectPostprocessor
    heat_rate_userobject = adrsuo
  []
  [chtsist]
    type = ConvectiveHeatTransferSideIntegralScalarTf
    T_solid = temp
    boundary = hp_bc_1
    htc = ${h_monolith_hp}
    T_fluid_var = T_walle
    scale = ${L_e}
  []
  [sav]
    type = SideAverageValue
    variable = temp
    boundary = hp_bc_1
  []
[]
#####################################################################################
# Heat pipe calculation
[GlobalParams]
  heat_rate_userobject = adrsuo
  d_p = 0.019
  d_w = 0.017
  d_v = 0.015
  T_f = ${fparse 563 + 273.15}
  M = 0.023
  h_c = 254
  epsilon = 0.84
  L_e = ${L_e}
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

  k_p = k_ss316
  k_l = k_l
  hfg = hfg
  p_v = p_v
  miu_v = miu_v
  rho_v = rho_v
[]
[Variables]
  [./T_v_e]
    family = SCALAR
    order  = FIRST
    initial_condition = ${fparse  600+273.15}
  [../]
  [./T_v_i]
    family = SCALAR
    order  = FIRST
    initial_condition = ${fparse  600+273.15}
  [../]
  [./T_v_c]
    family = SCALAR
    order  = FIRST
    initial_condition = ${fparse  600+273.15}
  [../]
  [./T_w_e]
    family = SCALAR
    order  = FIRST
    initial_condition = ${fparse  600+273.15}
  [../]
  [./T_w_i]
    family = SCALAR
    order  = FIRST
    initial_condition = ${fparse  600+273.15}
  [../]
  [./T_w_c]
    family = SCALAR
    order  = FIRST
    initial_condition = ${fparse  600+273.15}
  [../]
  [./T_p_e]
    family = SCALAR
    order  = FIRST
    initial_condition = ${fparse  600+273.15}
  [../]
  [./T_p_i]
    family = SCALAR
    order  = FIRST
    initial_condition = ${fparse  600+273.15}
  [../]
  [./T_p_c]
    family = SCALAR
    order  = FIRST
    initial_condition = ${fparse  600+273.15}
  [../]
  [./T_wallc]
    family = SCALAR
    order  = FIRST
    initial_condition = ${fparse  570+273.15}
  [../]
  [T_walle]
    family = SCALAR
    order = FIRST
    initial_condition = ${fparse  600+273.15}
  []
[]

[Functions]
  [k_l]
    type = ParsedFunction
    expression = '124.67 - 0.11381*t + 5.5226e-5*t*t - 1.1842e-8*t*t*t'
  []
  [miu_v]
    type = PiecewiseLinear
    x = '400.0  500.0  600.0  700.0  800.0  900.0  1000.0 1100.0 1200.0 1300.0 1400.0 1500.0 1600.0 1700.0 1800.0 1900.0 2000.0 2100.0 2200.0 2300.0 2400.0 2500.0 2503.7'
    y = '137.40 143.69 149.97 156.26 162.55 168.84 175.15 181.51 187.96 194.57 201.44 208.68 216.43 224.85 234.12 244.45 256.10 269.45 285.06 304.11 330.04 414.31 580.00'
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

[ScalarKernels]
  [./eq1]
    #type = ADHeatPipeNetworkEqForCouple
    type = ADHeatPipeNetworkEqForCoupleFromHeatRateUO
    variable = T_p_e
    equation = 1
  [../]
  [./eq2]
    #type = ADHeatPipeNetworkEqForCouple
    type = ADHeatPipeNetworkEqForCoupleFromHeatRateUO
    variable = T_p_i
    equation = 2
  [../]
  [./eq3]
    #type = ADHeatPipeNetworkEqForCouple
    type = ADHeatPipeNetworkEqForCoupleFromHeatRateUO
    variable = T_p_c
    equation = 3
  [../]
  [./eq4]
    #type = ADHeatPipeNetworkEqForCouple
    type = ADHeatPipeNetworkEqForCoupleFromHeatRateUO
    variable = T_wallc
    equation = 4
  [../]
  [./eq5]
    #type = ADHeatPipeNetworkEqForCouple
    type = ADHeatPipeNetworkEqForCoupleFromHeatRateUO
    variable = T_w_e
    equation = 5
  [../]
  [./eq6]
    #type = ADHeatPipeNetworkEqForCouple
    type = ADHeatPipeNetworkEqForCoupleFromHeatRateUO
    variable = T_w_i
    equation = 6
  [../]
  [./eq7]
    #type = ADHeatPipeNetworkEqForCouple
    type = ADHeatPipeNetworkEqForCoupleFromHeatRateUO
    variable = T_w_c
    equation = 7
  [../]
  [./eq8]
    #type = ADHeatPipeNetworkEqForCouple
    type = ADHeatPipeNetworkEqForCoupleFromHeatRateUO
    variable = T_v_e
    equation = 8
  [../]
  [./eq9]
    #type = ADHeatPipeNetworkEqForCouple
    type = ADHeatPipeNetworkEqForCoupleFromHeatRateUO
    variable = T_v_i
    equation = 9
  [../]
  [./eq10]
    #type = ADHeatPipeNetworkEqForCouple
    type = ADHeatPipeNetworkEqForCoupleFromHeatRateUO
    variable = T_v_c
    equation = 10
  [../]
  [./cal_T_walle]
    #type = ADHeatPipeNetworkEqForTwalleCouple
    type = ADHeatPipeTwalleFromHeatRateUO
    variable = T_walle
  []
[]
[UserObjects]
  [adrsuo]
    type = ADHeatRateSideUserObject
    temperature = temp
    T_wall = T_walle
    heat_transfer_coefficient = ${h_monolith_hp}
    scale = ${L_e}
    boundary = hp_bc_1
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_BEGIN TIMESTEP_END FINAL'
  []
[]
#####################################################################################
[Outputs]
  exodus = true
[]

[Executioner]
  type = Steady
[]
