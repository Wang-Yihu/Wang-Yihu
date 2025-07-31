# This input file is used to demonstrate a simple open-air Brayton cycle using
# a compressor, turbine, shaft, motor, and generator.
# The flow length is divided into 5 segments as illustrated below, where
#   - "(I)" denotes the inlet
#   - "(C)" denotes the compressor
#   - "(T)" denotes the turbine
#   - "(O)" denotes the outlet
#   - "*" denotes a fictitious junction
#
#                  Heated section
# (I)-----(C)-----*--------------*-----(T)-----(O)
#      1       2         3          4       5
#
# Initially the fluid is at rest at ambient conditions, the shaft speed is zero,
# and no heat transfer occurs with the system.
# The transient is controlled as follows:
#   * 0   - t1: motor ramps up torque linearly from zero
#   * t1 -  t2: motor ramps down torque linearly to zero, HTC ramps up linearly from zero.
#   * t2 -  t3: (no changes; should approach steady condition)
# The result is from chouqihuire_snerdihp_youdongneng.py
# But this version does not have recuperator

I_motor = 1.0
motor_torque_max = 400.0

I_generator = 1.0
generator_torque_per_shaft_speed = -0.002048191895894914

motor_ramp_up_duration = 1000.0  #100.0
motor_ramp_down_duration = 1000.0  #100.0
post_motor_time = 10000000.0
t1 = ${motor_ramp_up_duration}
t2 = ${fparse t1 + motor_ramp_down_duration}
t3 = ${fparse t2 + post_motor_time}

D1 = 0.30
D2 = ${D1}
D3 = ${D1}
D4 = ${D1}
D5 = ${D1}

A1 = ${fparse 0.25 * pi * D1^2}
A2 = ${fparse 0.25 * pi * D2^2}
A3 = ${fparse 0.25 * pi * D3^2}
A4 = ${fparse 0.25 * pi * D4^2}
A5 = ${fparse 0.25 * pi * D5^2}

L1 = 10.0
L2 = ${L1}
L3 = ${L1}
L4 = ${L1}
L5 = ${L1}

x1 = 0.0
x2 = ${fparse x1 + L1}
x3 = ${fparse x2 + L2}
x4 = ${fparse x3 + L3}
x5 = ${fparse x4 + L4}

x2_minus = ${fparse x2 - 0.001}
x2_plus = ${fparse x2 + 0.001}
x5_minus = ${fparse x5 - 0.001}
x5_plus = ${fparse x5 + 0.001}

n_elems1 = 10
n_elems2 = ${n_elems1}
n_elems3 = ${n_elems1}
n_elems4 = ${n_elems1}
n_elems5 = ${n_elems1}

A_ref_comp = ${fparse 0.5 * (A1 + A2)}
V_comp = ${fparse A_ref_comp * 1.0}
I_comp = 1.0

A_ref_turb = ${fparse 0.5 * (A4 + A5)}
V_turb = ${fparse A_ref_turb * 1.0}
I_turb = 1.0

c0_rated_comp = 351.6925137
rho0_rated_comp = 1.146881112

rated_mfr_c = 3.6008383500823133    #2.5
rated_mfr_t = 3.113025797482743     #2.5

speed_rated_rpm = 96000
speed_rated = ${fparse speed_rated_rpm * 2 * pi / 60.0}

speed_initial = 0

eff_comp = 0.79
eff_turb = 0.8113204517379417

#T_hot = 1000
T_ambient = 299.4867957686151
p_ambient = 102923.99667814026
p_outlet = 101325.0

tot_power = 1000000
[GlobalParams]
  orientation = '1 0 0'
  gravity_vector = '0 0 0'

  initial_p = ${p_ambient}
  initial_T = ${T_ambient}
  initial_vel = 0
  initial_vel_x = 0
  initial_vel_y = 0
  initial_vel_z = 0

  fp = fp_air
  closures = closures
  f = 0

  scaling_factor_1phase = '1 1 1e-5'
  scaling_factor_rhoV = 1
  scaling_factor_rhouV = 1
  scaling_factor_rhovV = 1
  scaling_factor_rhowV = 1
  scaling_factor_rhoEV = 1e-5

  rdg_slope_reconstruction = none
[]

[Functions]
  [motor_torque_fn]
    type = PiecewiseLinear
    x = '0 ${t1} ${t2}'
    y = '0 ${motor_torque_max} 0'
  []
  [q_wall_fn]
    type = PiecewiseLinear
    x = '0 ${t1} ${t2}'
    y = '0 194816 194816'    
  []
  [motor_power_fn]
    type = ParsedFunction
    expression = 'torque * speed'
    symbol_names = 'torque speed'
    symbol_values = 'motor_torque shaft:omega'
  []
  [generator_torque_fn]
    type = ParsedFunction
    expression = 'slope * t'
    symbol_names = 'slope'
    symbol_values = '${generator_torque_per_shaft_speed}'
  []
  [generator_power_fn]
    type = ParsedFunction
    expression = 'torque * speed'
    symbol_names = 'torque speed'
    symbol_values = 'generator_torque shaft:omega'
  []
  [htc_wall_fn]
    type = PiecewiseLinear
    x = '0 ${t1} ${t2}'
    y = '0 0 1e3'
  []
[]

[FluidProperties]
  [fp_air]
    type = IdealGasFluidProperties
    emit_on_nan = none
  []
[]

[Closures]
  [closures]
    type = Closures1PhaseSimple
  []
[]

[Components]
  [total_power]
    type = TotalPower
    power = ${tot_power}
  []
  [shaft]
    type = Shaft
    connected_components = 'motor compressor turbine generator'
    initial_speed = ${speed_initial}
  []
  [motor]
    type = ShaftConnectedMotor
    inertia = ${I_motor}
    torque = 0 # controlled
  []
  [generator]
    type = ShaftConnectedMotor
    inertia = ${I_generator}
    torque = generator_torque_fn
  []

  [inlet]
    type = InletStagnationPressureTemperature1Phase
    input = 'pipe1:in'
    p0 = ${p_ambient}
    T0 = ${T_ambient}
  []
  [pipe1]
    type = FlowChannel1Phase
    position = '${x1} 0 0'
    length = ${L1}
    n_elems = ${n_elems1}
    A = ${A1}
  []
  [compressor]
    type = ShaftConnectedCompressor1Phase
    position = '${x2} 0 0'
    inlet = 'pipe1:out'
    outlet = 'pipe2:in'
    A_ref = ${A_ref_comp}
    volume = ${V_comp}

    omega_rated = ${speed_rated}
    mdot_rated = ${rated_mfr_c}
    c0_rated = ${c0_rated_comp}
    rho0_rated = ${rho0_rated_comp}

    speeds = '0.5208 0.6250 0.7292 0.8333 0.9375'
    Rp_functions = 'rp_comp1 rp_comp2 rp_comp3 rp_comp4 rp_comp5'
    eff_functions = 'eff_comp1 eff_comp2 eff_comp3 eff_comp4 eff_comp5'

    min_pressure_ratio = 1.0

    speed_cr_I = 0
    inertia_const = ${I_comp}
    inertia_coeff = '${I_comp} 0 0 0'

    # assume no shaft friction
    speed_cr_fr = 0
    tau_fr_const = 0
    tau_fr_coeff = '0 0 0 0'
  []
  [pipe2]
    type = FlowChannel1Phase
    position = '${x2} 0 0'
    length = ${L2}
    n_elems = ${n_elems2}
    A = ${A2}
  []
  [junction2_3]
    type = JunctionOneToOne1Phase
    connections = 'pipe2:out pipe3:in'
  []
  [pipe3]
    type = FlowChannel1Phase
    position = '${x3} 0 0'
    length = ${L3}
    n_elems = ${n_elems3}
    A = ${A3}
  []
  [junction3_4]
    type = JunctionOneToOne1Phase
    connections = 'pipe3:out pipe4:in'
  []
  [pipe4]
    type = FlowChannel1Phase
    position = '${x4} 0 0'
    length = ${L4}
    n_elems = ${n_elems4}
    A = ${A4}
  []
  [turbine]
    type = ShaftConnectedCompressor1Phase
    position = '${x5} 0 0'
    inlet = 'pipe4:out'
    outlet = 'pipe5:in'
    A_ref = ${A_ref_turb}
    volume = ${V_turb}

    treat_as_turbine = true

    omega_rated = ${speed_rated}
    mdot_rated = ${rated_mfr_t}
    c0_rated = ${c0_rated_comp}
    rho0_rated = ${rho0_rated_comp}

    speeds = '0 0.5208 0.6250 0.7292 0.8333 0.9375'
    Rp_functions = 'rp_turb0 rp_turb1 rp_turb2 rp_turb3 rp_turb4 rp_turb5'
    eff_functions = 'eff_turb1 eff_turb1 eff_turb2 eff_turb3 eff_turb4 eff_turb5'

    min_pressure_ratio = 1.0

    speed_cr_I = 0
    inertia_const = ${I_turb}
    inertia_coeff = '${I_turb} 0 0 0'

    # assume no shaft friction
    speed_cr_fr = 0
    tau_fr_const = 0
    tau_fr_coeff = '0 0 0 0'
  []
  [pipe5]
    type = FlowChannel1Phase
    position = '${x5} 0 0'
    length = ${L5}
    n_elems = ${n_elems5}
    A = ${A5}
  []
  [outlet]
    type = Outlet1Phase
    input = 'pipe5:out'
    p = ${p_outlet}
  []

#  [heating]
#    type = HeatTransferFromSpecifiedTemperature1Phase
#    flow_channel = pipe3
#    T_wall = ${T_hot}
#    Hw = htc_wall_fn
#  []
   [heating]
     type = HeatTransferFromHeatFlux1Phase
     flow_channel = pipe3
     q_wall = q_wall_fn #2922.2408
     Hw = 1000000000000000000000000000000000000
   []
[]

[ControlLogic]
  [motor_ctrl]
    type = TimeFunctionComponentControl
    component = motor
    parameter = torque
    function = motor_torque_fn
  []
[]

[Postprocessors]
#  [heating_rate]
#    type = ADHeatRateConvection1Phase
#    block = 'pipe3'
#    T = T
#    T_wall = T_wall
#    Hw = Hw
#    P_hf = P_hf
#    execute_on = 'INITIAL TIMESTEP_END'
#  []

  [motor_torque]
    type = RealComponentParameterValuePostprocessor
    component = motor
    parameter = torque
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [motor_power]
    type = FunctionValuePostprocessor
    function = motor_power_fn
    execute_on = 'INITIAL TIMESTEP_END'
    indirect_dependencies = 'motor_torque shaft:omega'
  []

  [generator_torque]
    type = ShaftConnectedComponentPostprocessor
    quantity = torque
    shaft_connected_component_uo = generator:shaftconnected_uo
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [generator_power]
    type = FunctionValuePostprocessor
    function = generator_power_fn
    execute_on = 'INITIAL TIMESTEP_END'
    indirect_dependencies = 'generator_torque shaft:omega'
  []

  [shaft_speed]
    type = ScalarVariable
    variable = 'shaft:omega'
    execute_on = 'INITIAL TIMESTEP_END'
  []

  [p_in_comp]
    type = PointValue
    variable = p
    point = '${x2_minus} 0 0'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_out_comp]
    type = PointValue
    variable = p
    point = '${x2_plus} 0 0'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_ratio_comp]
    type = ParsedPostprocessor
    pp_names = 'p_in_comp p_out_comp'
    function = 'p_out_comp / p_in_comp'
    execute_on = 'INITIAL TIMESTEP_END'
  []

  [p_in_turb]
    type = PointValue
    variable = p
    point = '${x5_minus} 0 0'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_out_turb]
    type = PointValue
    variable = p
    point = '${x5_plus} 0 0'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [p_ratio_turb]
    type = ParsedPostprocessor
    pp_names = 'p_in_turb p_out_turb'
    function = 'p_in_turb / p_out_turb'
    execute_on = 'INITIAL TIMESTEP_END'
  []

  [mfr_comp]
    type = ADFlowJunctionFlux1Phase
    boundary = pipe1:out
    connection_index = 0
    equation = mass
    junction = compressor
  []
  [mfr_turb]
    type = ADFlowJunctionFlux1Phase
    boundary = pipe4:out
    connection_index = 0
    equation = mass
    junction = turbine
  []
####################################
# By myself
####################################
  [a_m_dot1] 
    type = ADFlowJunctionFlux1Phase
    boundary = pipe1:out
    connection_index = 0
    equation = mass
    junction = compressor
    outputs = csv_2
  []
  [a_vel1_x]
    type = SideAverageValue
    variable = vel_x
    boundary = pipe1:out
    outputs = csv_2
  []
  [a_v1]
    type = SideAverageValue
    variable = v
    boundary = pipe1:out
    outputs = csv_2
  []
  [a_p1]
    type = SideAverageValue
    variable = p
    boundary = pipe1:out
    outputs = csv_2
  []  
  [a_H1]
    type = SideAverageValue
    variable = H
    boundary = pipe1:out
    outputs = csv_2
  []
  [a_T1]
    type = SideAverageValue
    variable = T
    boundary = pipe1:out
    outputs = csv_2
  []
######################################
  [a_vel2_x]
    type = SideAverageValue
    variable = vel_x
    boundary = pipe2:out
    outputs = csv_2
  []
  [a_v2]
    type = SideAverageValue
    variable = v
    boundary = pipe2:out
    outputs = csv_2
  []
  [a_p2]
    type = SideAverageValue
    variable = p
    boundary = pipe2:out
    outputs = csv_2
  []  
  [a_H2]
    type = SideAverageValue
    variable = H
    boundary = pipe2:out
    outputs = csv_2
  []
  [a_T2]
    type = SideAverageValue
    variable = T
    boundary = pipe2:out
    outputs = csv_2
  []
######################################
  [a_vel3_x]
    type = SideAverageValue
    variable = vel_x
    boundary = pipe3:out
    outputs = csv_2
  []
  [a_v3]
    type = SideAverageValue
    variable = v
    boundary = pipe3:out
    outputs = csv_2
  []
  [a_p3]
    type = SideAverageValue
    variable = p
    boundary = pipe3:out
    outputs = csv_2
  []  
  [a_H3]
    type = SideAverageValue
    variable = H
    boundary = pipe3:out
    outputs = csv_2
  []
  [a_T3]
    type = SideAverageValue
    variable = T
    boundary = pipe3:out
    outputs = csv_2
  []
######################################
  [a_vel4_x]
    type = SideAverageValue
    variable = vel_x
    boundary = pipe5:out
    outputs = csv_2
  []
  [a_v4]
    type = SideAverageValue
    variable = v
    boundary = pipe5:out
    outputs = csv_2
  []
  [a_p4]
    type = SideAverageValue
    variable = p
    boundary = pipe5:out
    outputs = csv_2
  []  
  [a_H4]
    type = SideAverageValue
    variable = H
    boundary = pipe5:out
    outputs = csv_2
  []
  [a_T4]
    type = SideAverageValue
    variable = T
    boundary = pipe5:out
    outputs = csv_2
  []
######################################
[]

[Preconditioning]
  [pc]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  scheme = 'bdf2'

  end_time = ${t3}
  dt = 0.1
#  abort_on_solve_fail = true

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
    growth_factor = 1.1
    cutback_factor = 0.9
  []
  
  solve_type = NEWTON

  nl_abs_tol = 1e-10
  nl_max_its = 15
#  steady_state_detection = true
#  steady_state_start_time = ${t3}
######################
###################### 
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
    file_base = 'open_brayton_cycle'
    execute_vector_postprocessors_on = 'INITIAL'
  []
  [csv_2]
    type = CSV
    file_base = 'meigejiedan'
  []
  [console]
    type = Console
    show = 'shaft_speed p_ratio_comp p_ratio_turb compressor:pressure_ratio turbine:pressure_ratio'
  []
[]

[Functions]
  # compressor pressure ratio
  [rp_comp1]
    type = PiecewiseLinear
    x = '0.2868480 0.3084640 0.3300760 0.3516920 0.3733040 0.3949200 0.4165200 0.4381600 0.4597600 0.4813600 0.5030000 0.5187200'
    y = '1.5153000 1.5088000 1.5032000 1.4984000 1.4914000 1.4863000 1.4846000 1.4756000 1.4540000 1.4237000 1.3856000 1.3506000'
    extrap = true
  []
  [rp_comp2]
    type = PiecewiseLinear
    x = '0.3674120 0.3890240 0.4106400 0.4322400 0.4523200 0.4754800 0.4970800 0.5177200 0.5442400 0.5658800 0.5874800 0.6090800 0.6307200 0.6484000 0.6621600 0.6759200 0.6886800 0.6994800 0.7093200 0.7181600 0.7253600 0.7338800 0.7407600 0.7466400 0.7517600 0.7595600 0.7633600'
    y = '1.7741000 1.7626000 1.7550000 1.7536000 1.7497000 1.7455000 1.7376000 1.7276000 1.7026000 1.6780000 1.6405000 1.5914000 1.5233000 1.4564000 1.3890000 1.3187000 1.2318000 1.1631000 1.0851000 1.0143000 0.9425300 0.8601900 0.7844300 0.7160400 0.6450700 0.5733400 0.5341100'    
    extrap = true
  []
  [rp_comp3]
    type = PiecewiseLinear
    x = '0.4067200 0.4283200 0.4499200 0.4715600 0.4931600 0.5147600 0.5364000 0.5580000 0.5796400 0.6012400 0.6228400 0.6444800 0.6660800 0.6872000 0.7093200 0.7299200 0.7476400 0.7643200 0.7800400 0.7928000 0.8036400 0.8134400 0.8222800 0.8301600 0.8380000 0.8448800 0.8507600 0.8566800 0.8635600 0.8704400 0.8782800'
    y = '2.1535000 2.1352000 2.1251000 2.1192000 2.1135000 2.1088000 2.1071000 2.1068000 2.1043000 2.0975000 2.0877000 2.0742000 2.0539000 2.0272000 1.9813000 1.9245000 1.8643000 1.7959000 1.7227000 1.6551000 1.5896000 1.5110000 1.4403000 1.3714000 1.2969000 1.2326000 1.1655000 1.0985000 1.0177000 0.9385600 0.8578700' 
    extrap = true
  []
  [rp_comp4]
    type = PiecewiseLinear
    x = '0.4872800 0.5088800 0.5304800 0.5521200 0.5737200 0.5953600 0.6169600 0.6385600 0.6602000 0.6818000 0.7034000 0.7250400 0.7466400 0.7682400 0.7898800 0.8114800 0.8330800 0.8547200 0.8753600 0.8940000 0.9097200 0.9224800 0.9342800 0.9450800 0.9568800'
    y = '2.6634000 2.6485000 2.6366000 2.6248000 2.6184000 2.6124000 2.6110000 2.6102000 2.6110000 2.6102000 2.6110000 2.6099000 2.6060000 2.5989000 2.5874000 2.5642000 2.5309000 2.4824000 2.4202000 2.3500000 2.2832000 2.2195000 2.1437000 2.0706000 1.9947000' 
    extrap = true
  []
  [rp_comp5]
    type = PiecewiseLinear
    x = '0.5658800 0.5874800 0.6090800 0.6307200 0.6523200 0.6739200 0.6955600 0.7171600 0.7387600 0.7604000 0.7820000 0.8036400 0.8252400 0.8468400 0.8684800 0.8900800 0.9116800 0.9333200 0.9549200 0.9765200 0.9981600 1.0197600 1.0413600 1.0600400 1.0757600 1.0904800 1.1032800 1.1150800 1.1248800 1.1327600 1.1406000 1.1484800 1.1563200 1.1632000 1.1690800 1.1750000 1.1808800 1.1867600 1.1916800 1.1976000'
    y = '3.4718000 3.4428000 3.4189000 3.3970000 3.3728000 3.3455000 3.3249000 3.3106000 3.2976000 3.2886000 3.2819000 3.2799000 3.2844000 3.2892000 3.2898000 3.2892000 3.2889000 3.2830000 3.2703000 3.2551000 3.2281000 3.1873000 3.1291000 3.0660000 2.9999000 2.9281000 2.8556000 2.7823000 2.7101000 2.6451000 2.5778000 2.5099000 2.4280000 2.3562000 2.2850000 2.2128000 2.1344000 2.0580000 1.9920000 1.9198000' 
    extrap = true
  []

  # compressor efficiency
  [eff_comp1]
    type = ConstantFunction
    value = ${eff_comp}
  []
  [eff_comp2]
    type = ConstantFunction
    value = ${eff_comp}
  []
  [eff_comp3]
    type = ConstantFunction
    value = ${eff_comp}
  []
  [eff_comp4]
    type = ConstantFunction
    value = ${eff_comp}
  []
  [eff_comp5]
    type = ConstantFunction
    value = ${eff_comp}
  []

  # turbine pressure ratio
  [rp_turb0]
    type = ConstantFunction
    value = 1
  []
  [rp_turb1]
    type = PiecewiseLinear
    x = '0.2082520 0.2298640 0.2514800 0.2730960 0.2947080 0.3163240 0.3385240 0.3595520 0.3811640 0.4018000 0.4188400 0.4327600 0.4434800 0.4511200 0.4578000 0.4648800 0.4676400 0.4794000'
    y = '1.1197000 1.1292000 1.1423000 1.1599000 1.1751000 1.1934000 1.2179000 1.2523000 1.2972000 1.3575000 1.4183000 1.4967000 1.5555000 1.6311000 1.7075000 1.7896000 1.8465000 1.9957000'
    extrap = true
  []
  [rp_turb2]
    type = PiecewiseLinear
    x = '0.3674120 0.3890240 0.4106400 0.4322400 0.4538800 0.4705600 0.4922000 0.5079200 0.5196800 0.5275600 0.5354000 0.5422800 0.5491600 0.5590000'
    y = '1.2029000 1.2314000 1.2615000 1.2993000 1.3482000 1.3956000 1.4717000 1.5365000 1.6164000 1.6763000 1.7622000 1.8331000 1.9107000 1.9973000'
    extrap = true
  []
  [rp_turb3]
    type = PiecewiseLinear
    x = '0.4894400 0.5080800 0.5342000 0.5514400 0.5776400 0.5953600 0.6161200 0.6299200 0.6395600 0.6503600 0.6592000 0.6660800 0.6700000 0.6778800 0.6818000 0.6876800 0.6916400 0.6960400 0.6994800 0.7034000 0.7102800 0.7112800 0.7132400 0.7171600'
    y = '1.2856000 1.3172000 1.3532000 1.3853000 1.4625000 1.5312000 1.6149000 1.6750000 1.7413000 1.8149000 1.8875000 1.9559000 2.0013000 2.1282000 2.2221000 2.3390000 2.4564000 2.6010000 2.7379000 2.8729000 3.1802000 3.2705000 3.3605000 3.4468000'
    extrap = true
  []
  [rp_turb4]
    type = PiecewiseLinear
    x = '0.6071200 0.6287600 0.6493600 0.6759200 0.6975200 0.7191200 0.7407600 0.7604000 0.7741600 0.7888800 0.7996800 0.8085200 0.8164000 0.8232800 0.8291600 0.8350800 0.8390000 0.8422800 0.8478400 0.8511600 0.8547200 0.8586400 0.8635600 0.8664800 0.8684800 0.8694400 0.8724000 0.8733600 0.8763200 0.8792800'
    y = '1.3228000 1.3484000 1.3735000 1.4176000 1.4604000 1.5073000 1.5648000 1.6329000 1.6868000 1.7667000 1.8383000 1.9146000 1.9866000 2.0642000 2.1375000 2.2102000 2.2992000 2.3995000 2.5516000 2.6760000 2.8060000 2.9616000 3.1321000 3.2404000 3.3299000 3.4034000 3.4827000 3.5489000 3.6441000 3.7392000'
    extrap = true
  []
  [rp_turb5]
    type = PiecewiseLinear
    x = '0.6975200 0.7191200 0.7407600 0.7623600 0.7839600 0.8056000 0.8304800 0.8488000 0.8704400 0.8920400 0.9136400 0.9352800 0.9549200 0.9716400 0.9853600 0.9971600 1.0079600 1.0168000 1.0244800 1.0296000 1.0364800 1.0404000 1.0443200 1.0459600 1.0480400 1.0492400 1.0531600 1.0576400 1.0610400 1.0639600 1.0669200 1.0705600 1.0736000 1.0755600 1.0787200'
    y = '1.2932000 1.3060000 1.3271000 1.3501000 1.3780000 1.4050000 1.4415000 1.4684000 1.5015000 1.5409000 1.5900000 1.6541000 1.7158000 1.7865000 1.8472000 1.9161000 1.9997000 2.0694000 2.1477000 2.2175000 2.2945000 2.3562000 2.4547000 2.5110000 2.5962000 2.6544000 2.8277000 2.9733000 3.1269000 3.1945000 3.3560000 3.4621000 3.5716000 3.6771000 3.8214000'
    extrap = true
  []

  # turbine efficiency
  [eff_turb1]
    type = ConstantFunction
    value = ${eff_turb}
  []
  [eff_turb2]
    type = ConstantFunction
    value = ${eff_turb}
  []
  [eff_turb3]
    type = ConstantFunction
    value = ${eff_turb}
  []
  [eff_turb4]
    type = ConstantFunction
    value = ${eff_turb}
  []
  [eff_turb5]
    type = ConstantFunction
    value = ${eff_turb}
  []
[]
