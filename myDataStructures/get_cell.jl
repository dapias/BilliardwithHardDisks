using HardDiskBilliardModel
using DataStructures



include("parameters.jl")

function get_cell(q::Deque, numberofcell::Int)
    @assert -1023 <= numberofcell <= 1023
    if numberofcell < 0
        q.head.data[end+numberofcell+1]
    else
        q.rear.data[numberofcell+1]
    end
end

board, particle = create_board_with_particle(Lx1, Ly1,size_x,size_y,radiusdisk,massdisk, velocitydisk,
                           massparticle, velocityparticle, windowsize);

board = board.cells
cell = get_cell(board,0)
for i in 1:10
    cell = HardDiskBilliardModel.create_new_left_cell(cell, particle)
    unshift!(board, cell)
end

cell = get_cell(board,0)
for i in 1:10
    cell = HardDiskBilliardModel.create_new_right_cell(cell, particle)
    push!(board,cell)
end



