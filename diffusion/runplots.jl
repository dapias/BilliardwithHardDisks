include("plotfunctions.jl")

pygui(false) #if you want see the plots set it true

#This parameter have to be given if the file is executed directly.
#nameoffile = "test3"


mkdir("./images/$nameoffile")

a = plotmsdperensemble(nameoffile)
savefig("./images/$nameoffile/meansquaredisplacementeperensemble")
b = plotdeltaxperensemble(nameoffile)
savefig("./images/$nameoffile/deltaxperensemble")
c = fitmsdwithlinearsquares(nameoffile)
savefig("./images/$nameoffile/fitmsdwithlinearsquares")
d = plotmsdmanyensembles(nameoffile)
savefig("./images/$nameoffile/msdmanyensembles")


# a[:savefig]("./images/$nameoffile/meansquaredisplacementeperensemble")
# b[:savefig]("./images/$nameoffile/deltaxperensemble")
# c[:savefig]("./images/$nameoffile/fitmsdwithlinearsquares")
# d[:savefig]("./images/$nameoffile/msdmanyensembles")
