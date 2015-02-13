#include("../src/objects.jl")

module Init

VERSION < v"0.4-" && using Docile



using Objects

export create_board

@doc doc"""Creates a Disk enclosed in the cell with boundaries at Lx1, Lx2, Ly1, Ly2; and with a random velocity
with constant norm"""->


function create_disk(Lx1,Lx2,Ly1,Ly2,radius = 0.4, mass = 1, velocity = 1)
    x = randuniform(Lx1 + radius, Lx2 - radius)
    y = randuniform(Ly1 + radius, Ly2 - radius)
    theta = rand()*2*pi
    vx = cos(theta)*velocity
    vy = sin(theta)*velocity
    v = [vx, vy]
    d = Disk([x,y],v,radius, mass)
    d
end


# function create_disks(board, delta_x, delta_y, velocity = 1)
#     radius_max = min(delta_x,delta_y)/2.
#     radius = randuniform(radius_max*0.2,radius_max*0.8)[1]
#     mass = randuniform(0.5,1.0)[1]
#     for cell in board.cells
#         disk = create_disk(cell,radius, mass, velocity)
#         cell.disk = disk
#     end
# end


function create_initial_cell(size_x,size_y)
    Lx1 = 0
    Lx2 = size_x
    Ly1= 0
    Ly2 = size_y
    wall1 = VerticalWall(Lx1,[Ly1,Ly2])
    wall2 = HorizontalWall([Lx1,Lx2],Ly1)
    wall3 = HorizontalWall([Lx1,Lx2],Ly2)
    Ly1Hole = Ly1+(Ly2-Ly1)*rand()
    Ly2Hole = Ly1+(Ly2-Ly1)*rand()
    Ly1Hole, Ly2Hole = sort([Ly1Hole,Ly2Hole])
    sharedwall = VerticalHoleWall(Lx2,[Ly1,Ly1Hole,Ly2Hole,Ly2])
    disk =  create_disk(Lx1,Lx2,Ly1,Ly2)
    label = 1
    disk.numberofcell = label
    cell = Cell([wall1,wall2,wall3,sharedwall],disk,label)
    cell
end

function create_new_right_cell(cell,size_x,size_y)
    wall1 = cell.walls[end]
    Lx1 = cell.walls[end].x
    Lx2 = Lx1 + size_x
    Ly1 = 0
    Ly2 = size_y
    wall2 = HorizontalWall([Lx1,Lx2],Ly1)
    wall3 = HorizontalWall([Lx1,Lx2],Ly2)
    Ly1Hole = Ly1+(Ly2-Ly1)*rand()
    Ly2Hole = Ly1+(Ly2-Ly1)*rand()
    Ly1Hole, Ly2Hole = sort([Ly1Hole,Ly2Hole])
    sharedwall = VerticalHoleWall(Lx2,[Ly1,Ly1Hole,Ly2Hole,Ly2])
    disk =  create_disk(Lx1,Lx2,Ly1,Ly2)
    label = cell.label + 1
    disk.numberofcell = label
    cell = Cell([wall2,wall3,sharedwall],disk,label)
    cell
end

function create_last_right_cell(cell,size_x,size_y)
    wall1 = cell.walls[end]
    Lx1 = cell.walls[end].x
    Lx2 = Lx1 + size_x
    Ly1 = 0
    Ly2 = size_y
    wall2 = HorizontalWall([Lx1,Lx2],Ly1)
    wall3 = HorizontalWall([Lx1,Lx2],Ly2)
    Ly1Hole = Ly1+(Ly2-Ly1)*rand()
    Ly2Hole = Ly1+(Ly2-Ly1)*rand()
    Ly1Hole, Ly2Hole = sort([Ly1Hole,Ly2Hole])
    wall4 = VerticalWall(Lx2,[Ly1,Ly2])
    disk =  create_disk(Lx1,Lx2,Ly1,Ly2)
    disk.numberofcell = cell.label
    cell = Cell([wall2,wall3,wall4],disk,cell.label+1)
    cell
end

function create_board(numberofcells,size_x,size_y)
    cell = create_initial_cell(size_x,size_y)
    board = [cell]
    if numberofcells > 1
        for i in 2:numberofcells-1
            cell = create_new_right_cell(cell,size_x,size_y)
            push!(board,cell)
        end
            cell = create_last_right_cell(cell,size_x,size_y)
            push!(board,cell)
    end
    board = Board(board)
end

function get_coordinates_cell(cell)
    label = cell.label
    if label == 1
        Lx1 = 0
        Ly1 = 0
        Lx2 = cell.walls[4].x
        Ly2 = cell.walls[3].y
    else
        Lx1 = cell.walls[1].x[1]
        Ly1 = 0
        Lx2 = cell.walls[1].x[2]
        Ly2 = cell.walls[2].y
    end
    Lx1, Ly1, Lx2, Ly2
end


@doc doc"""Creates an random Array(Vector) of *dimension* dim with limits: liminf, limsup""" ->
function randuniform(a, b, c=1)
    a + rand(c)*(b - a)
end

function overlap(p::Particle, d::Disk)
    deltar = d.r - p.r
    r = norm(deltar)
    return r < d.radius
end

function create_particle(board, mass, velocity,delta_x,delta_y)
    cell = board.cells[1]
    disk = board.cells[1].disk
    Lx1 = 0
    Ly1 = 0
    Lx2 = Lx1 + delta_x
    Ly2 = Ly1 +delta_y
    x = randuniform(Lx1, Lx2)
    y = randuniform(Ly1, Ly2)
    theta = rand()*2*pi
    vx = cos(theta)*velocity
    vy = sin(theta)*velocity
    v = [vx, vy]
    p = Particle([x,y],v, mass, cell.label)
    while  overlap(p,disk)
        x = randuniform(Lx1, Lx2)[1]
        y = randuniform(Ly1, Ly2)[1]
        p = Particle([x,y],v, mass, cell.label)
    end
    p
end

# function create_particles(board, velocity = 1)
#     mass = randuniform(0.5,1.0)[1]
#     for cell in board.cells
#         create_particle(cell, velocity)
#     end
# end




end




