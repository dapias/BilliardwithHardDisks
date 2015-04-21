include("makeplots.jl")
pygui(false) #if you want see the plots set it true

#This parameter have to be given if the file is executed directly.
#nameoffile = "test"

try
  mkdir("./images/")
end




try
  mkdir("./images/$nameoffile")
end

try
  a = plotdata(nameoffile)
  savefig("./images/$nameoffile/data.pdf")
  b = plothistogram(nameoffile, nofbars)
  savefig("./images/$nameoffile/histogram.pdf")
  c = fitwithlinearsquares(nameoffile)
  savefig("./images/$nameoffile/fit.pdf")

catch
  println("
If runplots.jl is executed directly the filename and the number of bars for the histogram should be provided, as:
ARGS = [\"filename\" (without .hdf5 ending), nofbars] .
Otherwise and error is thrown.
")
  nameoffile = string(ARGS[1])
  nofbars = int(ARGS[2])
  a = plotdata(nameoffile)
  savefig("./images/$nameoffile/data.pdf")
  b = plothistogram(nameoffile, nofbars)
  savefig("./images/$nameoffile/histogram.pdf")
end


