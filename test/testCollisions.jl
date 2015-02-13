include("../src/objects.jl")
include("../src/createobjects.jl")
include("../src/timesandrules.jl")

using FactCheck
#push!(LOAD_PATH, "C:\\Users\\marisol\\Documentos\\GitHub\\Hard-Disk-Gas\\src")
#println(LOAD_PATH)

#using Objects
#using Init




facts("Collision Disk-Particle") do
    disk = Objects.Disk([0.,0.],[0.,0.],1.0)
    particle = Objects.Particle([2.0,0.],[-1.0,0.])

    @fact Rules.dtcollision(particle,disk) => 1.0
end