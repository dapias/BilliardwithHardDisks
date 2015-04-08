include("plotfunctions.jl")

pygui(false) #if you want see the plots set it true

#This parameter have to be given if the file is executed directly.
#nameoffile = "test3"

a = plotfile(nameoffile, time)
mkdir("./images/$nameoffile")
savefig("./images/$nameoffile/energyversuscell.pdf")
