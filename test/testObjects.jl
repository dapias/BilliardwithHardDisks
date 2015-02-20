include("../src/objects.jl")
include("../src/createobjects.jl")


using FactCheck
#push!(LOAD_PATH, "C:\\Users\\marisol\\Documentos\\GitHub\\Hard-Disk-Gas\\src")
#println(LOAD_PATH)

#using Objects
#using Init




facts("Create Cell test") do
    cell = Init.create_initial_cell(10.,10., 1.,1.,1.,0.5,0.,0.)
    @fact cell.walls[1].x => 0.
    @fact cell.walls[2].y => 0.
    @fact cell.walls[3].y => 10.
    @fact cell.walls[4].x => 10.
    @fact length(cell.walls[4].y) => 4
    @fact cell.numberofcell => 1
end

facts("Disk tests") do
  D = Objects.Disk([2.,3.],[4.,6.],6.,4)
    @fact D.r => [2.0,3.0]
    @fact D.v => [4.0,6.0]
    @fact D.radius => 6.0
    @fact D.mass => 4.0
    @fact D.numberofcell => 1
    @fact D.lastcollision => 0
end

facts("Create new cell test") do
    cell = Init.create_initial_cell(10.,10., 1.,1.,1.,0.5,0.,0.)
    cell = Init.create_new_right_cell(cell,10.,10., 1.,1.,1.,0.5)
    @fact cell.walls[1].x => 10.
    @fact cell.walls[2].y => 0.
    @fact cell.walls[3].y => 10.
    @fact cell.walls[4].x => 20.
    @fact length(cell.walls[4].y) => 4
    @fact cell.numberofcell => 2
end


facts("Create board test") do
    board = Init.create_board(3,10.,10., 1.,1.,1.,0.5,0.,0.)
    @fact length(board.cells) => 3
    @fact board.cells[1].numberofcell => 1
    @fact board.cells[end].numberofcell => 3
end

facts("Create disk test") do
    cell = Init.create_initial_cell(10.,10., 1.,1.,1.,0.5,0.,0.)
    disk = Init.create_disk(0.,10,0,10.,0.4,1.0,1.0)

    @fact disk.radius => 0.4
    @fact disk.mass => 1.0
    @fact disk.numberofcell => 1
end


facts("Create particle test") do
    board = Init.create_board(3,10.,10., 1.,1.,1.,0.5,0.,0.)
    particle = Init.create_particle(board,1.0, 1.0, 10.,10.,1,0.,0.)

    @fact particle.mass => 1.0
    @fact particle.numberofcell => 1
end








