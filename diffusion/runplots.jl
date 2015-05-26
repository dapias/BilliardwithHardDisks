include("plotfunctions.jl")

pygui(false) #if you want see the plots set it true

#This parameter have to be given if the file is executed directly.
#filename = "test3"


mkdir("./images/$filename")

a = plotmsdperensemble(filename)
savefig("./images/$filename/meansquaredisplacementeperensemble")
b = plotdeltaxperensemble(filename)
savefig("./images/$filename/deltaxperensemble")
c = fitmsdwithlinearsquares(filename)
savefig("./images/$filename/fitmsdwithlinearsquares")
d = plotmsdmanyensembles(filename)
savefig("./images/$filename/msdmanyensembles")


# a[:savefig]("./images/$filename/meansquaredisplacementeperensemble")
# b[:savefig]("./images/$filename/deltaxperensemble")
# c[:savefig]("./images/$filename/fitmsdwithlinearsquares")
# d[:savefig]("./images/$filename/msdmanyensembles")
