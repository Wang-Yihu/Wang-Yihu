total_power = 34.12e3
#power_factor = 0.25
power_factor = 1.0
heated_rod_position = ${fparse 117.0e-3}
heated_rod_length = ${fparse 1200.0e-3}

r_heated_clad_in = ${fparse 17.4e-3/2}                                   # 8.7e-3
thick_MgO = ${fparse 1.55e-3}
r_heated = ${fparse r_heated_clad_in - thick_MgO}                        # 7.15e-3
heated_num = 42
S_heated_total = ${fparse pi*r_heated*r_heated*heated_num}               # 6745.45495048425e-6

f0_z = ${fparse 0.0/1200.0*heated_rod_length+heated_rod_position}
f1_z = ${fparse 50.0/1200.0*heated_rod_length+heated_rod_position}
f2_z = ${fparse 150.0/1200.0*heated_rod_length+heated_rod_position}
f3_z = ${fparse 250.0/1200.0*heated_rod_length+heated_rod_position}
f4_z = ${fparse 350.0/1200.0*heated_rod_length+heated_rod_position}
f5_z = ${fparse 450.0/1200.0*heated_rod_length+heated_rod_position}
f6_z = ${fparse 550.0/1200.0*heated_rod_length+heated_rod_position}
f7_z = ${fparse 600.0/1200.0*heated_rod_length+heated_rod_position}
f8_z = ${fparse 650.0/1200.0*heated_rod_length+heated_rod_position}
f9_z = ${fparse 750.0/1200.0*heated_rod_length+heated_rod_position}
f10_z = ${fparse 850.0/1200.0*heated_rod_length+heated_rod_position}
f11_z = ${fparse 950.0/1200.0*heated_rod_length+heated_rod_position}
f12_z = ${fparse 1050.0/1200.0*heated_rod_length+heated_rod_position}
f13_z = ${fparse 1150.0/1200.0*heated_rod_length+heated_rod_position}
f14_z = ${fparse 1200.0/1200.0*heated_rod_length+heated_rod_position}

f0 = 0.105861
f1 = 0.291601
f2 = 0.646599
f3 = 0.961385
f4 = 1.216385
f5 = 1.395739
f6 = 1.488294
f7 = 1.50
f8 = 1.488294
f9 = 1.395739
f10 = 1.216385
f11 = 0.961385
f12 = 0.646599
f13 = 0.291601
f14 = 0.105861

integ = ${fparse (    (f0+f1)*(f1_z-f0_z) + (f1+f2)*(f2_z-f1_z) + (f2+f3)*(f3_z-f2_z) + (f3+f4)*(f4_z-f3_z) + (f4+f5)*(f5_z-f4_z) + (f5+f6)*(f6_z-f5_z) + (f6+f7)*(f7_z-f6_z) + (f7+f8)*(f8_z-f7_z) + (f8+f9)*(f9_z-f8_z) + (f9+f10)*(f10_z-f9_z) + (f10+f11)*(f11_z-f10_z) + (f11+f12)*(f12_z-f11_z) + (f12+f13)*(f13_z-f12_z) + (f13+f14)*(f14_z-f13_z)    )/2}

kp = ${fparse total_power*power_factor/S_heated_total/integ} 

s0 = ${fparse kp*f0}
s1 = ${fparse kp*f1} 
s2 = ${fparse kp*f2} 
s3 = ${fparse kp*f3} 
s4 = ${fparse kp*f4} 
s5 = ${fparse kp*f5} 
s6 = ${fparse kp*f6} 
s7 = ${fparse kp*f7} 
s8 = ${fparse kp*f8} 
s9 = ${fparse kp*f9} 
s10 = ${fparse kp*f10} 
s11 = ${fparse kp*f11} 
s12 = ${fparse kp*f12}
s13 = ${fparse kp*f13}
s14 = ${fparse kp*f14}  

h_monolith_heated = 4432.0
h_monolith_hp = 3693.0
r_hole = ${fparse 19.1e-3/2}
#r_hp = ${fparse 19.0e-3/2}
r_heated_clad_out = ${fparse 19.0e-3/2}
k_gap_heated = ${fparse h_monolith_heated*log(r_hole/r_heated_clad_out)*r_hole}
#k_gap_hp =  ${fparse h_monolith_hp*log(r_hole/r_hp)*r_hole}
k_MgO = 30.0 #https://www.azom.com/properties.aspx?ArticleID=54

pitch = 21.0e-3

x1 = 0

y1 = 0

x2 = ${fparse 2*pitch*cos(1*pi/6)}
x3 = ${fparse 2*pitch*cos(3*pi/6)}
x4 = ${fparse 2*pitch*cos(5*pi/6)}
x5 = ${fparse 2*pitch*cos(7*pi/6)}
x6 = ${fparse 2*pitch*cos(9*pi/6)}
x7 = ${fparse 2*pitch*cos(11*pi/6)}

y2 = ${fparse 2*pitch*sin(1*pi/6)}
y3 = ${fparse 2*pitch*sin(3*pi/6)}
y4 = ${fparse 2*pitch*sin(5*pi/6)}
y5 = ${fparse 2*pitch*sin(7*pi/6)}
y6 = ${fparse 2*pitch*sin(9*pi/6)}
y7 = ${fparse 2*pitch*sin(11*pi/6)}

x8 = ${fparse 4*pitch*cos(1*pi/6)}
x9 = ${fparse 4*pitch*cos(2*pi/6)}
x10 = ${fparse 4*pitch*cos(3*pi/6)}
x11 = ${fparse 4*pitch*cos(4*pi/6)}
x12 = ${fparse 4*pitch*cos(5*pi/6)}
x13 = ${fparse 4*pitch*cos(6*pi/6)}
x14 = ${fparse 4*pitch*cos(7*pi/6)}
x15 = ${fparse 4*pitch*cos(8*pi/6)}
x16 = ${fparse 4*pitch*cos(9*pi/6)}
x17 = ${fparse 4*pitch*cos(10*pi/6)}
x18 = ${fparse 4*pitch*cos(11*pi/6)}
x19 = ${fparse 4*pitch*cos(12*pi/6)}

y8 = ${fparse 4*pitch*sin(1*pi/6)}
y9 = ${fparse 4*pitch*sin(2*pi/6)}
y10 = ${fparse 4*pitch*sin(3*pi/6)}
y11 = ${fparse 4*pitch*sin(4*pi/6)}
y12 = ${fparse 4*pitch*sin(5*pi/6)}
y13 = ${fparse 4*pitch*sin(6*pi/6)}
y14 = ${fparse 4*pitch*sin(7*pi/6)}
y15 = ${fparse 4*pitch*sin(8*pi/6)}
y16 = ${fparse 4*pitch*sin(9*pi/6)}
y17 = ${fparse 4*pitch*sin(10*pi/6)}
y18 = ${fparse 4*pitch*sin(11*pi/6)}
y19 = ${fparse 4*pitch*sin(12*pi/6)}

assemble_length = ${fparse 1550.0e-3}

z1 = ${fparse assemble_length/2}
z2 = ${fparse assemble_length/2}
z3 = ${fparse assemble_length/2}
z4 = ${fparse assemble_length/2}
z5 = ${fparse assemble_length/2}
z6 = ${fparse assemble_length/2}
z7 = ${fparse assemble_length/2}
z8 = ${fparse assemble_length/2}
z9 = ${fparse assemble_length/2}
z10 = ${fparse assemble_length/2}
z11 = ${fparse assemble_length/2}
z12 = ${fparse assemble_length/2}
z13 = ${fparse assemble_length/2}
z14 = ${fparse assemble_length/2}
z15 = ${fparse assemble_length/2}
z16 = ${fparse assemble_length/2}
z17 = ${fparse assemble_length/2}
z18 = ${fparse assemble_length/2}
z19 = ${fparse assemble_length/2}

[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = './snerdi_experiment_mesh_zhiyoujiti_3_in.e'
  []
[]

[Functions]
  [gonglvmidu_fenbu]
    type = PiecewiseLinear
    axis = z
    x = '${f0_z} ${f1_z} ${f2_z} ${f3_z} ${f4_z} ${f5_z} ${f6_z} ${f7_z} ${f8_z} ${f9_z} ${f10_z} ${f11_z} ${f12_z} ${f13_z} ${f14_z}'
    y = '${s0} ${s1} ${s2} ${s3} ${s4} ${s5} ${s6} ${s7} ${s8} ${s9} ${s10} ${s11} ${s12} ${s13} ${s14}'
  []
  [k_ss316]
    type = PiecewiseLinear
    x = '293.15 373.15 473.15 573.15 673.15 773.15 873.15 973.15 1073.15 1173.15 1273.15'  
    y = '13.49  14.87  16.35  17.87  19.27  20.75  22.43  23.56  24.73   25.85   27.07'
  []
  [k_na_wick_084]
    type = PiecewiseLinear
    x = '371.0 400.0 500.0 600.0 700.0 800.0 900.0 1000.0 1100.0 1156.0 1200.0 1300.0 1400.0 1500.0 1600.0 1644.0 1700.0 1800.0 1900.0 2000.0 2100.0 2200.0 2300.0 2400.0 2500.0 2503.7'
    y = '71.272 69.878 65.381 61.318 57.638 54.305 51.276 48.501 45.944 44.586 43.553 41.283 39.085 36.918 34.711 33.714 32.418 29.970 27.309 24.363 21.035 17.215 12.740 7.330 0.384 0.069'
  []
  [fun_receive_hp_temp_1]
    type = ParsedFunction
    expression = 'vpc_1'
    symbol_names = 'vpc_1'
    symbol_values = 'vpc_1'
  []
  [fun_receive_hp_temp_2]
    type = ParsedFunction
    expression = 'vpc_2'
    symbol_names = 'vpc_2'
    symbol_values = 'vpc_2'
  []
  [fun_receive_hp_temp_3]
    type = ParsedFunction
    expression = 'vpc_3'
    symbol_names = 'vpc_3'
    symbol_values = 'vpc_3'
  []
  [fun_receive_hp_temp_4]
    type = ParsedFunction
    expression = 'vpc_4'
    symbol_names = 'vpc_4'
    symbol_values = 'vpc_4'
  []
  [fun_receive_hp_temp_5]
    type = ParsedFunction
    expression = 'vpc_5'
    symbol_names = 'vpc_5'
    symbol_values = 'vpc_5'
  []
  [fun_receive_hp_temp_6]
    type = ParsedFunction
    expression = 'vpc_6'
    symbol_names = 'vpc_6'
    symbol_values = 'vpc_6'
  []
  [fun_receive_hp_temp_7]
    type = ParsedFunction
    expression = 'vpc_7'
    symbol_names = 'vpc_7'
    symbol_values = 'vpc_7'
  []
  [fun_receive_hp_temp_8]
    type = ParsedFunction
    expression = 'vpc_8'
    symbol_names = 'vpc_8'
    symbol_values = 'vpc_8'
  []
  [fun_receive_hp_temp_9]
    type = ParsedFunction
    expression = 'vpc_9'
    symbol_names = 'vpc_9'
    symbol_values = 'vpc_9'
  []
  [fun_receive_hp_temp_10]
    type = ParsedFunction
    expression = 'vpc_10'
    symbol_names = 'vpc_10'
    symbol_values = 'vpc_10'
  []
  [fun_receive_hp_temp_11]
    type = ParsedFunction
    expression = 'vpc_11'
    symbol_names = 'vpc_11'
    symbol_values = 'vpc_11'
  []
  [fun_receive_hp_temp_12]
    type = ParsedFunction
    expression = 'vpc_12'
    symbol_names = 'vpc_12'
    symbol_values = 'vpc_12'
  []
  [fun_receive_hp_temp_13]
    type = ParsedFunction
    expression = 'vpc_13'
    symbol_names = 'vpc_13'
    symbol_values = 'vpc_13'
  []
  [fun_receive_hp_temp_14]
    type = ParsedFunction
    expression = 'vpc_14'
    symbol_names = 'vpc_14'
    symbol_values = 'vpc_14'
  []
  [fun_receive_hp_temp_15]
    type = ParsedFunction
    expression = 'vpc_15'
    symbol_names = 'vpc_15'
    symbol_values = 'vpc_15'
  []
  [fun_receive_hp_temp_16]
    type = ParsedFunction
    expression = 'vpc_16'
    symbol_names = 'vpc_16'
    symbol_values = 'vpc_16'
  []
  [fun_receive_hp_temp_17]
    type = ParsedFunction
    expression = 'vpc_17'
    symbol_names = 'vpc_17'
    symbol_values = 'vpc_17'
  []
  [fun_receive_hp_temp_18]
    type = ParsedFunction
    expression = 'vpc_18'
    symbol_names = 'vpc_18'
    symbol_values = 'vpc_18'
  []
  [fun_receive_hp_temp_19]
    type = ParsedFunction
    expression = 'vpc_19'
    symbol_names = 'vpc_19'
    symbol_values = 'vpc_19'
  []
[]

[Variables]
  [temp]
    initial_condition = ${fparse 900.0}
  []
[]

[AuxVariables]
  [aux_heatsource]
    order = CONSTANT
    family = MONOMIAL
    block = 'heated_rod heated_tri'
  []
  [receive_hp_temp]
    order = FIRST
    family = LAGRANGE
    initial_condition = ${fparse 900}
  []
[]

[AuxKernels]
  [cal_heat_source]
    type = FunctionAux
    variable = aux_heatsource
    function = gonglvmidu_fenbu
    block = 'heated_rod heated_tri'
  []
  [cal_hp_bc_1]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_1
    boundary = hp_bc_1
  []
  [cal_hp_bc_2]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_2
    boundary = hp_bc_2
  []
  [cal_hp_bc_3]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_3
    boundary = hp_bc_3
  []
  [cal_hp_bc_4]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_4
    boundary = hp_bc_4
  []
  [cal_hp_bc_5]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_5
    boundary = hp_bc_5
  []
  [cal_hp_bc_6]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_6
    boundary = hp_bc_6
  []
  [cal_hp_bc_7]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_7
    boundary = hp_bc_7
  []
  [cal_hp_bc_8]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_8
    boundary = hp_bc_8
  []
  [cal_hp_bc_9]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_9
    boundary = hp_bc_9
  []
  [cal_hp_bc_10]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_10
    boundary = hp_bc_10
  []
  [cal_hp_bc_11]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_11
    boundary = hp_bc_11
  []
  [cal_hp_bc_12]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_12
    boundary = hp_bc_12
  []
  [cal_hp_bc_13]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_13
    boundary = hp_bc_13
  []
  [cal_hp_bc_14]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_14
    boundary = hp_bc_14
  []
  [cal_hp_bc_15]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_15
    boundary = hp_bc_15
  []
  [cal_hp_bc_16]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_16
    boundary = hp_bc_16
  []
  [cal_hp_bc_17]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_17
    boundary = hp_bc_17
  []
  [cal_hp_bc_18]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_18
    boundary = hp_bc_18
  []
  [cal_hp_bc_19]
    type = FunctionAux
    variable = receive_hp_temp
    function = fun_receive_hp_temp_19
    boundary = hp_bc_19
  []
[]

[Kernels]
  [heat_1]
    type = HeatConduction
    variable = temp    
  []
  [heat_2]
    type = CoupledForce
    variable = temp
    v = aux_heatsource
    block = 'heated_rod heated_tri'
  []
[]

[Materials]
  [daore_monolith]
    type = HeatConductionMaterial
#    block = 'monolith heated_clad heated_rod heated_tri hp_clad'
    block = 'monolith heated_clad heated_rod heated_tri'
    temp = temp
    thermal_conductivity_temperature_function = k_ss316
  []
  [daore_heated_gap]
    type = HeatConductionMaterial
    block = 'heated_gap'
    temp = temp
    thermal_conductivity = ${k_gap_heated}
  []
#  [daore_hp_gap]
#    type = HeatConductionMaterial
#    block = 'hp_gap'
#    temp = temp
#    thermal_conductivity = ${k_gap_hp}
#  []
#  [daore_wick]
#    type = HeatConductionMaterial
#    block = 'wick'
#    temp = temp
#    thermal_conductivity_temperature_function = k_na_wick_084    
#  []
  [daore_Mgo]
    type = HeatConductionMaterial
    block = 'MgO'
    temp = temp
    thermal_conductivity = ${k_MgO}
  []
#  [daore_vapor_zone]
#    type = HeatConductionMaterial
#    block = 'vapor vapor_tri'
#    temp = temp
#    thermal_conductivity = 1.0
#  []
[]

[BCs]
#  [duiliu_bianjie]
#    type = ConvectiveHeatFluxBC
#    T_infinity= ${fparse 567.0+273.15}
#    boundary = 'duiliu_huanre'
#    heat_transfer_coefficient = 254.0
#    variable = temp
#  []
#   [duiliu_bianjie]
#    type = DirichletBC
#    value = ${fparse (628+615)/2 + 273.15}
#    boundary = 'hp_bc_1 hp_bc_2 hp_bc_3 hp_bc_4 hp_bc_5
#                hp_bc_6 hp_bc_7 hp_bc_8 hp_bc_9 hp_bc_10
#                hp_bc_11 hp_bc_12 hp_bc_13 hp_bc_14 hp_bc_15
#                hp_bc_16 hp_bc_17 hp_bc_18 hp_bc_19'
#    variable = temp
#  []
# ${fparse total_power/heated_num * 1/(2*pi*h_monolith_hp*r_hole*assemble_length) + (628+615)/2 + 273.15}
  [duiliu_bianjie]
    type = CoupledConvectiveHeatFluxBC
    htc = ${h_monolith_hp}
    T_infinity = receive_hp_temp
    boundary = 'hp_bc_1 hp_bc_2 hp_bc_3 hp_bc_4 hp_bc_5
                hp_bc_6 hp_bc_7 hp_bc_8 hp_bc_9 hp_bc_10
                hp_bc_11 hp_bc_12 hp_bc_13 hp_bc_14 hp_bc_15
                hp_bc_16 hp_bc_17 hp_bc_18 hp_bc_19'
    variable = temp    
  []
[]

[Postprocessors]
  [eivp]
    type = ElementIntegralVariablePostprocessor
    variable = aux_heatsource
    block = 'heated_rod heated_tri'
    outputs = csv_output_heatflux
  []
  [chtsi_1]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_1
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_2]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_2
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_3]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_3
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_4]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_4
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_5]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_5
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_6]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_6
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_7]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_7
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_8]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_8
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_9]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_9
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_10]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_10
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_11]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_11
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_12]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_12
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_13]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_13
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_14]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_14
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_15]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_15
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_16]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_16
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_17]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_17
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_18]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_18
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [chtsi_19]
    type = ConvectiveHeatTransferSideIntegral
    T_solid = temp
    boundary = hp_bc_19
    T_fluid_var = receive_hp_temp
    htc = ${h_monolith_hp}
    outputs = csv_output_heatflux
  []
  [sum_heat_flux]
    type = SumPostprocessor
    values = 'chtsi_1 chtsi_2 chtsi_3 chtsi_4 chtsi_5
              chtsi_6 chtsi_7 chtsi_8 chtsi_9 chtsi_10
              chtsi_11 chtsi_12 chtsi_13 chtsi_14 chtsi_15
              chtsi_16 chtsi_17 chtsi_18 chtsi_19'
    outputs = csv_output_heatflux
  []
  [vpc_1]
    type = VectorPostprocessorComponent
    index = 0
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_2]
    type = VectorPostprocessorComponent
    index = 1
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_3]
    type = VectorPostprocessorComponent
    index = 2
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_4]
    type = VectorPostprocessorComponent
    index = 3
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_5]
    type = VectorPostprocessorComponent
    index = 4
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_6]
    type = VectorPostprocessorComponent
    index = 5
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_7]
    type = VectorPostprocessorComponent
    index = 6
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_8]
    type = VectorPostprocessorComponent
    index = 7
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_9]
    type = VectorPostprocessorComponent
    index = 8
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_10]
    type = VectorPostprocessorComponent
    index = 9
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_11]
    type = VectorPostprocessorComponent
    index = 10
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_12]
    type = VectorPostprocessorComponent
    index = 11
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_13]
    type = VectorPostprocessorComponent
    index = 12
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_14]
    type = VectorPostprocessorComponent
    index = 13
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_15]
    type = VectorPostprocessorComponent
    index = 14
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_16]
    type = VectorPostprocessorComponent
    index = 15
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_17]
    type = VectorPostprocessorComponent
    index = 16
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_18]
    type = VectorPostprocessorComponent
    index = 17
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [vpc_19]
    type = VectorPostprocessorComponent
    index = 18
    vector_name = vop_receive_hp_temp
    vectorpostprocessor = vop_receive_hp_temp
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []   
[]

[VectorPostprocessors]
  [vop_hp]
    type = VectorOfPostprocessors
    postprocessors = 'chtsi_1 chtsi_2 chtsi_3 chtsi_4 chtsi_5
                      chtsi_6 chtsi_7 chtsi_8 chtsi_9 chtsi_10
                      chtsi_11 chtsi_12 chtsi_13 chtsi_14 chtsi_15
                      chtsi_16 chtsi_17 chtsi_18 chtsi_19'
  []
  [vop_receive_hp_temp]
    type = ConstantVectorPostprocessor
    vector_names = vop_receive_hp_temp
    value = '900 900 900 900 900
             900 900 900 900 900
             900 900 900 900 900
             900 900 900 900'
    execute_on = 'INITIAL'
  []
[]

[Executioner]
  type = Steady
  nl_abs_tol = 1e-10
  accept_on_max_fixed_point_iteration = True
  fixed_point_max_its = 50
  fixed_point_min_its = 50
  relaxation_factor = 0.5
#  transformed_variables = receive_hp_temp  #  Segmentation fault (core dumped)
#   transformed_variables = temp  
  transformed_postprocessors = 'vpc_1 vpc_2 vpc_3 vpc_4 vpc_5
                      vpc_6 vpc_7 vpc_8 vpc_9 vpc_10
                      vpc_11 vpc_12 vpc_13 vpc_14 vpc_15
                      vpc_16 vpc_17 vpc_18 vpc_19'
[]

[Outputs]
  exodus = true
  [csv_output_heatflux]
    type = CSV
  []
[]

[MultiApps]
  [sub_hp]
    type = FullSolveMultiApp
    input_files = 'jizongrezu_forcouple.i'
    execute_on = timestep_end
    positions = '${x1} ${y1} ${z1}
                 ${x2} ${y2} ${z2}
                 ${x3} ${y3} ${z3}
                 ${x4} ${y4} ${z4}
                 ${x5} ${y5} ${z5}
                 ${x6} ${y6} ${z6}
                 ${x7} ${y7} ${z7}
                 ${x8} ${y8} ${z8}
                 ${x9} ${y9} ${z9}
                 ${x10} ${y10} ${z10}
                 ${x11} ${y11} ${z11}
                 ${x12} ${y12} ${z12}
                 ${x13} ${y13} ${z13}
                 ${x14} ${y14} ${z14}
                 ${x15} ${y15} ${z15}
                 ${x16} ${y16} ${z16}
                 ${x17} ${y17} ${z17}
                 ${x18} ${y18} ${z18}
                 ${x19} ${y19} ${z19}'
     output_in_position = true
  []
[]

[Transfers]
#inactive = 'to_hp_heatflux from_T_walle'
  [to_hp_heatflux]
    type = MultiAppVectorPostprocessorTransfer
    postprocessor = receive_hp_flux
    vector_name = vop_hp
    vector_postprocessor = vop_hp
    to_multi_app = sub_hp
  []
#  [from_T_walle]
#    type = MultiAppPostprocessorInterpolationTransfer
#    from_multi_app = sub_hp
#    postprocessor = get_T_walle
#    variable = receive_hp_temp
#    num_points = 1
#  []
  [from_T_walle]
    type = MultiAppVectorPostprocessorTransfer  
    postprocessor = get_T_walle
    vector_name = vop_receive_hp_temp
    vector_postprocessor = vop_receive_hp_temp
    from_multi_app = sub_hp
  []
[]
