using LinearLeastSquares
using HDF5
using PyPlot

file = h5open("diffusiont_max100.0.hdf5","r")
deltat = attrs(file)["Δt"]
Δt = read(deltat)
t = [0.0:Δt:100.0]

fig = plt.figure()
ax = fig[:add_subplot](111)
ax[:set_xlabel]("time")
ax[:set_ylabel](L"$<\sigma ^2>$")
rms = file["rms/"]
variance = read(rms,"rms")
close(file)


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


corr_text = ax[:text](0.02,0.88,"",transform=ax[:transAxes])
corr_text[:set_text]("\$R^2\$ = $Rsquare")
ax[:plot](t,variance,"." , label="experimental")
ax[:plot](t, slope*t + intercept, "r.-", label="fit")
handles, labels = ax[:get_legend_handles_labels]()
ax[:legend](handles, labels, loc =4)

println("slope = $slope")
println("intercept = $intercept")
fig[:savefig]("./images/Variance/t_max100.0-10000-runsajuste.pdf")

file = h5open("diffusiont_max100.0.hdf5","r+")
file["/images/fit"] = "./images/Variance/t_max100.0-10000-runsajuste.pdf"
attrs(file["/images/fit"])["slope"] = slope
attrs(file["/images/fit"])["intercept"] = intercept
attrs(file["/images/fit"])["Rsquare"] = Rsquare
close(file)


# fig = plt.figure()
# ax = fig[:add_subplot](111)
# ax[:set_xlabel]("time")
# ax[:set_ylabel](L"$log(<\sigma ^2>)$")

# ax[:plot](t,log(variance),"." )
# fig[:savefig]("./images/Variance/t_max100.0-10000-runssemilog.pdf")

# fig = plt.figure()
# ax = fig[:add_subplot](111)
# ax[:set_xlabel](L"log(time)")
# ax[:set_ylabel](L"$log(<\sigma ^2>)$")

# ax[:plot](log(t),log(variance),"." )
# fig[:savefig]("./images/Variance/t_max100.0-10000-runsloglog.pdf")