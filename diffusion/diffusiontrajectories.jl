push!(LOAD_PATH,"./")
using PyPlot
using HDF5
import DiffusionSimulation.timearray, DiffusionSimulation.nofruns

dataset = h5open("diffusiondata.hdf5","r")

for t in timearray
    fig = plt.figure()
    ax = fig[:add_subplot](111)
    ax[:set_xlabel]("time")
    ax[:set_ylabel]("x")
    firstgroup = dataset["t_max$t"]
    A = read(firstgroup,"particle_x-1")
    B = read(firstgroup,"time-1")
    ax[:plot](B,A,".-")
    for run in 2:nofruns
        A = read(firstgroup,"particle_x-$run")
        B = read(firstgroup,"time-$run")
        ax[:plot](B,A,".-")
    end
    fig[:savefig]("./images/t_max$t.png")
end

close(dataset)
