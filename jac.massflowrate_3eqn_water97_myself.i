# We can see that delta_p_f = f * length/D_h * 0.5 * rho * u**2 approximately in this example by me.
# But the result is highly depended on n_elems.
[GlobalParams]
  gravity_vector = '0 0 0'

  initial_T = 444.447
  initial_p = 7e6
  initial_vel = 0

  closures = simple_closures
[]

[FluidProperties]
  [fp]
    type = Water97FluidProperties
    T_initial_guess = 444.447
    p_initial_guess = 7e6
  []
[]

[Closures]
  [simple_closures]
    type = Closures1PhaseSimple
  []
[]

[Components]
  [pipe]
    type = FlowChannel1Phase
    fp = fp
    # geometry
    position = '0 0 0'
    orientation = '1 0 0'
    A   = 1.0000000000e-04
    D_h  = 1.1283791671e-02
    f = 0.1
    length = 1
    n_elems = 30
  []

  [inlet]
    type = InletMassFlowRateTemperature1Phase
    input = 'pipe:in'
    m_dot = 1.8 # 0.18
    T     = 444.447
  []

  [outlet]
    type = Outlet1Phase
    input = 'pipe:out'
    p = 7e6
  []
[]

[Postprocessors]
  [a_mdot1]
    type = ADFlowBoundaryFlux1Phase
    boundary = inlet
    equation = mass
    outputs = csv_2
  []
  [a_vel1_x]
    type = SideAverageValue
    variable = vel_x
    boundary = pipe:in
    outputs = csv_2
  []
  [a_v1]
    type = SideAverageValue
    variable = v
    boundary = pipe:in
    outputs = csv_2
  []
  [a_p1]
    type = SideAverageValue
    variable = p
    boundary = pipe:in
    outputs = csv_2
  []  
  [a_H1]
    type = SideAverageValue
    variable = H
    boundary = pipe:in
    outputs = csv_2
  []
  [a_T1]
    type = SideAverageValue
    variable = T
    boundary = pipe:in
    outputs = csv_2
  []
######################################
  [a_mdot2]
    type = ADFlowBoundaryFlux1Phase
    boundary = outlet
    equation = mass
    outputs = csv_2
  []
  [a_vel2_x]
    type = SideAverageValue
    variable = vel_x
    boundary = pipe:out
    outputs = csv_2
  []
  [a_v2]
    type = SideAverageValue
    variable = v
    boundary = pipe:out
    outputs = csv_2
  []
  [a_p2]
    type = SideAverageValue
    variable = p
    boundary = pipe:out
    outputs = csv_2
  []  
  [a_H2]
    type = SideAverageValue
    variable = H
    boundary = pipe:out
    outputs = csv_2
  []
  [a_T2]
    type = SideAverageValue
    variable = T
    boundary = pipe:out
    outputs = csv_2
  []
[]

[Preconditioning]
  [SMP_PJFNK]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  scheme = 'bdf2'

  dt = 0.1
  start_time = 0.0
  num_steps = 30

  solve_type = 'NEWTON'
  line_search = 'basic'
  nl_rel_tol = 0
  nl_abs_tol = 1e-6
  nl_max_its = 20

  l_tol = 1e-3
  l_max_its = 100

  abort_on_solve_fail = true

  [Quadrature]
    type = GAUSS
    order = SECOND
  []
[]

[Outputs]
  exodus = true
  [csv_2]
    type = CSV
  []
[]
