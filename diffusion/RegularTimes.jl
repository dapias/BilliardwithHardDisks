module RegularTimes

push!(LOAD_PATH,"../src/")
using HardDiskBilliardSimulation
using Docile

export xtoregulartimes

@doc """#xtoregulartimes(simulation_results)
From the simulation results calculate the position of the particle in a time fixed by dtstep
""" ->
function xtoregulartimes(simulation_results, dtstep = 1/4.)
board, particle_xpositions, particle_xvelocities, time = simulation_results
    xposition = [particle_xpositions[1]]
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

