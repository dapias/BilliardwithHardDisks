using Compat

@compat Dict(:t_initial => 0.,
             :t_max => 6000,
             :radiusdisk => 4.5,
             :massdisk => 1.0,
             :velocitydisk => 0.0,
             :Lx1 => 0.,                         #x position of the first cell
             :Ly1 => 0.,                         #y position of the first cell
             :windowsize => 0.2,
             :massparticle => 1.0,
             :size_x => 12.,                     #Size of the cell in x
             :size_y => 12.,                     #Size of the cell in y
             :velocityparticle => 1.0
             )
