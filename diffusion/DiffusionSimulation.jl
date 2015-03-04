module DiffusionSimulation
push!(LOAD_PATH,"../src/")

using HDF5
using HardDiskBilliardSimulation

export nofruns, timearray

parameters = include("parameters.jl")
datafile = h5open("diffusiondata.hdf5", "w")
nofmaxtimes = 2  ###Usar un mejor nombre
nofruns = 10
timearray = ones(nofmaxtimes)

for i in 1:nofmaxtimes
    parameters[:t_max] *= i
    time = Float64(parameters[:t_max])
    timearray[i] = time
    for i in 1:nofruns
        sim = simulation(;parameters...)
        datafile["/t_max$time/particle_x-$i"] = sim[2]
        datafile["/t_max$time/time-$i"] = sim[3]
        attrs(datafile["/t_max$time/particle_x-$i"])["Numberofrun"] = i
        attrs(datafile["/t_max$time/time-$i"])["Numberofrun"] = i
    end
    for (key,value) in parameters
        attrs(datafile["/t_max$time"])[string(key)] = value
    end
end



close(datafile)


end
