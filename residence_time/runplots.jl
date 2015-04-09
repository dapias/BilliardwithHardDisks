include("makeplots.jl")
pygui(false) #if you want see the plots set it true

#This parameter have to be given if the file is executed directly.
#nameoffile = "test"

mkdir("./images/$nameoffile")

a = plotdata(nameoffile)
savefig("./images/$nameoffile/data.pdf")
b = plothistogram(nameoffile, nofbars)
savefig("./images/$nameoffile/histogram.pdf")
