include("plotfunctions.jl")

pygui(false) #if you want see the plots set it true

#This parameter have to be given if the file is executed directly.
#filename = "test3"

a = plotfile(filename, time)
mkdir("./images/$filename")
savefig("./images/$filename/energyversuscell.pdf")
