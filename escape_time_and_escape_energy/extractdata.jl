using PyPlot
using HDF5

function getnofrealizations(filename)
  file = h5open("HDF5/$filename.hdf5","r")
  nofrealizations = read(attrs(file)["Nofrealizations"])
  close(file)
  nofrealizations
end


function gettdata(filename)
  file = h5open("HDF5/$filename.hdf5","r")
  tdata = read(file["tdata/"])
  close(file)
  tdata
end

function getedata(filename)
  file = h5open("HDF5/$filename.hdf5","r")
  tdata = read(file["edata/"])
  close(file)
  tdata
end




# function plotdata(filename)
#   fig = plt.figure()
#   ax = fig[:add_subplot](111)
#   ax[:set_xlabel]("#oftest")  #Buscar un mejor nombre
#   ax[:set_ylabel]("t_residence")

#   nofrealizations = getnofrealizations(filename)
#   test = [1:1:nofrealizations]
#   tdata = getdata(filename)


#   ax[:plot](test,tdata,".-")
#   fig
# end

# function plothistogram(filename, nofbars)
#   fig = plt.figure()
#   ax = fig[:add_subplot](111)
#   ax[:set_ylabel]("Frequency")  #Buscar un mejor nombre
#   ax[:set_xlabel]("t_residence")

#   tdata = getdata(filename)
#   PyPlot.hist(tdata, bins = nofbars, normed = 1)

# end




