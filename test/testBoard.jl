include("../src/objects.jl")
include("../src/createobjects.jl")


using FactCheck
using DataStructures

facts("Create Board test") do
    board = Init.create_board(10.,10.,1.,1.,1.,0.5,0.,0.)
    cell = pop!(board.cells)

    @fact cell.walls[1].x => 0.
    @fact cell.walls[2].y => 0.
    @fact cell.walls[3].y => 10.
    @fact cell.walls[4].x => 10.

end