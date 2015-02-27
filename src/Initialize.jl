module Initialize

VERSION < v"0.4-" && using Docile
using Lexicon
using Objects
using DataStructures

export create_board_with_particle, create_initial_cell, create_new_left_cell, create_new_right_cell

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
function create_disk(Lx1,Lx2,Ly1,Ly2,radius, mass, normvelocity,numberofcell)
    x = randuniform(Lx1 + radius, Lx2 - radius)
    y = randuniform(Ly1 + radius, Ly2 - radius)
    theta = rand()*2*pi
    vx = cos(theta)*normvelocity
    vy = sin(theta)*normvelocity
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

@doc """Creates the initial cell with the size and initial coordinates for s and y specified. Inside of this
it creates a particle with a uniform sampling"""->
function create_initial_cell_with_particle( Lx1, Ly1,size_x,size_y,radiusdisk, massdisk, velocitydisk,
                                           massparticle, velocityparticle, windowsize)
    Lx2 = Lx1 + size_x
    Ly2 = Ly1 + size_y
    Ly3, Ly4 = create_window(Ly1, Ly2, windowsize)
    nofcell = 0
    leftsharedwall = VerticalSharedWall(Lx1,[Ly1,Ly3,Ly4,Ly2],(nofcell,nofcell-1))
    wall2 = HorizontalWall([Lx1,Lx2],Ly1)
    wall3 = HorizontalWall([Lx1,Lx2],Ly2)
    rightsharedwall = VerticalSharedWall(Lx2,[Ly1,Ly3,Ly4,Ly2],(nofcell,nofcell+1))
    disk =  create_disk(Lx1,Lx2,Ly1,Ly2, radiusdisk, massdisk, velocitydisk, nofcell)
    particle = create_particle(Lx1,Lx2,Ly1,Ly2, massparticle, velocityparticle, nofcell)
    while overlap(particle,disk)
        disk =  create_disk(Lx1,Lx2,Ly1,Ly2, radiusdisk, massdisk, velocitydisk, nofcell)
        particle = create_particle(Lx1,Lx2,Ly1,Ly2, massparticle, velocityparticle, nofcell)
    end
    cell = Cell([leftsharedwall,wall2,wall3,rightsharedwall],disk,nofcell)
    cell, particle
end

@doc """Extract the general data associated to the initial cell"""->
function parameters_to_create_a_new_cell(cell::Cell)
    size_x = cell.walls[4].x - cell.walls[1].x
    size_y = cell.walls[3].y - cell.walls[2].y
    radiusdisk = cell.disk.radius
    massdisk = cell.disk.mass
    velocitydisk = norm(cell.disk.v)                      ######Ver la forma de mejorar esto
    windowsize = cell.walls[1].y[3] - cell.walls[1].y[2]
    size_x, size_y, radiusdisk, massdisk, velocitydisk, windowsize
end


function create_new_right_cell(cell::Cell, particle::Particle)
    size_x, size_y, radiusdisk, massdisk, velocitydisk, windowsize = parameters_to_create_a_new_cell(cell)

    leftsharedwall = cell.walls[end]
    Lx1 = cell.walls[end].x
    Ly1 = cell.walls[end].y[1]
    Lx2 = Lx1 + size_x
    Ly2 = Ly1 + size_y
    wall2 = HorizontalWall([Lx1,Lx2],Ly1)
    wall3 = HorizontalWall([Lx1,Lx2],Ly2)
    Ly3, Ly4 = create_window(Ly1, Ly2, windowsize)
    nofcell  = cell.numberofcell +1
    disk =  create_disk(Lx1,Lx2,Ly1,Ly2, radiusdisk, massdisk, velocitydisk, nofcell)
    while overlap(particle,disk)
        disk =  create_disk(Lx1,Lx2,Ly1,Ly2, radiusdisk, massdisk, velocitydisk, nofcell)
    end
    rightsharedwall = VerticalSharedWall(Lx2,[Ly1,Ly3,Ly4,Ly2],(nofcell,nofcell+1))
    cell = Cell([leftsharedwall,wall2,wall3,rightsharedwall],disk,nofcell)
    cell
end


function create_new_left_cell(cell::Cell, particle::Particle)
    size_x, size_y, radiusdisk, massdisk, velocitydisk, windowsize = parameters_to_create_a_new_cell(cell)

    Lx2 = cell.walls[1].x
    Ly1 = cell.walls[1].y[1]
    Lx1 = Lx2 - size_x
    Ly2 = Ly1 + size_y
    wall2 = HorizontalWall([Lx1,Lx2],Ly1)
    wall3 = HorizontalWall([Lx1,Lx2],Ly2)
    rightsharedwall = cell.walls[1]
    Ly3, Ly4 = create_window(Ly1, Ly2, windowsize)
    nofcell  = cell.numberofcell - 1
    disk =  create_disk(Lx1,Lx2,Ly1,Ly2, radiusdisk, massdisk, velocitydisk,nofcell)
    while overlap(particle,disk)
        disk =  create_disk(Lx1,Lx2,Ly1,Ly2, radiusdisk, massdisk, velocitydisk, nofcell)
    end
    leftsharedwall = VerticalSharedWall(Lx1,[Ly1,Ly3,Ly4,Ly2],(nofcell,nofcell-1))
    cell = Cell([leftsharedwall,wall2,wall3,rightsharedwall],disk,nofcell)
    cell
end

@doc """Returns a Board instance with one cell and the particle located inside it"""->
function create_board_with_particle(Lx1, Ly1,size_x,size_y,radiusdisk, massdisk, velocitydisk,
                                    massparticle, velocityparticle, windowsize)
    cell, particle = create_initial_cell_with_particle(Lx1, Ly1,size_x,size_y,radiusdisk, massdisk, velocitydisk,
                                                       massparticle, velocityparticle, windowsize)
    board = Deque{Cell}()
    push!(board,cell)
    board = Board(board)
    board, particle
end

end




