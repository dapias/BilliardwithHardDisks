using Compat

@compat Dict(:t_initial => 0.,
             :t_max => 100,
             :radiusdisk => 1.0,
             :massdisk => 1.0,
             :velocitydisk => 1.0,
             :Lx1 => 0.,                         #x position of the first cell
             :Ly1 => 0.,                         #y position of the first cell
             :windowsize => 0.5,
             :massparticle => 1.0,
             :size_x => 3.,                     #Size of the cell in x
             :size_y => 3.,                     #Size of the cell in y
             :velocityparticle => 1.0,
             :vnewdisk => 0.0
             )
