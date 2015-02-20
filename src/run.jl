include("./simulation.jl")
include("./visualization.jl")

using Simulation
using Visual

#In this file the main functions of the project are called, i.e. *simulation* from main.jl and *visualizate* from visualization.jl.

parameters = Dict(:t_initial => 0,
                  :t_max => 100,
                  :radiusdisk => 1.0,
                  :massdisk => 1.0,
                  :velocitydisk => 1.0,
                  :Lx1 => 1,
                  :Ly1 => 1,
                  :maxholesize => 0.5,
                  :cellforinitialparticle => 1,
                  :massparticle => 1.0,
                  :numberofcells => 5,
                  :size_x => 3.,
                  :size_y => 3.,
                  :velocityparticle => 1.0
                  )

radiustovisualizeparticle = 0.02

sim = simulation(;parameters...);
@time visualize(sim, radiustovisualizeparticle);

#visualize_localenergy(sim);
