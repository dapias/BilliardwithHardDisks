push!(LOAD_PATH,"../src/")

using HDF5
using HardDiskBilliardSimulation
using Docile



function createhdf5(filename, parameters, nofrealizations)
  h5open("./HDF5/$filename.hdf5", "w") do file
    attrs(file)["Nofrealizations"] = nofrealizations
    for (key,value) in parameters
      attrs(file)[string(key)] = value
    end
  end
end

@doc """#groupforafixedtime(filename, parameters, nofrealizations, tfixed)
Generate the data \#ofcell and \<E\>_{disk} for the passed parameters.  The average ensemble energy is calculated
for each disk of the board at time tfixed."""->
function groupforafixedtime(filename, parameters, nofrealizations, tfixed)
  file = h5open("./HDF5/$filename.hdf5", "r+")
  parameters[:t_max] = tfixed
  dictionary = heatsimulation(;parameters...)

  for i in 2:nofrealizations
    dict = heatsimulation(;parameters...);
    for disk in keys(dict)
      if !haskey(dictionary, disk)
        dictionary["$disk"] = dict[disk]
      else
        push!(dictionary[disk],dict[disk][1])
      end
    end
  end
  for disk in keys(dictionary)
    push!(dictionary[disk],mean(dictionary[disk]))
  end

  cellmeanenergy = Float64[]
  numberofcell = Int64[]
  for disk in keys(dictionary)
    push!(cellmeanenergy,dictionary[disk][end])
    push!(numberofcell,parseint(disk[5:end]))  #number associated to the disk string (-2 to "disk-2" for example)
  end
  index = sortperm(numberofcell)

  file["$tfixed/<ΔE>"] = cellmeanenergy[index]
  file["$tfixed/#cell"] = numberofcell[index]
  close(file)

end


