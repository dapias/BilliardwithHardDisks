include("./simulation.jl")
include("./visualization.jl")

using Simulation
using Visual

include("./input_parameters.jl")
#In this file the main functions of the project are called, i.e. *simulation* from main.jl and *visualizate* from visualization.jl.
#Additionally the parameters from input_parameters.jl are called.


sim = simulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                    maxholesize, cellforinitialparticle, numberofcells);
@time visualize(sim, radiustovisualizeparticle);

#visualize_localenergy(sim);
