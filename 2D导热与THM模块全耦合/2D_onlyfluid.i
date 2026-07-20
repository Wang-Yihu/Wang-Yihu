T_in = 300.         # K
m_dot_in = 2e-3     # kg/s
press = 1e5         # Pa

# core parameters
core_length = 1.    # m
core_n_elems = 10
core_dia = ${units 2. cm -> m}
core_dia_add = ${fparse core_dia/5}
core_pitch = ${units 8.7 cm -> m}

tot_power = 2000       # W
#######################################
[Components]
  [hs_external]
    type = FileMeshComponent
    file = 2D_core_heatconduction_in.e
    position = '0 0 0'
  []
[]

[Variables]
  [T_moose]
    block = 'hs_external:block_tri hs_external:block hs_external:block_no_source'
    initial_condition = 3.946429e+02
  []
  [T_flow_average_scalar]
    family = SCALAR
    order = FIRST
    initial_condition = 300
  []
[]

[ScalarKernels]
  [set_flow_average_temperature]
    type = ADFlowTemperatureAverageScalarKernel
    variable = T_flow_average_scalar
    temperature_average_userobject = flow_temperature_average
  []
[]

[Kernels]
  [time_derivative]
    type = ADHeatConductionTimeDerivative
    variable = T_moose
    block = 'hs_external:block_tri hs_external:block hs_external:block_no_source'
    density_name = density
    specific_heat = specific_heat
  []
  [heat_conduction]
    type = ADHeatConduction
    variable = T_moose
    block = 'hs_external:block_tri hs_external:block hs_external:block_no_source'
    thermal_conductivity = thermal_conductivity
  []
  [source]
    type = HeatSource
    variable = T_moose
    block = 'hs_external:block_tri hs_external:block'
    function = hsf
  []
[]

[Functions]
  [hsf]
    type = ParsedFunction
    expression = ${tot_power}/(volume*${core_length})
    symbol_names = 'volume'
    symbol_values = 'volume'
  []
[]

[Postprocessors]
  [volume]
    type = VolumePostprocessor
    block = 'hs_external:block_tri hs_external:block'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [max_T_moose]
    type = ElementExtremeValue
    variable = T_moose
    block = 'hs_external:block_tri hs_external:block'
  []
  [scalar_T_flow_average_scalar]
    type = ScalarVariable
    variable = T_flow_average_scalar
  []
  [boundary_average_T_moose]
    type = SideAverageValue
    boundary = hs_external:right
    variable = T_moose
  []
[]

[BCs]
  [ouhebianjie]
    type = ADConvectiveHeatFluxScalarTfBC
    T_infinity = T_flow_average_scalar
    heat_transfer_coefficient = 265.3
    boundary = hs_external:right
    variable = T_moose
  []
[]

[Materials]
  [prop_mat]
    type = ADGenericConstantMaterial
    prop_names = 'density specific_heat thermal_conductivity'
    prop_values = '8050 466 4.5'
  []
[]
#######################################
[GlobalParams]
  initial_p = ${press}
  initial_vel = 0
  initial_T = ${T_in}

  rdg_slope_reconstruction = full
  closures = simple_closures
  fp = he
[]

[FluidProperties]
  [he]
    type = IdealGasFluidProperties
    molar_mass = 4e-3
    gamma = 1.67
    k = 0.2556
    mu = 3.22639e-5
  []
[]

[Closures]
  [simple_closures]
    type = Closures1PhaseSimple
  []
[]

[HeatStructureMaterials]
  [steel]
    type = SolidMaterialProperties
    rho = 8050
    k = 4.5
    cp = 466
  []
[]

[Components]
  [total_power]
    type = TotalPower
    power = ${tot_power}
  []

  [inlet]
    type = InletMassFlowRateTemperature1Phase
    input = 'core_chan:in'
    m_dot = ${m_dot_in}
    T = ${T_in}
  []

  [core_chan]
    type = FlowChannel1Phase
    position = '0 0 0'
    orientation = '0 0 1'
    length = ${core_length}
    n_elems = ${core_n_elems}
    A = ${fparse core_pitch * core_pitch- pi * (core_dia + core_dia_add)* (core_dia + core_dia_add) / 4.}
    D_h = ${fparse (4 * core_pitch * core_pitch - pi * (core_dia + core_dia_add) * (core_dia + core_dia_add))/(4 * core_pitch + pi * (core_dia + core_dia_add))}
    f = 1.6
  []

  [outlet]
    type = Outlet1Phase
    input = 'core_chan:out'
    p = ${press}
  []
[]

[Kernels]
  [solid_heat_into_thm]
    type = ADOneDEnergyFromHeatRateUO
    variable = rhoEA
    block = core_chan
    heat_rate_userobject = solid_to_fluid_heat_rate
    channel_length = ${core_length}
  []
[]

[Executioner]
  type = Transient
  start_time = 0
  end_time = 400000
#  dt = 10

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
    growth_factor = 1.1
    cutback_factor = 0.9
  []

  line_search = basic
  solve_type = NEWTON

  nl_rel_tol = 1e-7
  nl_abs_tol = 1e-7
  nl_max_its = 5
[]

[Postprocessors]
  [T_outlet]
    type = SideAverageValue
    variable = T
    boundary = core_chan:out
  []
  [T_inlet]
    type = SideAverageValue
    variable = T
    boundary = core_chan:in
  []
[]

[UserObjects] 
  [flow_temperature_average] 
    type = ADFlowTemperatureAverageUserObject 
    block = core_chan 
    temperature_property = T 
    execute_on = 'INITIAL LINEAR NONLINEAR' 
  []
  [solid_to_fluid_heat_rate]
    type = ADHeatRateSideUserObject
    temperature = T_moose
    T_wall = T_flow_average_scalar
    heat_transfer_coefficient = 265.3
    scale = ${core_length}
    boundary = hs_external:right
    execute_on = 'INITIAL LINEAR NONLINEAR' 
  []
[]

[Outputs]
  exodus = true
[]
