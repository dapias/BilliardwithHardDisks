#To run the file the first time it is needed to create the empty folders "HDF5" and "images" in this path.

nofrealizations = 1000
nameoffile = "$(nofrealizations)realizaciones"  #It will throw an error if the nameoffile is already exists

nofbars = 20 #For the histogram
parameters = include("parameters.jl")

include("runhdf5.jl")
include("runplots.jl")
