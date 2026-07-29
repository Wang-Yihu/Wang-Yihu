# Q = (T_1 - T_2) / (ln(r_2/r_1)/(2*pi*k*L)) / A_1

mesh_num_radial = 10
mesh_num_azimuthal = 40

T_in = 300.
length = 1.0

k = 45

core_dia = ${units 2. cm -> m}
core_dia_add = ${fparse core_dia/5}

tot_power = 100

[Mesh]
  [accg]
    type = AdvancedConcentricCircleGenerator
    ring_radii =       '${fparse core_dia/2} ${fparse core_dia/2 + (core_dia+core_dia_add)/2*9/10}'
    ring_intervals =   '${mesh_num_radial}   ${mesh_num_radial}'
    ring_block_ids =   '15 20                25'
    ring_block_names = 'block_tri block      block_no_source'
    external_boundary_id = 100
    external_boundary_name = 'right'
    num_sectors = ${mesh_num_azimuthal}
#    preserve_volumes = True
  []
[]

[Variables]
  [temp]
    family = LAGRANGE
    initial_condition = ${T_in}
  []
[]

[Kernels]
  [heat_1]
    type = HeatConduction
    variable = temp
    block = 'block_tri block block_no_source'
  []
  [heat_2]
    type = HeatSource
    variable = temp
    function = hsf
    block = 'block_tri block'
  []
[]


# Q = (T_1 - T_2) / (ln(r_2/r_1)/(2*pi*k*L)) / A_1
r_1 = ${fparse core_dia/2 + (core_dia+core_dia_add)/2*9/10}
r_2 = ${fparse core_dia/2 + (core_dia+core_dia_add)/2}
[Functions]
  [hsf]
    type = ParsedFunction
    expression = ${tot_power}/(volume*${length})
    symbol_names = 'volume'
    symbol_values = 'volume'
  []
  [cal_hf]
    type = ParsedFunction
     expression = '1 / (log(${r_2}/${r_1})/(2*pi*${k}*${length})) / area'
    symbol_names = 'area'
    symbol_values = 'area'
  []
[]

[Materials]
  [daore_steel]
    type = HeatConductionMaterial
    temp = temp
    thermal_conductivity = ${k}
    specific_heat = 466
    block = 'block_tri block block_no_source'
  []
  [density]
    type = Density
    block = 'block_tri block block_no_source'
    density = 8050
  []
  [dengxiao_huanrexishu]
    type = ADGenericFunctionMaterial
    boundary = right
    prop_names = hf
    prop_values = cal_hf
  []
[]

[BCs]
  [rightbc]
    type = ADConvectiveHeatFluxScalarTfBC
    variable = temp
    boundary = right
    heat_transfer_coefficient = hf
    T_infinity = 3.572934e+02
  []
[]

[Problem]
  type = FEProblem
[]

[Executioner]
  type = Transient
  start_time = 0
  end_time = 1000
  dt = 10

  line_search = basic
  solve_type = NEWTON

  nl_rel_tol = 1e-5
  nl_abs_tol = 1e-5
  nl_max_its = 5
[]

[Postprocessors]
  [volume]
    type = VolumePostprocessor
    block = 'block_tri block'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [area]
    type = AreaPostprocessor
    boundary = right
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [max_T]
    type = NodalExtremeValue
    variable = temp
  []
[]

[Outputs]
  exodus = true
[]

