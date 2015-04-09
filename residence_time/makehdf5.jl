include("residence.jl")


using HDF5
using HardDiskBilliardSimulation
using Docile


function createhdf5(nameoffile, parameters, nofrealizations)
  h5open("./HDF5/$nameoffile.hdf5", "w") do file
    attrs(file)["Nofrealizations"] = nofrealizations
    for (key,value) in parameters
      attrs(file)[string(key)] = value
    end
  end
end

function residencedata(nameoffile, parameters, nofrealizations)
  file = h5open("./HDF5/$nameoffile.hdf5", "r+")

  tdata = Array(Float64, nofrealizations)


  for i in 1:nofrealizations
      tdata[i] = residencetime(;parameters...)
  end

  file["tdata"] = tdata

  close(file)

end
