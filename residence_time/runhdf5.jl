include("makehdf5.jl")



##This parameters have to be given if the file is executed directly
#parameters = include("parameters.jl")
#nofrealizations = 10
#nameoffile = "test3"

createhdf5(nameoffile, parameters, nofrealizations)
residencedata(nameoffile, parameters, nofrealizations)

#See output at "../HDF5/nameoffile"
