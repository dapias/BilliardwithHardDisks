using HDF5
using PyPlot


function getnumbersofcell(filename, tfixed)
  file = h5open("HDF5/$filename.hdf5","r")
  timegroup = file["$tfixed"]
  nofcell = read(timegroup, "#cell")
  close(file)
  nofcell
end

function getdisksenergy(filename, tfixed)
  file = h5open("HDF5/$filename.hdf5","r")
  timegroup = file["$tfixed"]
  meandisksenergy = read(timegroup, "<ΔE>")
  close(file)
  meandisksenergy
end

function plotmeanenergyperensemble(filename, tfixed)
  fig = plt.figure()
  ax = fig[:add_subplot](111)
  ax[:set_xlabel]("#ofcell")
  ax[:set_ylabel](L"$<E>$")

  nofcell = getnumbersofcell(filename, tfixed)
  meandisksenergy = getdisksenergy(filename, tfixed)

  ax[:plot](nofcell,meandisksenergy,"*--", label = "time$tfixed")

  fig
end

function plotfile(filename, time)
  fig = plt.figure()
  ax = fig[:add_subplot](111)
  ax[:set_xlabel]("#ofcell")
  ax[:set_ylabel](L"$<E>$")

  for t in time
    nofcell = getnumbersofcell(filename, t)
    meandisksenergy = getdisksenergy(filename, t)
    ax[:plot](nofcell,meandisksenergy,"*--", label = "time$t")
  end
  handles, labels = ax[:get_legend_handles_labels]()
  ax[:legend](handles, labels, loc =1)

end

