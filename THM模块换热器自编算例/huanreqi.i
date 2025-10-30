#For heat exchanger modelled by HeatStructureCylindrical
#
#
#
#
# 3-----  HeatSection  -----4
#
# 
# T_max -  T_f - T_c - T_m    -   T_o
#      fuel - gap -clad - monolith
# Q = m_dot*(H_4 - H_3)
# Q = H_w*pi*d*L*(T_o - (T_4+T_3)/2)
# Q*(ln(r_c/r_f)/(2*pi*k_g*L) + ln(r_m/r_c)/(2*pi*k_s*L) + ln(r_w/r_m)/(2*pi*k_s*L)) + T_o = T_f
# T_max = T_f + q_v*d**2/16/k
# But we see the result:
# There is error for z_m_dot*(H_4-H_3)
# Maybe it is caused by the measurement from SideAverageValue

# Fuel parameters for snerdi
# Diameter:    16.38 mm
# Height  :     1.2  m
# Fuel number: 30*36 = 1080
# Radial size: fuel_inner, clad_inner, monolith_inner, monolith
#              16.38e-3/2, 16.72e-3/2, 19.0e-3/2,      20.8e-3/2

########################################################
motor_ramp_up_duration = 3605
motor_ramp_down_duration = 1800
post_motor_time = 2160000
t1 = ${motor_ramp_up_duration}
t2 = ${fparse t1 + motor_ramp_down_duration}
t3 = ${fparse t2 + post_motor_time}

D1 = 0.30
#D2 = ${D1}
D3 = ${D1}
#D4 = ${D1}
#D5 = ${D1}
#D6 = ${D1}
#D7 = ${D1}
#D8 = ${D1}

#A1 = ${fparse 0.25 * pi * D1^2}
#A2 = ${fparse 0.25 * pi * D2^2}
A3 = ${fparse 0.25 * pi * D3^2}
#A4 = ${fparse 0.25 * pi * D4^2}
#A5 = ${fparse 0.25 * pi * D5^2}
#A6 = ${fparse 0.25 * pi * D6^2}
#A7 = ${fparse 0.25 * pi * D7^2}
#A8 = ${fparse 0.25 * pi * D8^2}

fuel_radius =           ${fparse 16.38e-3/2}
clad_radius =           ${fparse 16.72e-3/2}
monolith_radius =       ${fparse 19.0e-3/2}
monolith_radius_outer = ${fparse 20.8e-3/2}
th_1 = ${fparse clad_radius-fuel_radius}
th_2 = ${fparse monolith_radius-clad_radius}
th_3 = ${fparse monolith_radius_outer-monolith_radius}



L1 = 1.2
L2 = ${L1}
L3 = ${fparse 2 * L1}
#L4 = ${fparse 2 * L1}
#L5 = ${L1}
#L6 = ${L1}
#L7 = ${fparse L1 + 0.01*L1}
#L8 = ${L1}

x1 = 0.0
x2 = ${fparse x1 + L1}
x3 = ${fparse x2 + L2}
#x4 = ${x3}
#x5 = ${fparse x4 - L4}
#x6 = ${x5}
#x7 = ${fparse x6 + L6}
#x8 = ${fparse x7 + L7}

y1 = 0
y2 = ${y1}
y3 = ${y2}
#y4 = ${fparse y3 - L3}
#y5 = ${y4}
#y6 = ${fparse y5 + L5}
#y7 = ${y6}
#y8 = ${y7}

#x1_out = ${fparse x1 + L1 - 0.001}
#x2_in = ${fparse x2 + 0.001}
#y5_in = ${fparse y5 + 0.001}
#x6_out = ${fparse x6 + L6 - 0.001}
#x7_in = ${fparse x7 + 0.001}
#y8_in = ${fparse y8 + 0.001}
#y8_out = ${fparse y8 + L8 - 0.001}
#hot_leg_in = ${y8_in}
#hot_leg_out = ${y8_out}
#cold_leg_in = ${fparse y3 - 0.001}
#cold_leg_out = ${fparse y3 - (L3/2) - 0.001}

n_elems1 = 200
#n_elems2 = ${n_elems1}
n_elems3 = ${fparse 2 * n_elems1}
#n_elems4 = ${fparse 2 * n_elems1}
#n_elems5 = ${n_elems1}
#n_elems6 = ${n_elems1}
#n_elems7 = ${n_elems1}
#n_elems8 = ${n_elems1}

#T_ambient = 300
#p_ambient = 1e5

num_rods = 1

#k = 45
k_he = 0.3
k_steel = 25.0
k_uo2   = 3.4

Hw = 4865.708274

hs_power = 1000

qv = ${fparse hs_power/(pi*fuel_radius^2*(L3/2))}

[GlobalParams]
  gravity_vector = '0 0 0'

#  initial_p = ${p_ambient}
#  initial_T = ${T_ambient}
  initial_vel = 0
#  initial_vel_x = 0
#  initial_vel_y = 0
#  initial_vel_z = 0

  fp = fp_air
  closures = closures
  f = 0

  scaling_factor_1phase = '1 1 1e-5'
#  scaling_factor_rhoV = 1
#  scaling_factor_rhouV = 1e-2
#  scaling_factor_rhovV = 1e-2
#  scaling_factor_rhowV = 1e-2
#  scaling_factor_rhoEV = 1e-5
  scaling_factor_temperature = 1e-2
  rdg_slope_reconstruction = none
[]

[Functions]
  [num_fn]
    type = ConstantFunction
    value = ${fparse num_rods}
  []
[]

[FluidProperties]
  [fp_air]
    type = IdealGasFluidProperties
    emit_on_nan = none
  []
[]

[HeatStructureMaterials]
  [steel]
    type = SolidMaterialProperties
    rho = 7500
    k = ${k_steel}
    cp = 550
  []
  [uo2]
    type = SolidMaterialProperties
    rho = 10980
    k = ${k_uo2}
    cp = 330
  []
  [he]
    type = SolidMaterialProperties
    rho = 0.0001216
    k = ${k_he}
    cp = 5192
  []
[]

[Closures]
  [closures]
    type = Closures1PhaseSimple
  []
[]

[Components]
  [inlet]
    type = InletMassFlowRateTemperature1Phase
    input = 'pipe4:in'
    m_dot = 0.434
    T = 476.44122903668
  []  
  [pipe4]
    type = FlowChannel1Phase
    position = '${x3} ${y3} 0'
    orientation = '0 -1 0'
    length = ${fparse L3/2}
    n_elems = ${fparse n_elems3/2}
    A = ${A3}
    initial_p = 360000.0
    initial_T = 462.1999306495847
  []
  [outlet]
    type = Outlet1Phase
    input = 'pipe4:out'
    p = 360000.0
  []
#fuel_radius =           ${fparse 16.38e-3/2}
#clad_radius =           ${fparse 16.72e-3/2}
#monolith_radius =       ${fparse 19.0e-3/2}
#monolith_radius_outer = ${fparse 20.8e-3/2}
  [reactor]
    type = HeatStructureCylindrical
    orientation = '0 -1 0'
    position = '${x3} ${y3} 0'
    length = ${fparse L3/2}
    widths = '${fuel_radius} ${th_1} ${th_2} ${th_3}'
    n_elems = ${fparse n_elems3/2}
    n_part_elems = '20 2 10 10'
    names =     'fuel  gap  clad    monolith'
    materials = 'uo2   he   steel   steel'
    inner_radius = 0.0
    initial_T = 462.1999306495847
    num_rods = ${fparse num_rods}
  []
  [heat_generation]
    type = HeatSourceFromTotalPower
    power = total_power
    hs = reactor
    regions = fuel
  []
  [total_power]
    type = TotalPower
    power = 0
  []
  [heat_transfer]
    type = HeatTransferFromHeatStructure1Phase
    flow_channel = pipe4
    hs = reactor
    hs_side = OUTER
    Hw = ${Hw} #10000
#    Hw = ${fparse num_rods * 4865.708274}
#    P_hf = ${fparse pi*d_o*1}
    P_hf = ${fparse pi*2*monolith_radius_outer*num_rods}
  []
[]

[ControlLogic]
  [power_applied]
    type = SetComponentRealValueControl
    component = total_power
    parameter = power
    value = power_logic:value
  []
  [power_logic]
    type = ParsedFunctionControl
    function = 'power_fn'
    symbol_names = 'power_fn'
    symbol_values = 'power_fn'
  []
[]

[Functions]
  [power_fn]
    type = PiecewiseLinear
    x = '0           ${t3}'
    y = '${hs_power} ${hs_power}'
  []
[]

[Executioner]
  type = Transient
  scheme = 'bdf2'

  end_time = ${t3}
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
    growth_factor = 1.1
    cutback_factor = 0.9
  []
  dtmin = 1e-5
  dtmax = 1000
  steady_state_detection = true
#  steady_state_start_time = 1000.0
  solve_type = NEWTON
  nl_rel_tol = 1e-50
  nl_abs_tol = 5e-11
#  nl_abs_tol = 1e-5
  nl_max_its = 15
  steady_state_tolerance = 1e-20
#  l_tol = 1e-5
  l_max_its = 10

  petsc_options_iname  = '-pc_type'
  petsc_options_value  = ' lu     '
[]

[Postprocessors]
  [a_m_dot3_4]
    type = ADFlowBoundaryFlux1Phase
    boundary = outlet
    equation = mass
  []
  #################################
  [a_vel3_z]
    type = SideAverageValue
    variable = vel_z
    boundary = pipe4:in
    outputs = csv_2
  []
  [a_v3]
    type = SideAverageValue
    variable = v
    boundary = pipe4:in
    outputs = csv_2
  []
  [a_p3]
    type = SideAverageValue
    variable = p
    boundary = pipe4:in
    outputs = csv_2
  []  
  [a_H3]
    type = SideAverageValue
    variable = H
    boundary = pipe4:in
    outputs = csv_2
  []
  [a_T3]
    type = SideAverageValue
    variable = T
    boundary = pipe4:in
    outputs = csv_2
  []
  #################################
  [a_vel4_z]
    type = SideAverageValue
    variable = vel_z
    boundary = pipe4:out
    outputs = csv_2
  []
  [a_v4]
    type = SideAverageValue
    variable = v
    boundary = pipe4:out
    outputs = csv_2
  []
  [a_p4]
    type = SideAverageValue
    variable = p
    boundary = pipe4:out
    outputs = csv_2
  []  
  [a_H4]
    type = SideAverageValue
    variable = H
    boundary = pipe4:out
    outputs = csv_2
  []
  [a_T4]
    type = SideAverageValue
    variable = T
    boundary = pipe4:out
    outputs = csv_2
  []
  #################################
  ###################################
  [b_T_max]
    type = SideAverageValue
    variable = T_solid
    boundary = reactor:inner
    outputs = csv_2
  []
  [b_T_o]
    type = SideAverageValue
    variable = T_solid
    boundary = reactor:outer
    outputs = csv_2
  []
  [b_T_f]
    type = SideAverageValue
    variable = T_solid
    boundary = reactor:fuel:gap
    outputs = csv_2
  []
  [b_T_c]
    type = SideAverageValue
    variable = T_solid
    boundary = reactor:gap:clad
    outputs = csv_2
  []
  [b_T_m]
    type = SideAverageValue
    variable = T_solid
    boundary = reactor:clad:monolith
    outputs = csv_2
  []
  ###################################
  # T_max -  T_f - T_c - T_m    -   T_o
  #      fuel - gap -clad - monolith
  # Q = m_dot*(H_4 - H_3)
  # Q = H_w*pi*d*L*(T_o - (T_4+T_3)/2)
  # Q*(ln(r_c/r_f)/(2*pi*k_g*L) + ln(r_m/r_c)/(2*pi*k_s*L) + ln(r_w/r_m)/(2*pi*k_s*L)) + T_o = T_f
  # T_max = T_f + q_v*d**2/16/k
  ###################################
  [z_m_dot*(H_4-H_3)]
    type = ParsedPostprocessor
    pp_names = 'a_m_dot3_4 a_H4 a_H3'
    function = 'a_m_dot3_4*(a_H4-a_H3)'
    outputs = csv_2
  []
  [z_pi*d_o*L*Hw*(To-(T3+T4)_div_2)]
    type = ParsedPostprocessor
    pp_names = 'a_T3 a_T4 b_T_o'
    function = '3.14159265*2*${monolith_radius_outer}*${fparse L3/2}*${Hw}*(b_T_o-(a_T3 + a_T4)/2)'
    outputs = csv_2
  []
  
  [z_(T_f-T_o)_div_((ln(r_c_div_r_f)_div_(2*pi*k_g*L)+ln(r_m_div_r_c)_div_(2*pi*k_s*L)+ln(r_o_div_r_m)_div_(2*pi*k_s*L)))]
    type = ParsedPostprocessor
    pp_names = 'b_T_f b_T_o'
    function = '(b_T_f-b_T_o)/((log(${clad_radius}/${fuel_radius})/(2*3.14159265*${k_he}*${fparse L3/2})+log(${monolith_radius}/${clad_radius})/(2*3.14159265*${k_steel}*${fparse L3/2})+log(${monolith_radius_outer}/${monolith_radius})/(2*3.14159265*${k_steel}*${fparse L3/2})))'
    outputs = csv_2
  []
  [z_T_w+q_v*r_f**2_div_4_div_k]
    type = ParsedPostprocessor
    pp_names = 'b_T_f'
    function = 'b_T_f + ${qv}*${fuel_radius}^2/4/${k_uo2}'
    outputs = csv_2
  []
  [z_hf_pipe]
    type = ADHeatRateConvection1Phase
    block = pipe4
    T_wall = T_wall
    T = T
    Hw = Hw
    P_hf = P_hf
    outputs = csv_2
  []
  [z_E_inlet]
    type = ADFlowBoundaryFlux1Phase
    boundary = inlet
    equation = energy
  []
  [z_E_outlet]
    type = ADFlowBoundaryFlux1Phase
    boundary = outlet
    equation = energy
  []
  [z_E_outlet-z_E_inlet]
    type = ParsedPostprocessor
    pp_names = 'z_E_outlet z_E_inlet'
    function = 'z_E_outlet-z_E_inlet'
    outputs = csv_2
  []
[]


[Outputs]
  [e]
    type = Exodus
    file_base = 'huanreqi_out'
  []
  [csv]
    type = CSV
    file_base = 'huanreqi_cycle'
    execute_vector_postprocessors_on = 'INITIAL'
  []
  [csv_2]
    type = CSV
    file_base = 'meigejiedan'
  []
[]
