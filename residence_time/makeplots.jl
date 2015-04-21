using PyPlot
using LinearLeastSquares
using HDF5

function getnofrealizations(nameoffile)
  file = h5open("HDF5/$nameoffile.hdf5","r")
  nofrealizations = read(attrs(file)["Nofrealizations"])
  close(file)
  nofrealizations
end


function getdata(nameoffile)
  file = h5open("HDF5/$nameoffile.hdf5","r")
  tdata = read(file["tdata/"])
  close(file)
  tdata
end


function plotdata(nameoffile)
  fig = plt.figure()
  ax = fig[:add_subplot](111)
  ax[:set_xlabel]("#oftest")  #Buscar un mejor nombre
  ax[:set_ylabel]("t_residence")

  nofrealizations = getnofrealizations(nameoffile)
  test = [1:1:nofrealizations]
  tdata = getdata(nameoffile)


  ax[:plot](test,tdata,".-")
  fig
end

function plothistogram(nameoffile, nofbars)
  fig = plt.figure()
  ax = fig[:add_subplot](111)
  ax[:set_ylabel]("Frequency")  #Buscar un mejor nombre
  ax[:set_xlabel]("t_residence")

  tdata = getdata(nameoffile)
  PyPlot.hist(tdata, bins = nofbars, normed = 1)

end


function plotnumberoftrajectories(nameoffile)
  fig = plt.figure()
  ax = fig[:add_subplot](111)
  ax[:set_ylabel]("Number of remaining trajectories")  #Buscar un mejor nombre
  ax[:set_xlabel]("time")

  tdata = getdata(nameoffile)
  max, = findmax(tdata)
  t = [0.:0.01:max/2.]
  N = Array(Float64, length(t))
  for i in 1:length(t)
    N[i] = length(find(tdata.>t[i]))  #Esta parte hace lento el código
  end

  ax[:plot](t, N)

  fig = plt.figure()
  ax = fig[:add_subplot](111)
  ax[:set_yscale]("log")
  ax[:set_ylabel]("Log(Number of remaining trajectories)")  #Buscar un mejor nombre
  ax[:set_xlabel]("Time")
  ax[:plot](t, N)

  fig = plt.figure()
  ax = fig[:add_subplot](111)
  ax[:set_xscale]("log")
  ax[:set_ylabel]("Log(Number of remaining trajectories)")  #Buscar un mejor nombre
  ax[:set_xlabel]("Log(time)")
  ax[:plot](t, N)

end

function fitwithlinearsquares(nameoffile)
  fig = plt.figure()
  ax = fig[:add_subplot](111)
  ax[:set_xlabel]("t")
  ax[:set_ylabel](L"$Log(Number of trajectories)$")

  tdata = getdata(nameoffile)
  max, = findmax(tdata)
  t = [0.:0.01:max/2.]
  N = Array(Float64, length(t))
  for i in 1:length(t)
    N[i] = length(find(tdata.>t[i]))
  end

  N = log(N)

  slope = Variable()
  intercept = Variable()
  line = intercept + t * slope
  residuals = line - N
  fit_error = sum_squares(residuals)
  optval = minimize!(fit_error)

  slope = evaluate(slope)
  intercept = evaluate(intercept)
  RSS = evaluate(fit_error)
  SYY = sum((N - mean(N)).^2)
  SS = SYY - RSS
  Rsquare = 1 - RSS/SYY


  corr_text = ax[:text](0.02,0.88,"",transform=ax[:transAxes])
  corr_text[:set_text]("\$R^2\$ = $Rsquare \n slope = $slope \n intercept = $intercept")
  ax[:plot](t,N,"." , label="experimental")
  ax[:plot](t, slope*t + intercept, "r.-", label="fit")
  handles, labels = ax[:get_legend_handles_labels]()
  ax[:legend](handles, labels, loc =4)

  fig
end

function fit(t,N)
  fig = plt.figure()
  ax = fig[:add_subplot](111)
  ax[:set_xlabel]("t")
  ax[:set_ylabel](L"$Log(Number of trajectories)$")

  slope = Variable()
  intercept = Variable()
  line = intercept + t * slope
  residuals = line - N
  fit_error = sum_squares(residuals)
  optval = minimize!(fit_error)

  slope = evaluate(slope)
  intercept = evaluate(intercept)
  RSS = evaluate(fit_error)
  SYY = sum((N - mean(N)).^2)
  SS = SYY - RSS
  Rsquare = 1 - RSS/SYY


  corr_text = ax[:text](0.02,0.88,"",transform=ax[:transAxes])
  corr_text[:set_text]("\$R^2\$ = $Rsquare \n slope = $slope \n intercept = $intercept")
  ax[:plot](t,N,"." , label="experimental")
  ax[:plot](t, slope*t + intercept, "r.-", label="fit")
  handles, labels = ax[:get_legend_handles_labels]()
  ax[:legend](handles, labels, loc =4)

  fig
end
