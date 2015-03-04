module DiffusionSimulation
push!(LOAD_PATH,"../src/")

using HDF5
using HardDiskBilliardSimulation

export nofruns, timearray

parameters = include("parameters.jl")
nofmaxtimes = 1  ###Usar un mejor nombre
nofruns = 100
timearray = ones(nofmaxtimes)


for i in 1:nofmaxtimes
    parameters[:t_max] *= i
    time = Float64(parameters[:t_max])
    timearray[i] = time
    datafile = h5open("diffusiondata$time.hdf5", "w")
    for (key,value) in parameters
        attrs(datafile)[string(key)] = value
    end
    close(datafile)
    for i in 1:nofruns
        datafile = h5open("diffusiondata$time.hdf5", "r+")
        sim = simulation(;parameters...)
        datafile["/particle_x-$i"] = sim[2]
        datafile["/time-$i"] = sim[3]
        attrs(datafile["/particle_x-$i"])["Numberofrun"] = i
        attrs(datafile["/time-$i"])["Numberofrun"] = i
        close(datafile)
    end

end








end
