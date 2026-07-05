pitch = 21.0e-3
r_hole = ${fparse 19.1e-3/2}
r_heated_clad_out = ${fparse 19.0e-3/2}
r_heated_clad_in = ${fparse 17.4e-3/2}
thick_MgO = ${fparse 1.55e-3}
r_heated = ${fparse r_heated_clad_in - thick_MgO}

r_hp = ${fparse 19.0e-3/2}
thick_hp_clad = ${fparse 1.0e-3}
thick_hp_wick = ${fparse 1.0e-3}
r_hp_clad_in = ${fparse r_hp - thick_hp_clad}
r_hp_wick_in = ${fparse r_hp_clad_in - thick_hp_wick}

assemble_size = ${fparse 178.0e-3}

assemble_length = ${fparse 1550.0e-3}
heated_rod_position = ${fparse 117.0e-3}
heated_rod_length = ${fparse 1200.0e-3}
hp_length = ${fparse 4000.0e-3}
hp_convection_length = ${fparse 2000.0e-3}
hp_adiabat_length = ${fparse hp_length-hp_convection_length-assemble_length}
h1 = ${fparse heated_rod_position}
h2 = ${fparse heated_rod_length} 
h3 = ${fparse assemble_length - heated_rod_length - heated_rod_position}
h4 = ${fparse hp_adiabat_length}
h5 = ${fparse hp_convection_length}

[Mesh]
final_generator =  'bdg_2'
#inactive = 'pattern_assm_for_delete'
  [hex_heated]
    type = PolygonConcentricCircleMeshGenerator
    # General parameters
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    # Ring regions parameters
    ring_radii     =  '            ${r_heated} ${r_heated_clad_in} ${r_heated_clad_out}              ${r_hole}'
    ring_intervals = '                      5                   2                   2                      2'
    ring_block_ids =   '1                   2                   3                   4                      5'
    ring_block_names = 'heated_tri heated_rod                 MgO         heated_clad             heated_gap'
    #preserve_volumes = on
    # Background region parameters
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []

  [hex_hp_1]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     901      1001'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_1  hp_gap_1'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_2]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     902      1002'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_2  hp_gap_2'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_3]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     903      1003'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_3  hp_gap_3'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_4]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     904      1004'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_4  hp_gap_4'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_5]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     905      1005'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_5  hp_gap_5'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_6]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     906      1006'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_6  hp_gap_6'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_7]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     907      1007'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_7  hp_gap_7'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_8]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     908      1008'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_8  hp_gap_8'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_9]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     909      1009'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_9  hp_gap_9'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_10]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     910      1010'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_10  hp_gap_10'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_11]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     911      1011'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_11  hp_gap_11'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_12]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     912      1012'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_12  hp_gap_12'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_13]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     913      1013'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_13  hp_gap_13'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_14]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     914      1014'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_14  hp_gap_14'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_15]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     915      1015'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_15  hp_gap_15'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_16]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     916      1016'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_16  hp_gap_16'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_17]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     917      1017'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_17  hp_gap_17'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_18]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     918      1018'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_18  hp_gap_18'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []
  [hex_hp_19]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 6
    num_sectors_per_side = '4 4 4 4 4 4'
    polygon_size = ${fparse pitch/2}
    ring_radii     =    '${r_hp_wick_in} ${r_hp_clad_in} ${r_hp} ${r_hole}'
    ring_intervals =   '              5               2       2         2'
    ring_block_ids =   '6             7               8     919      1019'
    ring_block_names = 'vapor_tri vapor            wick hp_clad_19  hp_gap_19'
    preserve_volumes = on
    background_intervals = 2
    background_block_ids = 100
    background_block_names = monolith
  []

  [pattern_assm]
    type = PatternedHexMeshGenerator
    inputs = 'hex_heated 
              hex_hp_1 hex_hp_2 hex_hp_3 hex_hp_4 hex_hp_5
              hex_hp_6 hex_hp_7 hex_hp_8 hex_hp_9 hex_hp_10
              hex_hp_11 hex_hp_12 hex_hp_13 hex_hp_14 hex_hp_15
              hex_hp_16 hex_hp_17 hex_hp_18 hex_hp_19'
    pattern =  '14 0 13 0 12;
               0 0 0 0 0 0;
              15 0 5 0 4 0 11;
             0 0 0 0 0 0 0 0;
            16 0 6 0 1 0 3 0 10;
             0 0 0 0 0 0 0 0;
              17 0 7 0 2 0 9;
               0 0 0 0 0 0;
                18 0 19 0 8' 
    hexagon_size = ${fparse assemble_size/2}
    background_intervals = 2
    background_block_id = 100
    background_block_name = monolith
#    duct_sizes = 
#    duct_block_ids = 100
#    duct_block_names = monolith
#    duct_intervals = 2
  []

#  [ssbsg]
#    type = SideSetsBetweenSubdomainsGenerator
#    input = pattern_assm
#    new_boundary = 'huanre'
#    paired_block = 'hp_gap'
#    primary_block = 'hp_clad'
#  []

#  [ssbsg_2]
#    type = SideSetsBetweenSubdomainsGenerator
#    input = ssbsg
#    new_boundary = 'jianhua_bianjie'
#    paired_block = 'hp_gap'
#    primary_block = 'monolith'
#  []  

#  [ssbsg_3]
#    type = SideSetsBetweenSubdomainsGenerator
#    input = ssbsg_2
#    new_boundary = 'huanre_2'
#    paired_block = 'hp_clad'
#    primary_block = 'hp_gap'
#  []
  
  [ssbsg_hp_1]
    type = SideSetsBetweenSubdomainsGenerator
    input = pattern_assm
    new_boundary = 'hp_bc_1'
    paired_block = 'hp_gap_1'
    primary_block = 'monolith'
  []
  [ssbsg_hp_2]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_1
    new_boundary = 'hp_bc_2'
    paired_block = 'hp_gap_2'
    primary_block = 'monolith'
  []
  [ssbsg_hp_3]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_2
    new_boundary = 'hp_bc_3'
    paired_block = 'hp_gap_3'
    primary_block = 'monolith'
  []
  [ssbsg_hp_4]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_3
    new_boundary = 'hp_bc_4'
    paired_block = 'hp_gap_4'
    primary_block = 'monolith'
  []
  [ssbsg_hp_5]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_4
    new_boundary = 'hp_bc_5'
    paired_block = 'hp_gap_5'
    primary_block = 'monolith'
  []
  [ssbsg_hp_6]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_5
    new_boundary = 'hp_bc_6'
    paired_block = 'hp_gap_6'
    primary_block = 'monolith'
  []
  [ssbsg_hp_7]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_6
    new_boundary = 'hp_bc_7'
    paired_block = 'hp_gap_7'
    primary_block = 'monolith'
  []
  [ssbsg_hp_8]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_7
    new_boundary = 'hp_bc_8'
    paired_block = 'hp_gap_8'
    primary_block = 'monolith'
  []
  [ssbsg_hp_9]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_8
    new_boundary = 'hp_bc_9'
    paired_block = 'hp_gap_9'
    primary_block = 'monolith'
  []
  [ssbsg_hp_10]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_9
    new_boundary = 'hp_bc_10'
    paired_block = 'hp_gap_10'
    primary_block = 'monolith'
  []
  [ssbsg_hp_11]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_10
    new_boundary = 'hp_bc_11'
    paired_block = 'hp_gap_11'
    primary_block = 'monolith'
  []
  [ssbsg_hp_12]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_11
    new_boundary = 'hp_bc_12'
    paired_block = 'hp_gap_12'
    primary_block = 'monolith'
  []
  [ssbsg_hp_13]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_12
    new_boundary = 'hp_bc_13'
    paired_block = 'hp_gap_13'
    primary_block = 'monolith'
  []
  [ssbsg_hp_14]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_13
    new_boundary = 'hp_bc_14'
    paired_block = 'hp_gap_14'
    primary_block = 'monolith'
  []
  [ssbsg_hp_15]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_14
    new_boundary = 'hp_bc_15'
    paired_block = 'hp_gap_15'
    primary_block = 'monolith'
  []
  [ssbsg_hp_16]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_15
    new_boundary = 'hp_bc_16'
    paired_block = 'hp_gap_16'
    primary_block = 'monolith'
  []
  [ssbsg_hp_17]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_16
    new_boundary = 'hp_bc_17'
    paired_block = 'hp_gap_17'
    primary_block = 'monolith'
  []
  [ssbsg_hp_18]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_17
    new_boundary = 'hp_bc_18'
    paired_block = 'hp_gap_18'
    primary_block = 'monolith'
  []
  [ssbsg_hp_19]
    type = SideSetsBetweenSubdomainsGenerator
    input = ssbsg_hp_18
    new_boundary = 'hp_bc_19'
    paired_block = 'hp_gap_19'
    primary_block = 'monolith'
  []
  
  [rbg]
    type = RenameBlockGenerator
    input = ssbsg_hp_19
    old_block = 'hp_clad_2 hp_clad_3 hp_clad_4 hp_clad_5 hp_clad_6
                 hp_clad_7 hp_clad_8 hp_clad_9 hp_clad_10 hp_clad_11
                 hp_clad_12 hp_clad_13 hp_clad_14 hp_clad_15 hp_clad_16
                 hp_clad_17 hp_clad_18 hp_clad_19 hp_gap_2 hp_gap_3 hp_gap_4 hp_gap_5 hp_gap_6 hp_gap_7 hp_gap_8 hp_gap_9 hp_gap_10 hp_gap_11 hp_gap_12 hp_gap_13 hp_gap_14 hp_gap_15 hp_gap_16 hp_gap_17 hp_gap_18 hp_gap_19'
    new_block = 'hp_clad_1 hp_clad_1 hp_clad_1 hp_clad_1 hp_clad_1
                 hp_clad_1 hp_clad_1 hp_clad_1 hp_clad_1 hp_clad_1
                 hp_clad_1 hp_clad_1 hp_clad_1 hp_clad_1 hp_clad_1
                 hp_clad_1 hp_clad_1 hp_clad_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1 hp_gap_1'
  []
  
  [rbg_2]
    type = RenameBlockGenerator
    input = rbg
    old_block = 'hp_clad_1 hp_gap_1'
    new_block = 'hp_clad   hp_gap  '
  []
  
  [rbg_3]
    type = RenameBlockGenerator
    input = rbg_2
    old_block = '901 1001'
    new_block = '9   10  '
  []

  [lashen]
    type = AdvancedExtruderGenerator
    input = rbg_3
    heights = '${fparse h1} ${fparse h2} ${fparse h3} ${fparse h4} ${fparse h5}'
    num_layers = '5 50 10 20 100'
    direction = '0 0 1'
    subdomain_swaps = '1 999
                       2 9999
                       3 9999
                       4 9999
                       5 9999
                       6 6
                       7 7
                       8 8
                       9 9
                       10 10
                       100 100
                       ;
                       ;
                       1 999
                       2 9999
                       3 9999
                       4 9999
                       5 9999
                       6 6
                       7 7
                       8 8
                       9 9
                       10 10
                       100 100
                       ;
                       1 999
                       2 9999
                       3 9999
                       4 9999
                       5 9999
                       6 6
                       7 7
                       8 8
                       9 9
                       10 9999
                       100 9999
                       ;
                       1 999
                       2 9999
                       3 9999
                       4 9999
                       5 9999
                       6 6
                       7 7
                       8 8
                       9 9
                       10 9999
                       100 9999                        
                       '
    
  []
  
  [bdg]
    type = BlockDeletionGenerator
    input = lashen
    block = '999 9999'
  []
  
  [bdg_2]
    type = BlockDeletionGenerator
    input = bdg
    block = 'vapor vapor_tri hp_clad wick hp_gap'
  []
[]
