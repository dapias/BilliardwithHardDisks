#include("./objects.jl")
# #######
# In this module is defined the rules for the calculation of the intervals of time of collision
# and the rules of collision for the objects defined in the board. Additionaly is implemented
# the caller to the functions that creates a new cell on the board.
#########

module Rules

VERSION < v"0.4-" && using Docile
using Lexicon
using DataStructures
using Initialize
using Objects
using LaTeXStrings

export move, dtcollision, collision
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
