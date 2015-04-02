include("./simulation.jl")
include("./visualization.jl")

using Simulation
using Visual
using Compat

#In this file the main functions of the project are called, i.e. *simulation* from main.jl and *visualizate* from visualization.jl.

parameters = @compat Dict(:t_initial => 0,
                  :t_max => 100,
                  :radiusdisk => 1.0,
                  :massdisk => 1.0,
                  :velocitydisk => 1.0,
                  :Lx1 => 1,                         #x position of the first cell
                  :Ly1 => 1,                         #y position of the first cell
                  :maxholesize => 0.5,
                  :cellforinitialparticle => 1,
                  :massparticle => 1.0,
                  :numberofcells => 3,
                  :size_x => 3.,                     #Size of the cell in x
                  :size_y => 3.,                     #Size of the cell in y
                  :velocityparticle => 1.0
                  )

radiustovisualizeparticle = 0.02

@time sim = simulation(;parameters...);
println("#ofevents =" length(sim[end]))
@time visualize(sim, radiustovisualizeparticle);

#visualize_localenergy(sim);
