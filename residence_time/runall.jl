nameoffile = "100,000realizaciones"  #It will throw an error if the nameoffile is already exists
nofrealizations = 100000
nofbars = 20 #For the histogram
parameters = include("parameters.jl")

include("runhdf5.jl")
include("runplots.jl")
