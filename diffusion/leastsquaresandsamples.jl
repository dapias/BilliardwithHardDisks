push!(LOAD_PATH,"./")
using PyPlot
using HDF5
using LinearLeastSquares
#using DiffusionSamples

time = 100
nofsamples = 20
nofruns = 10000
#parameters = include("parameters.jl")

file = h5open("HDF5/diffusiont_max$time.hdf5", "r")
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

#Escojo una muestra particular
rms = file["sample-5/rms/"]
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

doffreedom = time/Δt - 1
sigmasquare = RSS/doffreedom
SXX = sum((t - mean(t)).^2)

sepred(x) = (sigmasquare)^(1/2) .* (1+ 1/(time/Δt) + ((x .- mean(t)).^2)./SXX).^(1/2.)  #standarderrorofprediction
tstudent = 2.576

y = intercept + t*slope
cotasup = intercept + t*slope + tstudent*sepred(t)
cotainf = intercept + t*slope - tstudent*sepred(t)

ax[:plot](t,variance,".")
ax[:plot](t, y, "r.-")
ax[:plot](t, cotasup, "--")
ax[:plot](t, cotainf, "--")

path = "./images/Variance/comparaciont_max100.0-samples$nofsamples.pdf"
fig[:savefig](path)


# file = h5open("HDF5/diffusiont_max$time.hdf5","r+")
# file["images/"] = path
# # attrs(file["/images/"])["intercept"] = intercept
# # attrs(file["/images/"])["Rsquare"] = Rsquare
# close(file)



