module DiffusionSimulation
push!(LOAD_PATH,"../src/")

using HDF5
using HardDiskBilliardSimulation
using RegularTimes

export time, lenofarray, nofruns

parameters = include("parameters.jl")
nofmaxtimes = 1  ###Usar un mejor nombre
nofruns = 100
time = parameters[:t_max]

datafile = h5open("diffusiont_max$time.hdf5", "w")
for (key,value) in parameters
    attrs(datafile)[string(key)] = value
end
close(datafile)


len = int(ones(nofruns))  ###Solo voy a considerar un tiempo máximo por eso está más simple


datafile = h5open("diffusiont_max$time.hdf5", "r+")
sim = simulation(;parameters...)
x, dt = xtoregulartimes(sim)
lenofarray = length(x)
datafile["/particle-1/x"] = x
attrs(datafile["/particle-1"])["Numberofrun"] = 1
attrs(datafile)["Δt"] = dt
close(datafile)


if nofruns > 1
    for i in 2:nofruns
        datafile = h5open("diffusiont_max$time.hdf5", "r+")
        sim = simulation(;parameters...)
        x, dt = xtoregulartimes(sim)
        datafile["/particle-$i/x"] = x
        attrs(datafile["/particle-$i"])["Numberofrun"] = i
        close(datafile)
    end
end









end
