include("createhdf5.jl")

parameters = include("parameters.jl")
time = parameters[:t_max]
nofrealizations = 10
nofensembles = 2
nameoffile = "test"

createhdf5(nameoffile, parameters, nofensembles)
initializefile!(nameoffile, parameters, nofensembles)
runallrealizations!(nameoffile, nofensembles, nofrealizations)
deltaxandmsd!(nameoffile,nofensembles,nofrealizations)

#See output at "../HDF5/nameoffile"