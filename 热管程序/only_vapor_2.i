L_e = 1.55
L_i = 0.45
L_c = 2.0
Dv = 0.015
m_dot_max = 0.42e-3
n_e = 10
n_i = 10
n_c = 10
[Mesh]
  [gmg_1]
    type = GeneratedMeshGenerator
    dim = 1
    nx = ${n_e}
    xmin = 0
    xmax = ${fparse L_e}
  []
  [rbg_1]
    type = RenameBoundaryGenerator
    input = gmg_1
    old_boundary = 'left right'
    new_boundary = 'left_1 right_1'
  []
  [rblockg_1]
    type = RenameBlockGenerator
    input = rbg_1
    old_block = 0
    new_block = 1
  []
#######################################################
  [gmg_2]
    type = GeneratedMeshGenerator
    dim = 1
    nx = ${n_i}
    xmin = ${fparse L_e}
    xmax = ${fparse L_e+L_i}
  []
  [rbg_2]
    type = RenameBoundaryGenerator
    input = gmg_2
    old_boundary = 'left right'
    new_boundary = 'left_2 right_2'
  []
  [rblockg_2]
    type = RenameBlockGenerator
    input = rbg_2
    old_block = 0
    new_block = 2
  []
#######################################################
  [gmg_3]
    type = GeneratedMeshGenerator
    dim = 1
    nx = ${n_c}
    xmin = ${fparse L_e+L_i}
    xmax = ${fparse L_e+L_i+L_c}
  []
  [rbg_3]
    type = RenameBoundaryGenerator
    input = gmg_3
    old_boundary = 'left right'
    new_boundary = 'left_3 right_3'
  []
  [rblockg_3]
    type = RenameBlockGenerator
    input = rbg_3
    old_block = 0
    new_block = 3
  []
#######################################################
  [smg_1_2]
    type = StitchedMeshGenerator
    inputs = 'rblockg_1 rblockg_2'
    stitch_boundaries_pairs = 'right_1 left_2'
    clear_stitched_boundary_ids = true
  []
  [smg_1_2_3]
    type = StitchedMeshGenerator
    inputs = 'smg_1_2 rblockg_3'
    stitch_boundaries_pairs = 'right_2 left_3'
    clear_stitched_boundary_ids = true
  []
  [rename_final_blocks]
    type = RenameBlockGenerator
    input = smg_1_2_3
    old_block = '1 2 3'
    new_block = 'vapor_region_e vapor_region_i vapor_region_c'
  []
[]
#######################################################

[Variables]
#  [T]
#    order = FIRST
#    family = LAGRANGE
#    initial_condition = 888
#  []
  
  [u]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0 
  []
  
  [p]
    order = FIRST
    family = LAGRANGE
    initial_condition = 4.74e3
  []

# The magnitudes of the different equations differ too greatly.
# m_dot ~ 1e-4, u ~ 1e2
# Therefore, the initial residual of the mass conservation equation is scaled 
# from the order of 1e-4 to approximately 1, 
# making the line search more likely to accept the full Newton step.
  [m_dot]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    scaling = ${fparse 1/m_dot_max}
  []
[]


[Functions]
  [p_sat_T_na]
    type = PiecewiseLinear
    x = '370.98 394 400 425 461 500 504 555.5 600 620 700 701 800 808 900 954 1000 1100 1156.2 1200 1300 1400'
    y = '1.37E-11 1.01E-10 1.61E-10 1.01E-09 1.01E-08 8.54E-08 1.01E-07 1.01E-06 5.26E-06 1.01E-05 9.87E-05 1.01E-04 8.71E-04 1.01E-03 4.74E-03 1.01E-02 1.85E-02 5.77E-02 1.01E-01 1.52E-01 3.37E-01 5.93E-01'
    scale_factor = 1e6
  []
  
  [rho_sat_T_na_v]
    type = PiecewiseLinear
    x = '800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000'
    y = '0.003 0.017 0.059 0.163 0.381 0.779 1.433 2.433 3.874 5.857 8.485 11.850 16.040'
  []

# We want to get rho_v varying with T and p  
# So we assume the correction factor of ideal gas from saturation to overheat keeping constant.
# Z_sat(T) = p_sat(T)*M/rho_sat(T)/R_u/T  
# rho(T,p) = p*M/Z_sat(T)/R_u/T
# So rho(T,p) = p/p_sat(T) * rho_sat(T)
  [Z_sat_T_na]
    type = ParsedFunction
    value = 'psat * M / (rhosat * Ru * t)'
    vars = 'psat             rhosat          M             Ru'
    vals = 'p_sat_T_na       rho_sat_T_na_v  0.02298976928 8.314462618'
  []
  [gamma_m_function]
    type = ParsedFunction
    value = 'if(x < ${L_e},
                ${m_dot_max}/${L_e},
                if(x < ${fparse L_e+L_i},
                   0.0,
                   -${m_dot_max}/${L_c}))'
  []
[]

[Materials]
  [gamma_m]
    type = ADGenericFunctionMaterial
    prop_names = 'gamma_m'
    prop_values = 'gamma_m_function'
  []
  
  [temporary_alpha]
    type = ADGenericConstantMaterial
    prop_names = 'alpha_v'
    prop_values = '1'
  [] 
   
# IAEA–TECDOC–XXXX Sodium Coolant Handbook: Physical and Chemical Properties
# 2.2.15. Enthalpy increments of Liquid Sodium and Sodium Vapor
# The enthalpy increments of liquid sodium and sodium vapor are defined as the enthalpy
# difference with respect to the solid sodium enthalpy at 298.15 K.
# Enthalpy increments are typically expressed as specific enthalpy increments
# with respect to the mass.
# TABLE 226. LIQUID ENTHALPY INCREMENT AS A FUNCTION OF TEMPERATURE – [114]  
#  [na_saturated_vapor_enthalpy]
#    type = ADPiecewiseLinearInterpolationMaterial
#    variable = T 
#    property = enthalpy_v
#    x = '371 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000 2100 2200 2300 2400 2500 2503.7'
#    y = '4738.47e3 4757.05e3 4817.34e3 4871.97e3 4921.43e3 4966.28e3 5007.09e3 5044.40e3 5078.73e3 5110.51e3 5140.10e3 5167.73e3 5193.47e3 5217.17e3 5238.34e3 5256.01e3 5268.46e3 5272.72e3 5264.96e3 5240.50e3 5188.23e3 5077.61e3 4616.87e3 4294.00e3'
#    extrapolation = false    
#  []
#T ──> p_sat_v
#│
#└──> rho_sat_v
#
#p, p_sat_v, rho_sat_v
#          │
#          ▼
#rho_v = rho_sat_v*p/p_sat_v
#          │
#          ├──> continuity_equation
#          └──> momentum_equation
  # p_sat(T), Pa
#  [na_saturation_pressure]
#    type = ADCoupledValueFunctionMaterial
#
#    function = p_sat_T_na
#    v = 'T'
#
    # 将变量T传给Function的t参数
#    parameter_order = 'T'
#
#   prop_name = p_sat_v
#  []

  # rho_sat(T), kg/m^3
#  [na_saturated_vapor_density]
#    type = ADCoupledValueFunctionMaterial
#
#    function = rho_sat_T_na_v
#    v = 'T'
#    parameter_order = 'T'
#
#    prop_name = rho_sat_v
#  []

  # rho_v(T,p) = rho_sat(T) * p / p_sat(T)
#  [na_vapor_density]
#    type = ADParsedMaterial

#    property_name = rho_v

#    coupled_variables = 'p'
#    material_property_names = 'p_sat_v rho_sat_v'

#   expression = 'rho_sat_v * p / p_sat_v'
#  []
  
  [na_saturated_vapor_density_const]
    type = ADGenericConstantMaterial
    prop_names = 'rho_v_const'
    prop_values = '0.01532'
  []
  
   [na_saturated_vapor_viscosity_const]
    type = ADGenericConstantMaterial
    prop_names = 'viscosity_v_const'   
    prop_values = '0.000016356'    
   []
[]


[Kernels]
  [m_dot_balance]
    type = ADMassFlowRateBalance
    variable = m_dot
    mass_source_material = gamma_m
  []
  [continuity_equation]
    type = ADMassFlowVelocityConstraint
    variable = u
    mass_flow_rate = m_dot
    density = rho_v_const
    diameter = ${Dv}
  []
  [momentum_equation]
    type = ADVaporMomentumEquation
    variable = p
    velocity = u
    density = rho_v_const
    dynamic_viscosity = viscosity_v_const
    momentum_correction = alpha_v
    diameter = ${Dv}
  []
[]


[BCs]
  [m_dot_left]
    type = ADDirichletBC
    variable = m_dot
    boundary = left_1
    value = 0
  []
  [bc_u]
    type = ADDirichletBC
    boundary = 'left_1 right_3'
    variable = u
    value = 0
  []
  [p_reference]
    type = ADDirichletBC
    variable = p
    boundary = left_1
    value = 4.74e3
  []
[]

[Preconditioning]
  [full_smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  
  petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_type'
  petsc_options_value = 'preonly lu superlu_dist'
[]


[Outputs]
  exodus = true
[]
