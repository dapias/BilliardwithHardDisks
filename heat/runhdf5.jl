include("makehdf5.jl")

parameters = include("parameters.jl")

##This parameters have to be given if the file is executed directly
#time = [10.,100.]
# nofrealizations = 10
# filename = "test3"

createhdf5(filename, parameters, nofrealizations)
for t in time
  groupforafixedtime(filename, parameters, nofrealizations, t)
end

#See output at "../HDF5/filename"
