module HardDiskBilliardModel

#######################################
#This module contains the needed Types and methods to implement a Simulation of a Billiard
#consisted of a particle that travels along a horizontal board that consists of cells with a
#circumscribed disk that can exchange energy with the particle.
#######################################

VERSION < v"0.4-" && using Docile
using Lexicon
using DataStructures

export Wall, Disk, Event, Cell, Particle, Board
export create_board_with_particle
export move, dtcollision, collision

abstract Object
abstract DynamicObject <: Object
abstract Wall <: Object
abstract Vertical <: Wall

@doc """Type with attributes position(r), velocity(v), mass, numberofcell and lastcollision. This last label has to be
with the main loop of the simulation (see *simulation.jl*)"""->
type Particle <: DynamicObject
    r::Array{Float64,1}
    v::Array{Float64,1}
    mass::Float64
    numberofcell::Int
    lastcollision::Int
end

Particle(r,v, mass, numberofcell) = Particle(r,v,mass , numberofcell, 0)

@doc """Type with attributes position(r), velocity(v), radiusm mass, numberofcell and lastcollision. This last label has to be
with the main loop of the simulation (see *simulation.jl*)"""->
type Disk <: DynamicObject
  r::Array{Float64,1}
  v::Array{Float64,1}
  radius::Float64
  mass::Float64
  numberofcell::Int
  lastcollision ::Int
end

Disk(r,v,radius, mass, numberofcell) = Disk(r,v,radius, mass , numberofcell, 0)


@doc """Type that *contains* walls, a disk and a label called numberofcell"""->
type Cell
    walls::Vector{Wall}
    disk::Disk
    numberofcell::Int
end

#Cell(walls,label) = Cell(walls,label,Disk([-100.,-100.],[0.,0.],0.))

@doc doc"""Type that is implemented as a Deque(Double-ended queue) of Cells. It allows to insert
new cells as the particle diffuses"""->
type Board
    cells::Deque{Cell}
end

# @doc doc"""Type with attributes x and y. x corresponds to its horizontal position in a Cartesian Plane
# (just a number) and y represents its initial and final height in the Plane (Array of length equal to 2)."""  ->
# immutable VerticalWall <: Vertical
#   x :: Float64
#   y :: Array{Float64,1}
# end

@doc doc"""Type with attributes x and y. x corresponds to its horizontal extension in a Cartesian plane
(initial and final position -Array of length equal to 2- and y corresponds to its vertical position
(a number).""" ->
immutable HorizontalWall <:Wall
  x :: Array{Float64,1}
  y :: Float64
end


immutable VerticalSharedWall <: Vertical
  x :: Float64
  y :: Array{Float64,1}  #Array of a length greater than the VerticalWall
  sharedcells::(Int,Int) #Adjacent cells that share the wall
end

@doc doc"""Type with attributes time, referenceobject, diskorwall and whenwaspredicted. The last attribute makes reference to the cycle
within the main loop in which the event was predicted (see simulation in simulation.jl)."""->
type Event
    time :: Number
    referenceobject::DynamicObject           #Revisar en el diseño si conviene más tener un sólo objeto
    diskorwall ::Object                      ##tal como cell asociado a un evento y la partícula dentro de cell.
    whenwaspredicted:: Int
end

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


@doc """#move(::Disk, dt::Real)
Update the  position of the Disk by moving it a time dt"""->
move(d::Disk, dt::Real) = d.r += d.v * dt
@doc """#move(::Particle, dt::Real)
Update the  position of the Particle by moving it a time dt"""->
move(p::Particle, dt::Real) = p.r += p.v*dt

####Time
#######################################Disk#################################################3

@doc """#dtcollision(::Disk,::Vertical)
Returns the time of collision between a Disk and a Vertical (Wall). If they don't collide it retuns ∞ """->
function dtcollision(d::Disk, VW::Vertical)
    #La pared siempre va a estar acotada por números positivos
    dt = Inf
    if d.v[1] > 0
        if d.r[1] < VW.x
            dt = (VW.x - (d.r[1] + d.radius))/d.v[1]
        end
    elseif d.v[1] < 0
        if d.r[1] > VW.x
            dt = ((d.r[1] - d.radius) - VW.x)/-d.v[1]
        end
    end
    dt
end


@doc """#dtcollision(::Disk,::HorizontalWall)
Returns the time of collision between a Disk and a HorizontallWall.If they don't collide it retuns ∞"""->
function dtcollision(d::Disk, HW::HorizontalWall)
    dt = Inf
    if d.v[2] > 0
        if d.r[2] < HW.y
            dt = (HW.y - (d.r[2] + d.radius))/d.v[2]
        end
    elseif d.v[2] < 0
        if d.r[2] > HW.y
            dt = ((d.r[2] - d.radius) - HW.y)/-d.v[2]
        end
    end
    dt
end

@doc """#dtcollision(::Disk,::Cell)
Calculates the minimum time of collision between the Disk belonged to Cell and the Walls of the Cell. It retuns
the interval of time and the index of the Wall inside the Cell:
> 1 = left wall, 2 = bottom wall, 3 = top wall, 4 = right wall."""->
function dtcollision(d::Disk, c::Cell)
    time = zeros(4)
    index = 1
    for wall in c.walls
        dt = dtcollision(d,wall)
        time[index] = dt
        index += 1
    end
    dt,k = findmin(time)
end

@doc """#dtcollision(::Disk,::Particle)
Calculates the time of collision between a Disk and the Particle in the same cell.If they don't collide it retuns ∞"""->
function dtcollision(d::Disk, p::Particle)
    deltar = p.r - d.r
    deltav = p.v - d.v
    rdotv = dot(deltar, deltav)
    rcuadrado = dot(deltar,deltar)
    vcuadrado = dot(deltav, deltav)
    if rdotv >= 0
        return Inf
    end
    dis = (rdotv)^2 -(vcuadrado)*(rcuadrado - (d.radius)^2)
    if dis < 0
        return Inf
    end
    dt = (rcuadrado - (d.radius)^2)/(-rdotv + sqrt(dis))
    return dt
end

################################Particle#############################################################3

@doc """#dtcollision(::Particle, ::Vertical)
Calculates the time of collision between a Particle and a VerticalWall.If they don't collide it retuns ∞ """->
function dtcollision(p::Particle, VW::Vertical)
    dt = (VW.x - p.r[1])/p.v[1]
    if dt < 0
        return Inf
    end
    dt
end

@doc doc"""#dtcollision(::Particle,::HorizontalWall)
Returns the time of collision between a Disk and a HorizontallWall.If they don't collide it retuns ∞"""->
function dtcollision(p::Particle, HW::HorizontalWall)
    dt = (HW.y - p.r[2])/p.v[2]
    if dt < 0
        return Inf
    end
    dt
end

@doc """#dtcollision(::Particle,::Disk)
See *dtcollision(::Disk,::Particle)*"""->
dtcollision(p::Particle, d::Disk) = dtcollision(d::Disk, p::Particle)

@doc """#dtcollision(::Particle,::Cell)
Calculates the minimum time of collision between a Particle and the Walls of the a. It retuns
the interval of time and the index of the Wall inside the Cell:
> 1 = left wall, 2 = bottom wall, 3 = top wall, 4 = right wall."""->
function dtcollision(p::Particle,c::Cell)
    time = zeros(4)
    index = 1
    for wall in c.walls
        dt = dtcollision(p,wall)
        time[index] = dt
        index += 1
    end
    dt,k = findmin(time)
end

==(w1::Wall,w2::Wall) = (w1.x == w2.x && w1.y == w2.y)

@doc doc"""#dtcollision(::Particle,::Cell, ::Wall)
This function is similar to *dtcollision(::Particle,::Cell)* but avoids
the recollision between a Particle and a Wall in the next event if they collides in the last Event.""" ->
function dtcollision(p::Particle,c::Cell, w::Wall)
    time = zeros(4)
    index = 1
    for walle in c.walls
        if walle == w
            dt = Inf
        else
            dt = dtcollision(p,walle)
        end
        time[index] = dt
        index += 1
    end
    dt,k = findmin(time)
end



##########################################################################################
#Rules
###############Disk##################################################
@doc doc"""#collision(::Disk, ::Vertical, ::Board)
Update the velocity vector of a Disk (Disk.v) after it collides with a Vertical(Wall)."""->
function collision(d::Disk, V::Vertical)
    d.v = [-d.v[1], d.v[2]]
end

@doc doc"""#collision(::Disk, ::Vertical, ::Board)
Update the velocity vector of a Disk (Disk.v) after it collides with a Vertical(Wall). The Board is given just to
enforce the fact that collision is made in the context of a Cell. """->
function collision(d::Disk, V::Vertical,b::Board)
    collision(d,V)
end

@doc doc"""#collision(::Disk, ::HorizontalWall, ::Board)
Update the velocity vector of a Disk (Disk.v) after it collides with a HorizontallWall."""->
function collision(d::Disk, H::HorizontalWall)
    d.v = [d.v[1],-d.v[2]]
end

@doc doc"""#collision(::Disk, ::HorizontalWall, ::Board)
Update the velocity vector of a Disk (Disk.v) after it collides with a HorizontallWall. The Board is given just to
enforce the fact that collision is made in the context of a Cell."""->
function collision(d::Disk, H::HorizontalWall, b::Board)
    collision(d,H)
end

###################Particle##############################################33
@doc doc"""#collision(::Particle, ::HorizontalWall)
Update the velocity vector of a Particle (Particle.v) after it collides with a HorizontallWall."""->
function collision(p::Particle, H::HorizontalWall)
    p.v = [p.v[1],-p.v[2]]
end

@doc doc"""#collision(::Particle, ::HorizontalWall, ::Board)
Update the velocity vector of a Particle (Particle.v) after it collides with a HorizontallWall. The Board is given just to
enforce the fact that collision is made in the context of a Cell."""->
function collision(p::Particle, H::HorizontalWall, b::Board )
    collision(p,H)
end

@doc """#collision(::Particle, ::Vertical)
Update the velocity vector of a Particle (Particle.v) after it collides with a rigid Vertical(Wall)."""->
function collision(p::Particle, VW::Vertical)
    p.v = [-p.v[1], p.v[2]]
end


@doc """#collision(::Particle, ::VerticalSharedWall, ::Board)
Update the attributes of the particle according to the site where it collides with the VerticalSharedWall. If the collision is
through the window, the label of the particle is updated to the label of the new cell, that is created in case it wasn't
done before. Else if the collision is through the rigid part of the wall, it updates the particle velocity according to a
specular collision"""->
function collision(p::Particle, VSW::VerticalSharedWall, b::Board)
    new = false
    if updateparticlelabel(p,VSW)
        if !is_cell_in_board(b, p)
            newcell!(b,p)
            new = true
        end
    else
        collision(p,VSW)
    end
    new
end

@doc """#updateparticlelabel(::Particle, ::VerticalSharedWall)
Update the label of the particle when it passes through the window of the VerticalSharedWall."""->
function updateparticlelabel(p::Particle, VSW::VerticalSharedWall)
    update = false
    Ly1window = VSW.y[2]
    Ly2window= VSW.y[3]
    if Ly1window < p.r[2] < Ly2window
        pcell = p.numberofcell
        for nofcell in VSW.sharedcells
            if pcell != nofcell
                p.numberofcell = nofcell
            end
        end
        update = true
    end
    update
end


@doc """#is_cell_in_board(::Board,::Particle)
Ask for the existence of a Cell with the label associated to the Particle (Particle.numberofcell)"""->
function is_cell_in_board(b::Board,p::Particle)
    iscell = false
    if back(b.cells).numberofcell <= p.numberofcell <= front(b.cells).numberofcell
        iscell = true
    end
    iscell
end

@doc """#newcell!(::Board, ::Particle)
Introduces a new cell on the board according to the value of the attribute *numberofcell* of the particle.
It may pushes the cell at the left or right side of the board to mantain the order in the **Dequeue** structure of the
board: at the back the leftmost cell, at front the rightmost cell."""->
function newcell!(b::Board, p::Particle)
    if back(b.cells).numberofcell - 1 == p.numberofcell
        cell = create_new_left_cell(back(b.cells),p)
        push!(b.cells, cell)
    elseif front(b.cells).numberofcell + 1 == p.numberofcell
        cell = create_new_right_cell(front(b.cells),p)
        unshift!(b.cells,cell)
    end
end

@doc """#collision(::Particle, ::Disk)
Updates the velocities for the Particle and Disk after they collides through an elastic collision. """->
function collision(p::Particle, d::Disk)
    deltar = p.r - d.r
    deltav = p.v - d.v
    h = dot(deltar,deltav)
    sigma = d.radius
    J = 2*p.mass*d.mass*h/(sigma*(p.mass + d.mass))
    p.v -= J*deltar/(sigma*p.mass)
    d.v += J*deltar/(sigma*d.mass)
end

@doc """#collision(::Particle, ::Disk, ::Board)
Updates the velocities for the Particle and Disk after they collides through an elastic collision. The Board is given just to
enforce the fact that collision is made in the context of a Cell. """->
function collision(p::Particle, d::Disk, b::Board)
    collision(p,d)
end


@doc """#collision(::Disk, ::Particle)
See *collision(::Particle, ::Disk)*"""->
collision(d::Disk, p::Particle) = collision(p::Particle, d::Disk)

@doc """#collision(::Disk, ::Particle, ::Board).
See *collision(::Particle, ::Disk, ::Board)*"""->
collision(d::Disk, p::Particle, b::Board) = collision(p::Particle, d::Disk, b::Board)

end
