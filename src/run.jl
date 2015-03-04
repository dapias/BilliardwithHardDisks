##################
#In this file the main functions of the project are called,
#i.e. *simulation* or *animatedsimulation* from HardDiskBilliardSimulation.jl and *visualize* from
#Visual.jl.
###########################

#include("./HardDiskBilliardSimulation.jl")
#include("./Visual.jl")

push!(LOAD_PATH,"./")
using HardDiskBilliardSimulation
using Visual
using Compat  ## To handle versions less than 0.4
using DataStructures

visual = false
# To change a parameter, type: parameters[:nameofsymbol] = valueyouwanttoset
parameters = @compat Dict(:t_initial => 0,
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


if visual
    radiustovisualizeparticle = 0.02
    sim = animatedsimulation(;parameters...);
    @time visualize(sim, radiustovisualizeparticle);
    delta_e_max, = findmax(sim[end])
    delta_e_min, = findmin(sim[end])
    println("Delta_E_max, Delta_E_min = $(delta_e_max),$(delta_e_min)")
    time = sim[5]
    nofevents = length(time)
    println("# of events: $nofevents")
else
    parameters[:t_max] = 100
    @time sim = simulation(;parameters...);
    board = sim[1]
    left = back(board.cells).numberofcell
    right = front(board.cells).numberofcell
    println("Left-cell, Right-cell: $left,$right")
    numberofcells = right + abs(left) + 1
    println("# of cells: $numberofcells")
    time = sim[3]
    nofevents = length(time)
    println("# of events: $nofevents")
end



# if (ARGS)[1] != 0
#     if ARGS[1] == "true"
#         include("./Visual.jl")
#         using Visual
#         @time visualize(sim, radiustovisualizeparticle);
#     end
# end

#visualize_localenergy(sim);
#just for git
