module Initialize

VERSION < v"0.4-" && using Docile
using Lexicon
using Objects
using DataStructures

export create_board_with_particle, create_new_left_cell, create_new_right_cell

@doc """#randuniform(liminf, limsup, dim=1)
Creates an random Array(Vector) of *dimension* dim with limits: liminf, limsup""" ->
function randuniform(liminf, limsup, dim=1)
    liminf + rand(dim)*(limsup - liminf)
end

@doc """#overlap(::Particle,::Disk)
Check if a Particle and a Disk overlap. Return a Boolean"""->
function overlap(p::Particle, d::Disk)
    deltar = d.r - p.r
    r = norm(deltar)
    return r < d.radius
end

@doc doc"""#create_particle(Lx1,Lx2,Ly1,Ly2, mass, velocitynorm, numberofcell::Int)
Creates a Particle with Cartesian coordinates between the boundaries Lx1, Lx2, Ly1, Ly2; and a random velocity
of constant norm. It is worth noting that the passed parameters define corners with Cartesian coordinates:
> (Lx1,Ly1),(Lx1, y2), (Lx2,Ly1), (Lx2,Ly2).
"""->
function create_particle(Lx1::Real,Lx2::Real,Ly1::Real,Ly2::Real, mass::Real, velocitynorm::Real, numberofcell::Int)
    x = randuniform(Lx1, Lx2)
    y = randuniform(Ly1, Ly2)
    theta = rand()*2*pi
    vx = cos(theta)*velocitynorm
    vy = sin(theta)*velocitynorm
    v = [vx, vy]
    Particle([x,y],v, mass, numberofcell,0)
end

@doc doc"""#create_disk(Lx1,Lx2,Ly1,Ly2, radius, mass, velocitynorm, numberofcell::Int)
Creates a Disk enclosed in a box with boundaries Lx1, Lx2, Ly1, Ly2; and a random velocity
of constant norm. It is worth noting that the passed parameters define  corners with Cartesian coordinates:
> (Lx1,Ly1),(Lx1, y2), (Lx2,Ly1), (Lx2,Ly2). """->
function create_disk(Lx1::Real,Lx2::Real,Ly1::Real,Ly2::Real,radius::Real, mass::Real, velocitynorm::Real, numberofcell::Int)
    x = randuniform(Lx1 + radius, Lx2 - radius)
    y = randuniform(Ly1 + radius, Ly2 - radius)
    theta = rand()*2*pi
    vx = cos(theta)*velocitynorm
    vy = sin(theta)*velocitynorm
    v = [vx, vy]
    Disk([x,y],v,radius, mass,numberofcell)
end

@doc """#create_window(Ly1, Ly2, windowsize)
Returns the extrema y-coordinates for a window with size windowsize centered between Ly1 and Ly2 (regardless of
the x-coordinate).
"""->
function create_window(Ly1::Real, Ly2::Real, windowsize::Real)
    Ly3 = Ly1 + (Ly2 - Ly1)/2. - windowsize/2.
    Ly4 = Ly3 + windowsize
    Ly3, Ly4
end

@doc """#create_initial_cell_with_particle( Lx1, Ly1,size_x,size_y,radiusdisk, massdisk, velocitydisk,
                                           massparticle, velocityparticle, windowsize)
Creates an instance of Cell. Size of its sides and initial coordinates for the left down corner are passed (Lx1,Ly1)
together with the needed data to create the embedded disk and a particle inside the cell."""->
function create_initial_cell_with_particle( Lx1::Real, Ly1::Real,size_x::Real,size_y::Real,radiusdisk,
                                           massdisk::Real, velocitydisk::Real,
                                           massparticle::Real, velocityparticle::Real, windowsize::Real)
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

@doc """#parameters_to_create_a_new_cell(::Cell)
Extract the general data associated to a previous created cell"""->
function parameters_to_create_a_new_cell(cell::Cell)
    size_x = cell.walls[4].x - cell.walls[1].x
    size_y = cell.walls[3].y - cell.walls[2].y
    radiusdisk = cell.disk.radius
    massdisk = cell.disk.mass
    velocitydisk = norm(cell.disk.v)                      ######Ver la forma de mejorar esto
    windowsize = cell.walls[1].y[3] - cell.walls[1].y[2]
    size_x, size_y, radiusdisk, massdisk, velocitydisk, windowsize
end


@doc """#create_new_right_cell(::Cell,::Particle)
Creates a new cell that shares the rightmost verticalwall of the passed cell. A Particle is passed
to avoid overlap with the embedded Disk.
"""->
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


@doc """#create_new_left_cell(::Cell,::Particle)
Creates a new cell that shares the leftmost verticalwall of the passed cell. A Particle is passed
to avoid overlap with the embedded Disk.
"""->
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

@doc """#create_board_with_particle(Lx1, Ly1,size_x,size_y,radiusdisk, massdisk, velocitydisk,
                                    massparticle, velocityparticle, windowsize)
Returns a Board instance with one cell and a particle inside it (that is also returned). Size of its sides and initial coordinates for the left down corner are passed (Lx1,Ly1)
together with the needed data to create the embedded disk and a particle inside the cell. """->
function create_board_with_particle(Lx1::Real, Ly1::Real,size_x::Real,size_y::Real,radiusdisk,
                                    massdisk::Real, velocitydisk::Real,
                                    massparticle::Real, velocityparticle::Real, windowsize::Real)
    cell, particle = create_initial_cell_with_particle(Lx1, Ly1,size_x,size_y,radiusdisk, massdisk, velocitydisk,
                                                       massparticle, velocityparticle, windowsize)
    board = Deque{Cell}()
    push!(board,cell)
    board = Board(board)
    board, particle
end

end




