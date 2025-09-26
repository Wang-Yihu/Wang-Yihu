# [dnt/dt] = (rhot-beta)/LAMBDA * nt +lambda1*C1 + ... + lambda6*C6
# [dC1/dt] = beta1/LAMBDA * nt - lambda1*C1
# ......
# [dC6/dt] = beta6/LAMBDA * nt - lambda6*C6
# 
LAMBDA = 2E-5
beta1 = 0.000266
beta2 = 0.001491
beta3 = 0.001316
beta4 = 0.002849
beta5 = 0.000896
beta6 = 0.000182
beta  = ${fparse beta1 + beta2 + beta3 + beta4 + beta5 + beta6}
lambda1 = 0.0127
lambda2 = 0.0317
lambda3 = 0.115
lambda4 = 0.311
lambda5 = 1.4
lambda6 = 3.87
n0 = 1.0
C10 = ${fparse beta1*n0/lambda1/LAMBDA }
C20 = ${fparse beta2*n0/lambda2/LAMBDA }
C30 = ${fparse beta3*n0/lambda3/LAMBDA }
C40 = ${fparse beta4*n0/lambda4/LAMBDA }
C50 = ${fparse beta5*n0/lambda5/LAMBDA }
C60 = ${fparse beta6*n0/lambda6/LAMBDA }
rho = 0.003

[Mesh/generate]
  type = GeneratedMeshGenerator
  dim = 1
[]

[Variables]
  [./nt]
    family = SCALAR
    order = FIRST
    initial_condition = ${fparse n0}
  []
  [./C1]
    family = SCALAR
    order = FIRST
    initial_condition = ${fparse C10}
  []
  [./C2]
    family = SCALAR
    order = FIRST
    initial_condition = ${fparse C20}
  []
  [./C3]
    family = SCALAR
    order = FIRST
    initial_condition = ${fparse C30}
  []
  [./C4]
    family = SCALAR
    order = FIRST
    initial_condition = ${fparse C40}
  []
  [./C5]
    family = SCALAR
    order = FIRST
    initial_condition = ${fparse C50}
  []
  [./C6]
    family = SCALAR
    order = FIRST
    initial_condition = ${fparse C60}
  []
[]

[ScalarKernels]
  [./td_nt]
    type = ODETimeDerivative
    variable = nt
  [../]
  [./td_C1]
    type = ODETimeDerivative
    variable = C1
  [../]
  [./td_C2]
    type = ODETimeDerivative
    variable = C2
  [../]
  [./td_C3]
    type = ODETimeDerivative
    variable = C3
  [../]
  [./td_C4]
    type = ODETimeDerivative
    variable = C4
  [../]
  [./td_C5]
    type = ODETimeDerivative
    variable = C5
  [../]
  [./td_C6]
    type = ODETimeDerivative
    variable = C6
  [../]
################################################################################
  [./ode_nt]
    type = ParsedODEKernel
    expression = '-(${rho}-${beta})/${LAMBDA}*nt-(${lambda1}*C1+${lambda2}*C2+${lambda3}*C3+${lambda4}*C4+${lambda5}*C5+${lambda6}*C6)'
    coupled_variables = 'C1 C2 C3 C4 C5 C6'
    variable = nt
  [../]
  [./ode_C1]
    type = ParsedODEKernel
    expression = '-${beta1}/${LAMBDA}*nt+${lambda1}*C1'
    coupled_variables = nt
    variable = C1
  [../]
  [./ode_C2]
    type = ParsedODEKernel
    expression = '-${beta2}/${LAMBDA}*nt+${lambda2}*C2'
    coupled_variables = nt
    variable = C2
  [../]
  [./ode_C3]
    type = ParsedODEKernel
    expression = '-${beta3}/${LAMBDA}*nt+${lambda3}*C3'
    coupled_variables = nt
    variable = C3
  [../]
  [./ode_C4]
    type = ParsedODEKernel
    expression = '-${beta4}/${LAMBDA}*nt+${lambda4}*C4'
    coupled_variables = nt
    variable = C4
  [../]
  [./ode_C5]
    type = ParsedODEKernel
    expression = '-${beta5}/${LAMBDA}*nt+${lambda5}*C5'
    coupled_variables = nt
    variable = C5
  [../]
  [./ode_C6]
    type = ParsedODEKernel
    expression = '-${beta6}/${LAMBDA}*nt+${lambda6}*C6'
    coupled_variables = nt
    variable = C6
  [../]
[]

[Postprocessors]
  [output_nt]
    type = ScalarVariable
    variable = nt
    outputs = 'nt_output'

  [] 
[]

[Executioner]
  type = Transient
#  nl_abs_tol = 1e-3
#  nl_rel_tol = 0.5
  dt = 0.01
  num_steps = 100
  solve_type = 'PJFNK'
#  nl_rel_tol = 1e-1
#  l_tol = 1e-8
#  nl_forced_its = 5
[]

[Outputs]
  [nt_output]
    type = CSV
    file_base = 'output_nt'
#    time_step_intervals = 10   # An error input parameters!
    sync_only = True
    sync_times = '0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0'
  []
  exodus = true
[]
