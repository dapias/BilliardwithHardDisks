module Init

VERSION < v"0.4-" && using Docile

using Objects
using DataStructures

export create_board, create_particle

@doc doc"""Creates an random Array(Vector) of *dimension* dim with limits: liminf, limsup""" ->
function randuniform(liminf, limsup, dim=1)
    liminf + rand(dim)*(limsup - liminf)
end


function overlap(p::Particle, d::Disk)
    deltar = d.r - p.r
    r = norm(deltar)
    return r < d.radius
end

@doc doc"""Creates a Particle enclosed in a box with boundaries at Lx1, Lx2, Ly1, Ly2; and with a random velocity
of constant norm"""->
function create_particle(Lx1,Lx2,Ly1,Ly2, mass, velocity, numberofcell)
    x = randuniform(Lx1, Lx2)
    y = randuniform(Ly1, Ly2)
    theta = rand()*2*pi
    vx = cos(theta)*velocity
    vy = sin(theta)*velocity
    v = [vx, vy]
    Particle([x,y],v, mass, numberofcell,0)
end

@doc doc"""Creates a Disk enclosed in a box with boundaries Lx1, Lx2, Ly1, Ly2; and with a random velocity
of constant norm"""->
function create_disk(Lx1,Lx2,Ly1,Ly2,radius, mass, velocity,numberofcell)
    x = randuniform(Lx1 + radius, Lx2 - radius)
    y = randuniform(Ly1 + radius, Ly2 - radius)
    theta = rand()*2*pi
    vx = cos(theta)*velocity
    vy = sin(theta)*velocity
    v = [vx, vy]
    Disk([x,y],v,radius, mass,numberofcell)
end

@doc """Gives the y-coordinates for the window at the sharedwalls exactly at half of the height of
the cell"""->
function create_window(Ly1, Ly2, windowsize)
    Ly3 = Ly1 + (Ly2 - Ly1)/2. - windowsize/2.
    Ly4 = Ly3 + windowsize
    Ly3, Ly4
end


function create_initial_cell( Lx1, Ly1,size_x,size_y,radiusdisk, massdisk, velocitydisk,
                             massparticle, velocityparticle, windowsize)
    Lx2 = Lx1 + size_x
    Ly2 = Ly1 + size_y
    Ly3, Ly4 = create_window(Ly1, Ly2, windowsize)
    nofcell = 0
    wall1 = VerticalSharedWall(Lx1,[Ly1,Ly3,Ly4,Ly2],(nofcell,nofcell-1))
    wall2 = HorizontalWall([Lx1,Lx2],Ly1)
    wall3 = HorizontalWall([Lx1,Lx2],Ly2)
    sharedwall = VerticalSharedWall(Lx2,[Ly1,Ly3,Ly4,Ly2],(nofcell,nofcell+1))
    disk =  create_disk(Lx1,Lx2,Ly1,Ly2, radiusdisk, massdisk, velocitydisk, nofcell)
    particle = create_particle(Lx1,Lx2,Ly1,Ly2, massparticle, velocityparticle, nofcell)
    while overlap(particle,disk)
        disk =  create_disk(Lx1,Lx2,Ly1,Ly2, radiusdisk, massdisk, velocitydisk, nofcell)
        particle = create_particle(Lx1,Lx2,Ly1,Ly2, massparticle, velocityparticle, nofcell)
    end
    cell = Cell([wall1,wall2,wall3,sharedwall],disk,nofcell)
    cell, particle
end

function create_new_right_cell(cell,size_x,size_y, radiusdisk, massdisk, velocitydisk, windowsize)
    wall1 = cell.walls[end]
    Lx1 = cell.walls[end].x
    Ly1 = cell.walls[end].y[1]
    Lx2 = Lx1 + size_x
    Ly2 = size_y + Ly1
    wall2 = HorizontalWall([Lx1,Lx2],Ly1)
    wall3 = HorizontalWall([Lx1,Lx2],Ly2)
    Ly3, Ly4 = create_window(Ly1, Ly2, windowsize)
    nofcell  = cell.numberofcell +1
    disk =  create_disk(Lx1,Lx2,Ly1,Ly2, radiusdisk, massdisk, velocitydisk, nofcell)
    sharedwall = VerticalSharedWall(Lx2,[Ly1,Ly3,Ly4,Ly2],(nofcell,nofcell+1))
    cell = Cell([wall1,wall2,wall3,sharedwall],disk,nofcell)
    cell
end


function create_new_left_cell(cell,size_x,size_y, radiusdisk, massdisk, velocitydisk, windowsize)
    Lx2 = cell.walls[1].x
    Ly1 = cell.walls[1].y[1]
    Lx1 = Lx2 - size_x
    Ly2 = Ly1 + size_y
    wall2 = HorizontalWall([Lx1,Lx2],Ly1)
    wall3 = HorizontalWall([Lx1,Lx2],Ly2)
    wall4 = cell.walls[1]
    Ly3, Ly4 = create_window(Ly1, Ly2, windowsize)
    nofcell  = cell.numberofcell - 1
    disk =  create_disk(Lx1,Lx2,Ly1,Ly2, radiusdisk, massdisk, velocitydisk,nofcell)
    sharedwall = VerticalSharedWall(Lx1,[Ly1,Ly3,Ly4,Ly2],(nofcell,nofcell-1))
    cell = Cell([sharedwall,wall2,wall3,wall4],disk,nofcell)
    cell
end

function create_last_right_cell(cell,size_x,size_y, radiusdisk, massdisk, velocitydisk)
    wall1 = cell.walls[end]
    Lx1 = cell.walls[end].x
    Lx2 = Lx1 + size_x
    Ly1 = cell.walls[end].y[1]
    Ly2 = size_y + Ly1
    wall2 = HorizontalWall([Lx1,Lx2],Ly1)
    wall3 = HorizontalWall([Lx1,Lx2],Ly2)
    wall4 = VerticalWall(Lx2,[Ly1,Ly2])
    disk =  create_disk(Lx1,Lx2,Ly1,Ly2, radiusdisk, massdisk, velocitydisk)
    nofcell  = cell.numberofcell +1
    disk.numberofcell = nofcell
    cell = Cell([wall1,wall2,wall3,wall4],disk,nofcell)
    cell
end

function create_board(size_x,size_y, radiusdisk, massdisk, velocitydisk, windowsize,  Lx1, Ly1)
    cell, = create_initial_cell(Lx1, Ly1,size_x,size_y,radiusdisk, massdisk, velocitydisk,
                             radiusparticle, massparticle, velocityparticle, windowsize)
    board = Deque{Cell}()
    push!(board,cell)
    board = Board(board)
end



end




