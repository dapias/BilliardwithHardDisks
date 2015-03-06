push!(LOAD_PATH,"./")
using PyPlot
using HDF5
using LinearLeastSquares
#using DiffusionSimulation

time = 1000
nofruns = 10000

#parameters = include("parameters.jl")
datafile = h5open("diffusiont_max$time.hdf5", "r")

deltat = attrs(datafile)["Δt"]
Δt = read(deltat)

t = [0.0:Δt:time]

fig = plt.figure()
ax = fig[:add_subplot](111)
ax[:set_xlabel]("time")
ax[:set_ylabel](L"$<\sigma ^2>$")
rms = datafile["rms"]
variance = read(rms,"rms")
#ax[:plot](t,variance,".")

slope = Variable()
intercept = Variable()
line = intercept + t * slope
residuals = line - variance
fit_error = sum_squares(residuals)
optval = minimize!(fit_error)

slope = evaluate(slope)
intercept = evaluate(intercept)

RSS = evaluate(fit_error)

SYY = sum((variance - mean(variance)).^2)
SS = SYY - RSS
Rsquare = 1 - RSS/SYY
println("slope = $slope")
println("intercept = $intercept")

corr_text = ax[:text](0.02,0.88,"",transform=ax[:transAxes])
corr_text[:set_text]("\$R^2\$ = $Rsquare")


ax[:plot](t,variance,"." , label="experimental")
ax[:plot](t, slope*t + intercept, "r.-", label="fit")
handles, labels = ax[:get_legend_handles_labels]()
ax[:legend](handles, labels, loc =4)



fig[:savefig]("./images/Variance/t_max$time-runs$nofruns.pdf")

close(datafile)
