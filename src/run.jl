include("./simulation.jl")
include("./visualization.jl")

using Simulation
using Visual

#In this file the main functions of the project are called, i.e. *simulation* from main.jl and *visualizate* from visualization.jl.
#Additionally the parameters from input_parameters.jl are called.

include("./input_parameters.jl")

#srand(1234)
sim = simulation(t_i, t_max);
@time visualize(sim);
