push!(LOAD_PATH,"./")
push!(LOAD_PATH,"../src/")
using HDF5
using DiffusionSimulation

parameters = include("parameters.jl")
# time = parameters[:t_max]
# t = linspace(0.0, tmin, nofsamples)

# datafile = h5open("diffusiont_max$time.hdf5", "r+")
# firstgroup = datafile["/particle-1"]
# x = read(firstgroup,"x")
# for k in 1:length(x)

#     for run in 2:nofruns
#         A = read(firstgroup,"particle_x-$run")
#         B = read(firstgroup,"time-$run")
#         ax[:plot](B,A,".-")
#     end
#     fig[:savefig]("./images/t_max$t.png")
#     close(dataset)



using HardDiskBilliardSimulation




function xtoregulartimes(simulation_results)
board, particle_xpositions, particle_xvelocities, time = simulation_results

    xposition = [particle_xpositions[1]]
    t = [0.0]
    nofsteps = int(time[end] * 10)
    for i in 1:nofsteps
        dt = i/10
        comparetimes = [dt > t for t in time]
        k = findfirst(comparetimes,false) - 1
        if k != 0
            push!(xposition, particle_xpositions[1+(k-1)] + particle_xvelocities[1+(k-1)]*(dt-time[k]))
            push!(t, dt)
        end
    end

xposition, t
end

sim = simulation(;parameters...)
x, t = xtoregulartimes(sim)



