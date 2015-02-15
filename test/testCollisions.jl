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


facts("Collision Particle-VerticalWall") do
    p1 = Objects.Particle([2.0,1.],[-1.0,0.])
    vw1 = Objects.VerticalWall(0.0,[0.,3.])
    p2 = Objects.Particle([2.0,1.],[1.0,0.])
    vw2 = Objects.VerticalWall(3.0,[0.,3.])


    @fact Rules.dtcollision(p1,vw1) => 2.0
    @fact Rules.dtcollision(p2,vw2) => 1.0
end

facts("Collision Particle-VerticalSharedWall") do
    p1 = Objects.Particle([2.0,1.],[-1.0,0.])
    vw1 = Objects.VerticalSharedWall(0.0,[0.,1.,2.,3.],(1,2))
    p2 = Objects.Particle([2.0,1.],[1.0,0.])
    vw2 = Objects.VerticalSharedWall(3.0,[0.,1.,2.,3.],(1,2))


    @fact Rules.dtcollision(p1,vw1) => 2.0
    @fact Rules.dtcollision(p2,vw2) => 1.0
end

facts("Collision Particle-HorizontalWall") do
    p1 = Objects.Particle([2.0,1.],[0,-1.])
    vw1 = Objects.HorizontalWall([0.0,3.],0)
    p2 = Objects.Particle([2.0,1.],[0.0,1.])
    vw2 = Objects.HorizontalWall([0.,3.],3.)


    @fact Rules.dtcollision(p1,vw1) => 1.0
    @fact Rules.dtcollision(p2,vw2) => 2.0
end
