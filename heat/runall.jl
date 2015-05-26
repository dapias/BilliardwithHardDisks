filename = "prueba"  #It will throw an error if the filename is already exists
nofrealizations = 10
time = [10.,100.]   #Time for which the profile of energies is displayed

include("runhdf5.jl")
include("runplots.jl")
