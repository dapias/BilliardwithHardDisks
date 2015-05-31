using Dates

include("makehdf5.jl")
include("extractdata.jl")

try
  mkdir("./HDF5/")
end

parameters, nofrealizations = include(ARGS[1])
t_max = parameters[:t_max]
today = today()

try
  mkdir("./HDF5/$today")
end

s = string(now())
hour = s[end-7:end]
filename = "$today/$hour""ensemble:""$nofrealizations""t_max:""$t_max"

##This parameters have to be given if the file is executed directly
#parameters = include("parameters.jl")
#nofrealizations = 10
#filename = "test3"

# println("If runhdf5.jl is executed directly; the parameters and the number of realizations must be passed.
# It can be done as:
# parameters = include(\"parameters.jl\")
# nofrealizations = number of realizations .
# filename = \"filename\" without .hdf5 ending
# And then include(\"runhdf5.jl\") \n")

createhdf5(filename, parameters, nofrealizations)
data(filename, parameters, nofrealizations)

try
  mkdir("./HDF5/images")
end

try
  mkdir("./HDF5/images/$today")
end


plottdata(filename)
plotehistogram(filename)


println("Look for the file at the \"HDF5\" folder with the name \"$filename\"")



#See output at "../HDF5/filename"
