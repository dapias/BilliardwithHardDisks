module Init

VERSION < v"0.4-" && using Docile

using Objects

export create_board, create_particle

include("./input_parameters.jl")

@doc doc"""Creates a Disk enclosed in the cell with boundaries at Lx1, Lx2, Ly1, Ly2; and with a random velocity
with constant norm"""->
function create_disk(Lx1,Lx2,Ly1,Ly2,radius, mass, velocity)
    x = randuniform(Lx1 + radius, Lx2 - radius)
    y = randuniform(Ly1 + radius, Ly2 - radius)
    theta = rand()*2*pi
    vx = cos(theta)*velocity
    vy = sin(theta)*velocity
    v = [vx, vy]
    d = Disk([x,y],v,radius, mass)
    d
end

function create_initial_cell(size_x,size_y)
    Lx2 = size_x
    Ly2 = size_y
    wall1 = VerticalWall(Lx1,[Ly1,Ly2])
    wall2 = HorizontalWall([Lx1,Lx2],Ly1)
    wall3 = HorizontalWall([Lx1,Lx2],Ly2)
    Ly1Hole = Ly1+(Ly2-Ly1-maxholesize)*rand()
    Ly2Hole = Ly1Hole + maxholesize
    nofcell = 1
    sharedwall = VerticalSharedWall(Lx2,[Ly1,Ly1Hole,Ly2Hole,Ly2],(nofcell,nofcell+1))
    disk =  create_disk(Lx1,Lx2,Ly1,Ly2, radiusdisk, massdisk, velocitydisk)
    disk.numberofcell = nofcell
    cell = Cell([wall1,wall2,wall3,sharedwall],disk,nofcell)
    cell
end

function create_new_right_cell(cell,size_x,size_y)
    wall1 = cell.walls[end]
    Lx1 = cell.walls[end].x
    Lx2 = Lx1 + size_x
    Ly2 = size_y
    wall2 = HorizontalWall([Lx1,Lx2],Ly1)
    wall3 = HorizontalWall([Lx1,Lx2],Ly2)
    Ly1Hole = Ly1+(Ly2-Ly1-maxholesize)*rand()
    Ly2Hole = Ly1Hole + maxholesize
    disk =  create_disk(Lx1,Lx2,Ly1,Ly2, radiusdisk, massdisk, velocitydisk)
    nofcell  = cell.numberofcell +1
    sharedwall = VerticalSharedWall(Lx2,[Ly1,Ly1Hole,Ly2Hole,Ly2],(nofcell,nofcell+1))
    disk.numberofcell = nofcell
    cell = Cell([wall1,wall2,wall3,sharedwall],disk,nofcell)
    cell
end

function create_last_right_cell(cell,size_x,size_y)
    wall1 = cell.walls[end]
    Lx1 = cell.walls[end].x
    Lx2 = Lx1 + size_x
    Ly2 = size_y
    wall2 = HorizontalWall([Lx1,Lx2],Ly1)
    wall3 = HorizontalWall([Lx1,Lx2],Ly2)
    wall4 = VerticalWall(Lx2,[Ly1,Ly2])
    disk =  create_disk(Lx1,Lx2,Ly1,Ly2, radiusdisk, massdisk, velocitydisk)
    nofcell  = cell.numberofcell +1
    disk.numberofcell = nofcell
    cell = Cell([wall1,wall2,wall3,wall4],disk,nofcell)
    cell
end

function create_board(numberofcells,size_x,size_y)
    cell = create_initial_cell(size_x,size_y)
    board = [cell]

    if numberofcells == 2
        cell = create_last_right_cell(cell,size_x,size_y)
        push!(board,cell)
    elseif numberofcells > 1
        for i in 2:numberofcells-1
            cell = create_new_right_cell(cell,size_x,size_y)
            push!(board,cell)
        end
            cell = create_last_right_cell(cell,size_x,size_y)
            push!(board,cell)
    end

    board = Board(board)
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

function create_particle(board, mass, velocity,delta_x,delta_y, numberofcell)
    cell = board.cells[numberofcell]
    disk = board.cells[numberofcell].disk
    Lx2 = Lx1 + delta_x
    Ly2 = Ly1 +delta_y
    theta = rand()*2*pi
    vx = cos(theta)*velocity
    vy = sin(theta)*velocity
    v = [vx, vy]
    solape = true
    p = Particle([-100,-100],v, mass, numberofcell,0)
    while solape
        x = randuniform(Lx1, Lx2)[1]
        y = randuniform(Ly1, Ly2)[1]
        p = Particle([x,y],v, mass, numberofcell,0)
        solape = overlap(p,disk)
    end
    p
end

end




