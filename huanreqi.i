#For heat exchanger modelled by HeatStructureCylindrical
#       6 (hot inner)
#       |
# 2-HeatExchanger-3 (cold,outer)
#       |
#       5
#Q/(num_rods) = 2*math.pi*k*L*(T_i-T_o)/math.log(r_o/r_i)
#Q = H_w*P_hf_i*L*(  (T_5+T_6)/2-T_i  )
#Q = H_w*P_hf_o*L*(  T_o-(T_2+T_3)/2  )

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
D8 = ${D1}

#A1 = ${fparse 0.25 * pi * D1^2}
#A2 = ${fparse 0.25 * pi * D2^2}
A3 = ${fparse 0.25 * pi * D3^2}
#A4 = ${fparse 0.25 * pi * D4^2}
#A5 = ${fparse 0.25 * pi * D5^2}
#A6 = ${fparse 0.25 * pi * D6^2}
#A7 = ${fparse 0.25 * pi * D7^2}
A8 = ${fparse 0.25 * pi * D8^2}

recuperator_width = 0.002 #0.15

d_i = ${fparse 0.015}
d_o = ${fparse (d_i/2 + recuperator_width)*2 }

L1 = 5.0
L2 = ${L1}
L3 = ${fparse 2 * L1}
L4 = ${fparse 2 * L1}
L5 = ${L1}
L6 = ${L1}
L7 = ${fparse L1 + recuperator_width}
L8 = ${L1}

x1 = 0.0
x2 = ${fparse x1 + L1}
x3 = ${fparse x2 + L2}
x4 = ${x3}
x5 = ${fparse x4 - L4}
x6 = ${x5}
x7 = ${fparse x6 + L6}
x8 = ${fparse x7 + L7}

y1 = 0
y2 = ${y1}
y3 = ${y2}
y4 = ${fparse y3 - L3}
y5 = ${y4}
y6 = ${fparse y5 + L5}
y7 = ${y6}
y8 = ${y7}

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

n_elems1 = 100
#n_elems2 = ${n_elems1}
n_elems3 = ${fparse 2 * n_elems1}
#n_elems4 = ${fparse 2 * n_elems1}
#n_elems5 = ${n_elems1}
#n_elems6 = ${n_elems1}
#n_elems7 = ${n_elems1}
n_elems8 = ${n_elems1}

#T_ambient = 300
#p_ambient = 1e5

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

[FluidProperties]
  [fp_air]
    type = IdealGasFluidProperties
    emit_on_nan = none
  []
[]

[HeatStructureMaterials]
  [steel]
    type = SolidMaterialProperties
    rho = 8050
    k = 45
    cp = 466
  []
[]

[Closures]
  [closures]
    type = Closures1PhaseSimple
  []
[]

[Components]

  [inlet_cold_leg]
    type = InletMassFlowRateTemperature1Phase
    input = 'cold_leg:in'
    m_dot = 4.34
    T = 462.1999306495847
  []
    
  [cold_leg]
    type = FlowChannel1Phase
    position = '${x3} ${y3} 0'
    orientation = '0 -1 0'
    length = ${fparse L3/2}
    n_elems = ${fparse n_elems3/2}
    A = ${A3}
    initial_p = 360000.0
    initial_T = 462.1999306495847
  []
  
  [outlet_cold_leg]
    type = Outlet1Phase
    input = 'cold_leg:out'
    p = 360000.0
  []
  
  [recuperator]
    type = HeatStructureCylindrical
    orientation = '0 -1 0'
    position = '${x3} ${y3} 0'
    length = ${fparse L3/2}
    widths = ${recuperator_width}
    n_elems = ${fparse n_elems3/2}
    n_part_elems = 2
    names = recuperator
    materials = steel
    inner_radius = ${fparse d_i/2}
    initial_T = 462.1999306495847
    num_rods = 100
  []

  [heat_transfer_cold_leg]
    type = HeatTransferFromHeatStructure1Phase
    flow_channel = cold_leg
    hs = recuperator
    hs_side = OUTER
    Hw = 4865.708274 #10000
    P_hf = ${fparse pi*d_o*100}
  []

  [heat_transfer_hot_leg]
    type = HeatTransferFromHeatStructure1Phase
    flow_channel = hot_leg
    hs = recuperator
    hs_side = INNER
    Hw = 4865.708274 #10000
    P_hf = ${fparse pi*d_i*100}
  []

#  [inlet_hot_leg]
#    type = InletStagnationPressureTemperature1Phase
#    input = 'hot_leg:in'
#    p0 = ${p_ambient}
#    T0 = ${T_ambient}
#  []

  [inlet_hot_leg]
    type = InletMassFlowRateTemperature1Phase
    input = 'hot_leg:in'
    m_dot = 4.34
    T = 666.8898360038002  
  []

  [hot_leg]
    type = FlowChannel1Phase
    position = '${x8} ${y8} 0'
    orientation = '0 1 0'
    length = ${L8}
    n_elems = ${n_elems8}
    A = ${A8}
    initial_p = 101325.0
    initial_T = 666.8898360038002
  []

  [outlet_hot_leg]
    type = Outlet1Phase
    input = 'hot_leg:out'
    p = 101325.0
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
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8
#  nl_abs_tol = 1e-5
  nl_max_its = 15
  steady_state_tolerance = 1e-14
  l_tol = 1e-4
  l_max_its = 10

  petsc_options_iname  = '-pc_type'
  petsc_options_value  = ' lu     '
[]

[Postprocessors]
  [a_m_dot2_3]
    type = ADFlowBoundaryFlux1Phase
    boundary = outlet_cold_leg
    equation = mass
  []
  [a_m_dot5_6]
    type = ADFlowBoundaryFlux1Phase
    boundary = outlet_hot_leg
    equation = mass
  []
  #################################
  [a_vel2_z]
    type = SideAverageValue
    variable = vel_z
    boundary = cold_leg:in
    outputs = csv_2
  []
  [a_v2]
    type = SideAverageValue
    variable = v
    boundary = cold_leg:in
    outputs = csv_2
  []
  [a_p2]
    type = SideAverageValue
    variable = p
    boundary = cold_leg:in
    outputs = csv_2
  []  
  [a_H2]
    type = SideAverageValue
    variable = H
    boundary = cold_leg:in
    outputs = csv_2
  []
  [a_T2]
    type = SideAverageValue
    variable = T
    boundary = cold_leg:in
    outputs = csv_2
  []
  #################################
  [a_vel3_z]
    type = SideAverageValue
    variable = vel_z
    boundary = cold_leg:out
    outputs = csv_2
  []
  [a_v3]
    type = SideAverageValue
    variable = v
    boundary = cold_leg:out
    outputs = csv_2
  []
  [a_p3]
    type = SideAverageValue
    variable = p
    boundary = cold_leg:out
    outputs = csv_2
  []  
  [a_H3]
    type = SideAverageValue
    variable = H
    boundary = cold_leg:out
    outputs = csv_2
  []
  [a_T3]
    type = SideAverageValue
    variable = T
    boundary = cold_leg:out
    outputs = csv_2
  []
  #################################
  [a_vel5_z]
    type = SideAverageValue
    variable = vel_z
    boundary = hot_leg:in
    outputs = csv_2
  []
  [a_v5]
    type = SideAverageValue
    variable = v
    boundary = hot_leg:in
    outputs = csv_2
  []
  [a_p5]
    type = SideAverageValue
    variable = p
    boundary = hot_leg:in
    outputs = csv_2
  []  
  [a_H5]
    type = SideAverageValue
    variable = H
    boundary = hot_leg:in
    outputs = csv_2
  []
  [a_T5]
    type = SideAverageValue
    variable = T
    boundary = hot_leg:in
    outputs = csv_2
  []
  #################################
  [a_vel6_z]
    type = SideAverageValue
    variable = vel_z
    boundary = hot_leg:out
    outputs = csv_2
  []
  [a_v6]
    type = SideAverageValue
    variable = v
    boundary = hot_leg:out
    outputs = csv_2
  []
  [a_p6]
    type = SideAverageValue
    variable = p
    boundary = hot_leg:out
    outputs = csv_2
  []  
  [a_H6]
    type = SideAverageValue
    variable = H
    boundary = hot_leg:out
    outputs = csv_2
  []
  [a_T6]
    type = SideAverageValue
    variable = T
    boundary = hot_leg:out
    outputs = csv_2
  []
  ###################################
  [b_T_w_inner]
    type = SideAverageValue
    variable = T_solid
    boundary = recuperator:inner
    outputs = csv_2
  []
  [b_T_w_outer]
    type = SideAverageValue
    variable = T_solid
    boundary = recuperator:outer
    outputs = csv_2
  []  
[]


[Outputs]
  [e]
    type = Exodus
    file_base = 'recuperated_brayton_cycle_out'
  []
  [csv]
    type = CSV
    file_base = 'recuperated_brayton_cycle'
    execute_vector_postprocessors_on = 'INITIAL'
  []
  [csv_2]
    type = CSV
    file_base = 'meigejiedan'
  []
[]
