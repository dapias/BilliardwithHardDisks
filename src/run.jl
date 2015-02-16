include("./simulation.jl")
include("./visualization.jl")

using Simulation
using Visual

#In this file the main functions of the project are called, i.e. *simulation* from main.jl and *visualizate* from visualization.jl.
#Additionally the parameters from input_parameters.jl are called.


numberofcells = 5
size_x = 3.
size_y = 3.
particle_mass = 1.0
particle_velocity = 1.0
t_i = 0
t_max = 100

#srand(1234)
sim = simulation(numberofcells,size_x,size_y,particle_mass,particle_velocity, t_i, t_max);
@time visualize(sim, numberofcells, size_x, size_y );
