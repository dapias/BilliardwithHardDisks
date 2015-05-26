include("plotfunctions.jl")

pygui(false) #if you want see the plots set it true

#This parameter have to be given if the file is executed directly.
#filename = "test3"
#time = [10.,100.,1000.]

a = plotfile(filename, time)
mkdir("./images/$filename")
savefig("./images/$filename/energyversuscell.pdf")
