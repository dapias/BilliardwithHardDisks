include("makehdf5.jl")

try
  mkdir("./HDF5/")
end


##This parameters have to be given if the file is executed directly
#parameters = include("parameters.jl")
#nofrealizations = 10
#nameoffile = "test3"

println("If runhdf5.jl is executed directly; the parameters and the number of realizations must be passed.
It can be done as:
parameters = include(\"parameters.jl\")
nofrealizations = number of realizations .
And then include(\"runhdf5.jl\") \n")

try
  createhdf5(nameoffile, parameters, nofrealizations)
  residencedata(nameoffile, parameters, nofrealizations)
catch
  nameoffile = "$(nofrealizations)realizaciones"
  createhdf5(nameoffile, parameters, nofrealizations)
  residencedata(nameoffile, parameters, nofrealizations)
end

println("Look for the file at the \"HDF5\" folder with the name \"$(nofrealizations)realizaciones\"")



#See output at "../HDF5/nameoffile"
