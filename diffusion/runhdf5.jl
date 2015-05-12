include("makehdf5.jl")

parameters = include("parameters.jl")
time = parameters[:t_max]

##This parameters have to be given if the file is executed directly
# nofrealizations = 10
# nofensembles = 5
# filename = "test3"

createhdf5(filename, parameters, nofensembles, nofrealizations)
initializefile!(filename, parameters, nofensembles)
runallrealizations!(filename, nofensembles, nofrealizations)
deltaxandmsd!(filename,nofensembles,nofrealizations)

#See output at "../HDF5/filename"
