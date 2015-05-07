##################
#In this file the main functions of the project are called,
#i.e. *simulation* or *animatedsimulation* from HardDiskBilliardSimulation.jl and *visualize* from
#Visual.jl.
###########################


push!(LOAD_PATH,"./")
using HardDiskBilliardSimulation
using ClosedTrajectory
using Compat  ## To handle versions less than 0.4
using DataStructures

#srand(1234)

function run(t_final = 100)

  # To change a parameter, type: parameters[:nameofsymbol] = valueyouwanttoset
  parameters = @compat Dict(:t_initial => 0.,
                            :t_max => 100.,
                            :radiusdisk => 1.0,
                            :massdisk => 1.0,
                            :velocitydisk => 1.0,
                            :Lx1 => 0.,                         #x position of the first cell
                            :Ly1 => 0.,                         #y position of the first cell
                            :windowsize => 0.0,
                            :massparticle => 1.0,
                            :size_x => 3.,                     #Size of the cell in x
                            :size_y => 3.,                     #Size of the cell in y
                            :velocityparticle => 1.0
                            )


  parameters[:t_max] = t_final
  radiustovisualizeparticle = 0.02
  sim = animatedsimulation(;parameters...);
  trajectory(sim, radiustovisualizeparticle);

end

try
  t_final = float(ARGS[1])
  run(t_final)
catch
  run()
end
