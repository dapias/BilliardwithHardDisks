using PyPlot

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

