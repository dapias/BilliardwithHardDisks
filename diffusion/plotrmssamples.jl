push!(LOAD_PATH,"./")
using PyPlot
using HDF5
#using DiffusionSamples

time = 100
nofsamples = 20
nofruns = 10000
#parameters = include("parameters.jl")

file = h5open("diffusiont_max$time.hdf5", "r")
deltat = attrs(file)["Δt"]
Δt = read(deltat)
t = [0.0:Δt:time]

fig = plt.figure()
ax = fig[:add_subplot](111)
ax[:set_xlabel]("time")
ax[:set_ylabel](L"$<\sigma ^2>$")

for i in 1:nofsamples
    rms = file["sample-$i/rms/"]
    variance = read(rms,"rms")
    ax[:plot](t,variance,".")
end
close(file)

fig[:savefig]("./images/Variance/t_max$time-samples$nofsamples-runs$nofruns.pdf")

file = h5open("diffusiont_max$time.hdf5","r+")
file["/images/"] = "./images/Variance/t_max$time-samples$nofsamples-runs$nofruns.pdf"
# attrs(file["/images/fit"])["slope"] = slope
# attrs(file["/images/fit"])["intercept"] = intercept
# attrs(file["/images/fit"])["Rsquare"] = Rsquare
close(file)



