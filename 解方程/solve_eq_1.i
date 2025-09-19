#Solving equation x + ln(x) = 0
#x = 0.567143...
n0 = 10
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
[]

[ScalarKernels]

  [./ode_nt]
    type = ParsedODEKernel
    expression = 'nt +log(nt)'
    variable = nt
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
  type = Steady
  solve_type = 'PJFNK'
[]

[Outputs]
  [nt_output]
    type = CSV
    file_base = 'output_nt'
  []
  exodus = true
[]
