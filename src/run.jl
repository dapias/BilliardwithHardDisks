##################
#In this file the main functions of the project are called,
#i.e. *simulation* from main.jl and *visualizate* from visualization.jl.
###########################

include("./Simulation.jl")
include("./Visual.jl")
using Simulation
using Visual
using Compat  ## To handle versions less than 0.4


# To change a parameter, type: parameters[:nameofsymbol] = valueyouwanttoset
parameters = @ compat Dict(:t_initial => 0,
                  :t_max => 50,
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
delta_e_max, = findmax(sim[end])
delta_e_min, = findmin(sim[end])

println("Delta_E_max y Delta_E_min = $(delta_e_max),$(delta_e_min)")

# if (ARGS)[1] != 0
#     if ARGS[1] == "true"
#         include("./Visual.jl")
#         using Visual
#         @time visualize(sim, radiustovisualizeparticle);
#     end
# end

#visualize_localenergy(sim);
