#include("./objects.jl")

module Rules

VERSION < v"0.4-" && using Docile

importall Objects

export move, dtcollision, collision, dtcollision_without_disk, dtcollision_without_wall

move(d::Disk, dt::Real) = d.r += d.v * dt
move(p::Particle, dt::Real) = p.r += p.v*dt

####Time
#######################################Disk#################################################3

@doc doc"""Calculates the time of collision between the Disk and a Vertical (Wall)"""->
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


@doc doc"""Calculates the time of collision between the Disk and a HorizontallWall"""->
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

@doc doc"""Calculates the time of collision between a Disk and the Walls of the cell"""->
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


@doc doc"""Calculates the time of collision between a Disk and the Particle in the same cell"""->
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

@doc doc"""Calculates the time of collision between a Particle and a VerticalWall"""->
function dtcollision(p::Particle, VW::Vertical)
    dt = (VW.x - p.r[1])/p.v[1]
    if dt < 0
        return Inf
    end
    dt
end

function dtcollision(p::Particle, HW::HorizontalWall)
    dt = (HW.y - p.r[2])/p.v[2]
    if dt < 0
        return Inf
    end
    dt
end

dtcollision(p::Particle, d::Disk) = dtcollision(d::Disk, p::Particle)

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

@doc doc"""This function avoids the recollision between the particle and a wall in the next event""" ->
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



# function dtcollision_without_disk(p::Particle,c::Cell)
#     time = zeros(4)
#     index = 1
#     for wall in c.walls
#         dt = dtcollision(p,wall)
#         time[index] = dt
#         index += 1
#     end
#     dt,k = findmin(time)
# end




##########################################################################################


#Rules

###############Disk##################################################

@doc doc"""Update the velocity vector of a disk (Disk.v) after it collides with a VerticalWall."""->
function collision(d::Disk, V::Vertical)
    d.v = [-d.v[1], d.v[2]]
end

@doc doc"""Update the velocity vector of a disk (Disk.v) after it collides with a HorizontallWall."""->
function collision(d::Disk, H::HorizontalWall )
    d.v = [d.v[1],-d.v[2]]
end

###################Particle##############################################33
function collision(p::Particle, V::VerticalWall )
    p.v = [-p.v[1], p.v[2]]
end

function collision(p::Particle, H::HorizontalWall )
    p.v = [p.v[1],-p.v[2]]
end

function updateparticlelabel(p::Particle, VSW::VerticalSharedWall)
    update = false
    Ly1Hole = VSW.y[2]
    Ly2Hole = VSW.y[3]
    if Ly1Hole < p.r[2] < Ly2Hole
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



function collision(p::Particle, VSW::VerticalSharedWall)
    if updateparticlelabel(p,VSW)
    else
        p.v = [-p.v[1], p.v[2]]
    end
end


function collision(p::Particle, d::Disk)
    deltar = p.r - d.r
    deltav = p.v - d.v
    h = dot(deltar,deltav)
    sigma = d.radius
    J = 2*p.mass*d.mass*h/(sigma*(p.mass + d.mass))
    p.v -= J*deltar/(sigma*p.mass)
    d.v += J*deltar/(sigma*d.mass)
end

collision(d::Disk, p::Particle) = collision(p::Particle, d::Disk)

end
