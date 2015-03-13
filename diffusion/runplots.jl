include("plotfunctions.jl")

pygui(false) #if you want see the plots set it true

nameoffile = "test3"
a = plotmsdperensemble(nameoffile)
b = plotdeltaxperensemble(nameoffile)
c = fitmsdwithlinearsquares(nameoffile)
d = plotmsdmanyensembles(nameoffile)


mkdir("./images/$nameoffile")
a[:savefig]("./images/$nameoffile/meansquaredisplacementeperensemble")
b[:savefig]("./images/$nameoffile/deltaxperensemble")
c[:savefig]("./images/$nameoffile/fitmsdwithlinearsquares")
d[:savefig]("./images/$nameoffile/msdmanyensembles")
