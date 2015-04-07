using HDF5
using PyPlot


function getnumbersofcell(nameoffile, tfixed)
  file = h5open("HDF5/$nameoffile.hdf5","r")
  timegroup = file["$tfixed"]
  nofcell = read(timegroup, "#cell")
  close(file)
  nofcell
end

function getdisksenergy(nameoffile, tfixed)
  file = h5open("HDF5/$nameoffile.hdf5","r")
  timegroup = file["$tfixed"]
  meandisksenergy = read(timegroup, "<ΔE>")
  close(file)
  meandisksenergy
end

function plotmeanenergyperensemble(nameoffile, tfixed)
  fig = plt.figure()
  ax = fig[:add_subplot](111)
  ax[:set_xlabel]("t")
  ax[:set_ylabel](L"$\Delta x$")

  nofcell = getnumbersofcell(nameoffile, tfixed)
  meandisksenergy = getdisksenergy(nameoffile, tfixed)

  ax[:plot](nofcell,meandisksenergy,"*--", label = "time$tfixed")

  fig
end

function plotfile(nameoffile, time)
  fig = plt.figure()
  ax = fig[:add_subplot](111)
  ax[:set_xlabel]("t")
  ax[:set_ylabel](L"$\Delta x$")

  for t in time
    nofcell = getnumbersofcell(nameoffile, t)
    meandisksenergy = getdisksenergy(nameoffile, t)
    ax[:plot](nofcell,meandisksenergy,"*--", label = "time$t")
  end
  handles, labels = ax[:get_legend_handles_labels]()
  ax[:legend](handles, labels, loc =1)

end

