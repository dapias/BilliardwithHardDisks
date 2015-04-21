#To run the file the first time it is needed to create the empty folders "HDF5" and "images" in this path.

nofrealizations = 10000000
#nameoffile = "$(nofrealizations)realizaciones"  #It will throw an error if the nameoffile is already exists
nameoffile = "10millonesdoblev"
nofbars = 1000 #For the histogram
parameters = include("parameters.jl")

include("runhdf5.jl")
include("runplots.jl")
