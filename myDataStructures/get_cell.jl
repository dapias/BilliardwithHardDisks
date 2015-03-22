using HardDiskBilliardModel
using DataStructures



include("parameters.jl")

function get_cell(q::Deque, numberofcell::Int)
    @assert -1023 <= numberofcell <= 1023
    if numberofcell < 0
        q.head.data[end+numberofcell]
    else
        q.rear.data[numberofcell+1]
    end
end

board, particle = create_board_with_particle(Lx1, Ly1,size_x,size_y,radiusdisk,massdisk, velocitydisk,
                           massparticle, velocityparticle, windowsize);

board = board.cells



get_cell(board,0)