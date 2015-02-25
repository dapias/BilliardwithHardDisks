include("./Simulation.jl")
include("./Visual.jl")

using Simulation
using Visual

#In this file the main functions of the project are called, i.e. *simulation* from main.jl and *visualizate* from visualization.jl.

parameters = Dict(:t_initial => 0,
                  :t_max => 100,
                  :radiusdisk => 1.0,
                  :massdisk => 1.0,
                  :velocitydisk => 1.0,
                  :Lx1 => 0,                         #x position of the first cell
                  :Ly1 => 0,                         #y position of the first cell
                  :windowsize => 0.5,
                  :massparticle => 1.0,
                  :size_x => 3.,                     #Size of the cell in x
                  :size_y => 3.,                     #Size of the cell in y
                  :velocityparticle => 1.0
                  )

radiustovisualizeparticle = 0.02

sim = simulation(;parameters...);
@time visualize(sim, radiustovisualizeparticle);

#visualize_localenergy(sim);
