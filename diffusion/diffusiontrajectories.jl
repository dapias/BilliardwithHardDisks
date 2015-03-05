push!(LOAD_PATH,"./")
using PyPlot
using HDF5
using DiffusionSimulation

#parameters = include("parameters.jl")
datafile = h5open("diffusiont_max$time.hdf5", "r")

deltat = attrs(datafile)["Δt"]
Δt = read(deltat)

t = [0.0:Δt:time]

fig = plt.figure()
ax = fig[:add_subplot](111)
ax[:set_xlabel]("time")
ax[:set_ylabel]("x")
firstdata = datafile["particle-1"]
x = read(firstdata,"x")
ax[:plot](t,x,".")
for run in 2:nofruns
    xdata = datafile["particle-$run"]
    x = read(xdata,"x")
    ax[:plot](t,x,".")
end

fig[:savefig]("./images/t_max$time-$nofruns\-runs.pdf")

close(datafile)
