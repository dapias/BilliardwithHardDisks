using LinearLeastSquares
using HDF5
using PyPlot

function gettime(filename)
    file = h5open("HDF5/$filename.hdf5","r")
    deltat = attrs(file)["Δt"]
    tmax = attrs(file)["t_max"]
    tmax = read(tmax)
    Δt = read(deltat)
    t = [0.0:Δt:tmax]
    close(file)
    t
end

function getmsdperensemble(filename, nofensemble = 1)
    file = h5open("HDF5/$filename.hdf5","r")
    msd = file["ensemble-$nofensemble/meansquaredisplacement/"]
    msd = read(msd,"<(Δx)^2>")
    close(file)
    msd
end

function getnofensembles(filename)
    file = h5open("HDF5/$filename.hdf5","r")
    nofensembles = attrs(file)["Nofensembles"]
    nofensembles = read(nofensembles)
    close(file)
    nofensembles
end

function plotmsdperensemble(filename, nofensemble = 1)
    fig = plt.figure()
    ax = fig[:add_subplot](111)
    ax[:set_xlabel]("t")
    ax[:set_ylabel](L"$\langle(\Delta x)^2\rangle_t$")

    t = gettime(filename)
    msd = getmsdperensemble(filename, nofensemble)


    ax[:plot](t,msd,".")
    fig
end

function plotdeltaxperensemble(filename, nofensemble = 1, nofparticles = 100)
    fig = plt.figure()
    ax = fig[:add_subplot](111)
    ax[:set_xlabel]("t")
    ax[:set_ylabel](L"$\Delta x$")

    t = gettime(filename)

    file = h5open("HDF5/$filename.hdf5","r")
    nofrealizations = attrs(file)["Nofrealizations"]
    nofrealizations = read(nofrealizations)

    firstrealization = file["ensemble-$nofensemble/particle-1"]
    Δx = read(firstrealization,"Δx")
    ax[:plot](t,Δx,".")

    if nofrealizations > 1 && nofrealizations > nofparticles
        for realization in 2:nofparticles
            xdata = file["ensemble-$nofensemble/particle-$realization"]
            Δx = read(xdata,"Δx")
            ax[:plot](t,Δx,".")
        end

    elseif nofrealizations > 1 && nofrealizations < nofparticles
        for realization in 2:nofrealizations
            xdata = file["ensemble-$nofensemble/particle-$realization"]
            Δx = read(xdata,"Δx")
            ax[:plot](t,Δx,".")
        end
    end
    fig
end



function fitmsdwithlinearsquares(filename, nofensemble=1)
    fig = plt.figure()
    ax = fig[:add_subplot](111)
    ax[:set_xlabel]("t")
    ax[:set_ylabel](L"$\langle(\Delta x)^2\rangle_t$")

    t = gettime(filename)
    msd = getmsdperensemble(filename, nofensemble)

    slope = Variable()
    intercept = Variable()
    line = intercept + t * slope
    residuals = line - msd
    fit_error = sum_squares(residuals)
    optval = minimize!(fit_error)

    slope = evaluate(slope)
    intercept = evaluate(intercept)
    RSS = evaluate(fit_error)
    SYY = sum((msd - mean(msd)).^2)
    SS = SYY - RSS
    Rsquare = 1 - RSS/SYY


    corr_text = ax[:text](0.02,0.88,"",transform=ax[:transAxes])
    corr_text[:set_text]("\$R^2\$ = $Rsquare \n slope = $slope \n intercept = $intercept")
    ax[:plot](t,msd,"." , label="experimental")
    ax[:plot](t, slope*t + intercept, "r.-", label="fit")
    handles, labels = ax[:get_legend_handles_labels]()
    ax[:legend](handles, labels, loc =4)

    fig
end

@doc "Fit any pair of data (t,msd) with the linear  squares method"->
function fitmsdwithlinearsquares(t, msd)

#   fig = plt.figure()
#   ax = fig[:add_subplot](111)
#   ax[:set_xlabel]("t")
#   ax[:set_ylabel](L"$\langle(\Delta x)^2\rangle_t$")

  slope = Variable()
  intercept = Variable()
  line = intercept + t * slope
  residuals = line - msd
  fit_error = sum_squares(residuals)
  optval = minimize!(fit_error)

  slope = evaluate(slope)
  intercept = evaluate(intercept)
  RSS = evaluate(fit_error)
  SYY = sum((msd - mean(msd)).^2)
  SS = SYY - RSS
  Rsquare = 1 - RSS/SYY


#   corr_text = ax[:text](0.02,0.88,"",transform=ax[:transAxes])
#   corr_text[:set_text]("\$R^2\$ = $Rsquare \n slope = $slope \n intercept = $intercept")
#   ax[:plot](t,msd,"." , label="experimental")
#   ax[:plot](t, slope*t + intercept, "r.-", label="fit")
#   handles, labels = ax[:get_legend_handles_labels]()
#   ax[:legend](handles, labels, loc =4)
#   fig
  Rsquare, slope, intercept

end

function plotmsdmanyensembles(filename)
    fig = plt.figure()
    ax = fig[:add_subplot](111)
    ax[:set_xlabel]("t")
    ax[:set_ylabel](L"$\langle(\Delta x)^2\rangle_t$")

    nofensembles = getnofensembles(filename)

    for ensemble in 1:nofensembles
        t = gettime(filename)
        msd = getmsdperensemble(filename, ensemble)
        ax[:plot](t,msd,".")
    end
    fig
end




#     fig = plt.figure()
#     ax = fig[:add_subplot](111)
#     ax[:set_xlabel]("t")
#     ax[:set_ylabel](L"$log(\langle\sigma ^2\rangle_t)$")

#     ax[:plot](t,log(variance),"." )
#     fig[:savefig]("./images/Variance/t_max100.0-10000-runssemilog.pdf")

#     fig = plt.figure()
#     ax = fig[:add_subplot](111)
#     ax[:set_xlabel](L"log(time)")
#     ax[:set_ylabel](L"$log(\langle\sigma ^2\rangle_t)$")

#     ax[:plot](log(t),log(variance),"." )
#     fig[:savefig]("./images/Variance/t_max100.0-10000-runsloglog.pdf")

#     fig = plt.figure()
#     ax = fig[:add_subplot](111)
#     ax[:set_xlabel](L"time \cdot log(time)")
#     ax[:set_ylabel](L"$\langle\sigma ^2\rangle_t$")

#     ax[:plot](t .* log(t),variance,"." )
#     fig[:savefig]("./images/Variance/t_max100.0-10000-runslinearithmic.pdf")


#     fig = plt.figure()
#     ax = fig[:add_subplot](111)
#     ax[:set_xlabel](L"time")
#     ax[:set_ylabel](L"$\frac{\langle\sigma ^2\rangle_t}{t}$")

#     ax[:plot](t,variance ./ t,"." )
#     fig[:savefig]("./images/Variance/t_max100.0-10000-runsvarianceovert.pdf")
