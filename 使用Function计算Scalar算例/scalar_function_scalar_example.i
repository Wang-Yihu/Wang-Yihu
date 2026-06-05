# x + 2*x + y = 10
# x   - y = 2
# So, x = 3, y = 1
[Mesh/generate]
  type = GeneratedMeshGenerator
  dim = 1
[]

[Variables]
  [./x]
    family = SCALAR
    order  = FIRST
    initial_condition = 0
  [../]
  [./y]
    family = SCALAR
    order  = FIRST
    initial_condition = 0
  [../]
[]

[AuxVariables]
  [./aux_scalar]
    family = SCALAR
    order  = FIRST
    initial_condition = 0
  [../]
[]

# x + 2*x + y = 10
# x   - y = 2
# So, x = 3, y = 1

[ScalarKernels]
  [./eq1]
    type = ParsedODEKernel
    expression = '-x - aux_scalar - y + 10'
    coupled_variables = 'x aux_scalar'
    variable = y
  [../]
  [./eq2]
    type = ParsedODEKernel
    expression = '-x + y + 2'
    coupled_variables = y
    variable = x
  []
[]

[AuxScalarKernels]
  [cal_aux_scalar]
    type = ScalarFunctionToScalarAux
    input_scalar = x
    input_function = xianxing_chazhi
    variable = aux_scalar
  []
[]

[Functions]
  [xianxing_chazhi]
    type = PiecewiseLinear
    x = '0 1 2 3 4 5'
    y = '0 2 4 6 8 10'
    extrap = true
  []
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
[]


[Outputs]
  exodus = false
  csv = true
[]
