include("makehdf5.jl")

parameters = include("parameters.jl")

##This parameters have to be given if the file is executed directly
#time = [10.,100.]
# nofrealizations = 10
# nameoffile = "test3"

createhdf5(nameoffile, parameters, nofrealizations)
for t in time
  groupforafixedtime(nameoffile, parameters, nofrealizations, t)
end

#See output at "../HDF5/nameoffile"
