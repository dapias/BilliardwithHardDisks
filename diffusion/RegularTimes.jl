module RegularTimes

push!(LOAD_PATH,"../src/")
using HardDiskBilliardSimulation

export xtoregulartimes

function xtoregulartimes(simulation_results)
board, particle_xpositions, particle_xvelocities, time = simulation_results

    xposition = [particle_xpositions[1]]
    dtstep = 1/4.
    nofsteps = int(time[end] * 1/dtstep)
    for i in 1:nofsteps
        dt = dtstep*i
        comparetimes = [dt > t for t in time]
        k = findfirst(comparetimes,false) - 1
        push!(xposition, particle_xpositions[1+(k-1)] + particle_xvelocities[1+(k-1)]*(dt-time[k]))
    end

xposition, dtstep
end

# parameters = include("parameters.jl")
# sim = simulation(;parameters...)
# x, t = xtoregulartimes(sim)

end

