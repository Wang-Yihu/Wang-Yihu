# 1D heat-pipe vapor model rewritten with Navier-Stokes FV kernels
# Improved verification version:
#   1. Rhie-Chow face-velocity interpolation suppresses pressure checkerboarding.
#   2. Central (average) momentum advection reduces the first-order upwind error
#      for this smooth, one-directional verification problem.
#   3. All three sections use the same cell size, avoiding abrupt mesh-size jumps.
#   4. INSFVMomentumFriction is used because this is a free-flow vapor core,
#      not a porous-medium momentum equation.
# Governing equations:
#   d(rho*u*A_v)/dx = Gamma_m
#   d(rho*u^2*A_v)/dx = -d(p*A_v)/dx - 32*mu*u*A_v/D_v^2
#
# Since A_v is constant:
#   d(rho*u)/dx - Gamma_m/A_v = 0
#   d(rho*u^2)/dx + dp/dx + 32*mu*u/D_v^2 = 0
#
# IMPORTANT:
#   m_dot is NOT a nonlinear variable in this file.
#   The continuity equation is solved directly together with u and pressure.

L_e = 1.55
L_i = 0.45
L_c = 2.0

Dv = 0.015
A_v = ${fparse 3.141592653589793*Dv*Dv/4}

m_dot_max = 0.42e-3

# Uniform axial cell size: dx = 0.05 m in all three sections.
n_e = 31
n_i = 9
n_c = 40

rho_v = 0.01532
mu_v = 0.000016356

# Physical pressure reference for the analytical solution: p(0) = p_left.
p_left = 4.74e3

# Useful constants for the analytical solution and the FV pressure constraint.
u_max = ${fparse m_dot_max/(rho_v*A_v)}
linear_friction_coefficient = ${fparse 32*mu_v/(Dv*Dv)}

# FV pressure is cell centered.  Constrain the first-cell value to the
# analytical pressure at its centroid instead of incorrectly setting that
# cell-center value equal to the boundary value p(0).
dx = ${fparse L_e/n_e}
x_reference = ${fparse dx/2}
p_reference = ${fparse p_left-rho_v*u_max*u_max*x_reference*x_reference/(L_e*L_e)-linear_friction_coefficient*u_max*x_reference*x_reference/(2*L_e)}

velocity_interp_method = 'rc'
advected_interp_method = 'average'

gamma_e = ${fparse  m_dot_max/L_e/A_v}
gamma_c = ${fparse -m_dot_max/L_c/A_v}


[GlobalParams]
  rhie_chow_user_object = rc
  velocity_interp_method = ${velocity_interp_method}
[]


[Mesh]
  [gmg_1]
    type = GeneratedMeshGenerator
    dim = 1
    nx = ${n_e}
    xmin = 0
    xmax = ${L_e}
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

  [gmg_2]
    type = GeneratedMeshGenerator
    dim = 1
    nx = ${n_i}
    xmin = ${L_e}
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


[Variables]
  [u]
    type = INSFVVelocityVariable
  []

  [pressure]
    type = INSFVPressureVariable
  []

  # Used only to fix the pressure reference
  [lambda_p]
    type = MooseVariableScalar
  []
[]


[UserObjects]
  [rc]
    type = INSFVRhieChowInterpolator
    u = u
    pressure = pressure
  []
[]


[Functions]
  # Initial velocity obtained from
  #   d(rho*u*A_v)/dx = Gamma_m
  # with u(0)=0 and constant rho.
  #
  # Evaporator: u increases linearly from 0.
  # Adiabatic section: u is constant.
  # Condenser: u decreases linearly back to 0.
  [u_init]
    type = ParsedFunction
    expression = 'if(x < ${L_e},
                     ${m_dot_max}*x/(${L_e}*${rho_v}*${A_v}),
                     if(x < ${fparse L_e+L_i},
                        ${m_dot_max}/(${rho_v}*${A_v}),
                        ${m_dot_max}*(1-(x-${fparse L_e+L_i})/${L_c})/(${rho_v}*${A_v})))'
  []

  # Gamma_m / A_v, units kg/(m^3 s)
  [gamma_v]
    type = ParsedFunction
    expression = 'if(x < ${L_e},
                     ${gamma_e},
                     if(x < ${fparse L_e+L_i},
                        0.0,
                        ${gamma_c}))'
  []

  # Analytical pressure corresponding to p(0)=p_left and
  #   dp/dx = -rho*d(u^2)/dx - (32*mu/Dv^2)*u.
  [p_exact]
    type = ParsedFunction
    expression = 'if(x < ${L_e},
                     ${p_left}
                     - ${rho_v}*(${u_max}*x/${L_e})^2
                     - ${linear_friction_coefficient}*${u_max}*x^2/(2*${L_e}),
                     if(x < ${fparse L_e+L_i},
                        ${p_left}
                        - ${rho_v}*${u_max}^2
                        - ${linear_friction_coefficient}*(${u_max}*${L_e}/2+${u_max}*(x-${L_e})),
                        ${p_left}
                        - ${rho_v}*(${u_max}*(${fparse L_e+L_i+L_c}-x)/${L_c})^2
                        - ${linear_friction_coefficient}*(${u_max}*${L_e}/2+${u_max}*${L_i}+${u_max}*((x-${fparse L_e+L_i})-(x-${fparse L_e+L_i})^2/(2*${L_c})))))'
  []
[]


[ICs]
  [u_ic]
    type = FunctionIC
    variable = u
    function = u_init
  []

  [pressure_ic]
    type = FunctionIC
    variable = pressure
    function = p_exact
  []
[]


[FunctorMaterials]
  # INSFVMomentumFriction contributes C_L*u to the momentum residual.
  # Therefore choose C_L = 32*mu_v/Dv^2, giving exactly the desired
  # vapor-core wall-friction term 32*mu_v*u/Dv^2.
  [linear_wall_friction]
    type = ADGenericFunctorMaterial
    prop_names = 'linear_wall_friction'
    prop_values = '${linear_friction_coefficient}'
  []

  # Diagnostic functor used only to report the maximum pressure error.
  [pressure_error]
    type = ADParsedFunctorMaterial
    expression = 'abs(P-P_exact)'
    functor_names = 'pressure p_exact'
    functor_symbols = 'P P_exact'
    property_name = 'pressure_abs_error'
  []
[]


[FVKernels]
  # ============================================================
  # Continuity:
  #
  # d(rho*u)/dx - Gamma_m/A_v = 0
  # ============================================================

  [mass_advection]
    type = INSFVMassAdvection
    variable = pressure
    rho = ${rho_v}
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
  []

  # FVBodyForce contributes -function to the residual,
  # therefore this gives -Gamma_m/A_v.
  [mass_source]
    type = FVBodyForce
    variable = pressure
    function = gamma_v
  []


  # ============================================================
  # x-momentum:
  #
  # d(rho*u^2)/dx + dp/dx + 32*mu*u/D_v^2 = 0
  # ============================================================

  [u_advection]
    type = INSFVMomentumAdvection
    variable = u
    rho = ${rho_v}
    momentum_component = x
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
  []

  [u_pressure]
    type = INSFVMomentumPressure
    variable = u
    pressure = pressure
    momentum_component = x
  []

  # Wall-friction term:
  #   + 32*mu_v*u/Dv^2
  # in the left-hand-side momentum residual.
  [u_friction]
    type = INSFVMomentumFriction
    variable = u
    linear_coef_name = linear_wall_friction
    momentum_component = x
  []


  # Fix the pressure level without putting a pressure BC
  # on the same closed end where u = 0.
  #
  # In FV this constrains the pressure value in the cell containing the
  # specified point.  The value is p_exact at the first-cell centroid,
  # so the underlying physical reference remains p(0)=p_left.
  [pressure_reference]
    type = FVPointValueConstraint
    variable = pressure
    lambda = lambda_p
    point = '${x_reference} 0 0'
    phi0 = ${p_reference}
  []
[]


[AuxVariables]
  [pressure_exact_output]
    type = MooseVariableFVReal
  []
  [pressure_abs_error_output]
    type = MooseVariableFVReal
  []
  [velocity_exact_output]
    type = MooseVariableFVReal
  []
[]


[AuxKernels]
  [pressure_exact_aux]
    type = FunctionAux
    variable = pressure_exact_output
    function = p_exact
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [pressure_abs_error_aux]
    type = ADFunctorElementalAux
    variable = pressure_abs_error_output
    functor = pressure_abs_error
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [velocity_exact_aux]
    type = FunctionAux
    variable = velocity_exact_output
    function = u_init
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]


[FVBCs]
  # Both ends of the vapor space are closed.
  [u_left]
    type = INSFVNoSlipWallBC
    variable = u
    boundary = left_1
    function = 0
  []

  [u_right]
    type = INSFVNoSlipWallBC
    variable = u
    boundary = right_3
    function = 0
  []
[]


[Executioner]
  type = Steady
  solve_type = NEWTON

  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-8
  nl_max_its = 50

  petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_type -pc_factor_shift_type'
  petsc_options_value = 'preonly   lu       superlu_dist               NONZERO'
[]


[Postprocessors]
# When using this, you must input
# conda activate moose
#  [max_pressure_abs_error]
#    type = ADElementExtremeFunctorValue
#    functor = pressure_abs_error
#    value_type = max
#    execute_on = 'INITIAL TIMESTEP_END'
#  []
[]


[Outputs]
  exodus = true
  csv = true
[]

[Debug]
  show_var_residual_norms = true
[]


