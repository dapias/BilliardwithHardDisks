##################
#In this file the main functions of the project are called,
#i.e. *simulation* or *animatedsimulation* from HardDiskBilliardSimulation.jl and *visualize* from
#Visual.jl.
###########################


push!(LOAD_PATH,"./")
using HardDiskBilliardSimulation
using Visual
using Compat  ## To handle versions less than 0.4
using DataStructures

#srand(1234)

function run(t_final = 100)

    visual = true

    # To change a parameter, type: parameters[:nameofsymbol] = valueyouwanttoset
    parameters = @compat Dict(:t_initial => 0.,
                      :t_max => 100.,
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
                      :vnewdisk => 1.0
                      )

    if visual
        parameters[:t_max] = t_final
        radiustovisualizeparticle = 0.02
        sim = animatedsimulation(;parameters...);
        elapsed_time = @time @elapsed visualize(sim, radiustovisualizeparticle);
        delta_e_max, = findmax(sim[end-1])
        delta_e_min, = findmin(sim[end - 1])
        println("Delta_E_max, Delta_E_min = $(delta_e_max),$(delta_e_min)")
    #     time = sim[5]
    #     nofevents = length(time)
    #     println("# of events: $nofevents")
    else
        parameters[:t_max] = t_final
        elapsed_time = @time @elapsed sim = simulation(;parameters...);
        board = sim[1]
        left = back(board.cells).numberofcell
        right = front(board.cells).numberofcell
        println("Left-cell, Right-cell: $left,$right")
        time = sim[4]
        nofevents = length(time)
        println("# of events: $nofevents")
    end

    elapsed_time

end

try
    t_final = float(ARGS[1])
    elapsed_time = run(t_final)
    println("# Tomé $elapsed_time segundos")

catch
    elapsed_time = run()
    println("# Tomé $elapsed_time segundos")
end
