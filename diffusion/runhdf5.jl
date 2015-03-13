include("makehdf5.jl")

parameters = include("parameters.jl")
time = parameters[:t_max]

##This parameters have to be given if the file is executed directly
# nofrealizations = 10
# nofensembles = 5
# nameoffile = "test3"

createhdf5(nameoffile, parameters, nofensembles, nofrealizations)
initializefile!(nameoffile, parameters, nofensembles)
runallrealizations!(nameoffile, nofensembles, nofrealizations)
deltaxandmsd!(nameoffile,nofensembles,nofrealizations)

#See output at "../HDF5/nameoffile"
