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


#Hacer esto con metaprogramming o con un macro!

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


################################Particle#############################################################3

#Parece ser igual para la pared independiente de la velocidad
@doc doc"""Calculates the time of collision between a Particle and a VerticalWall"""->
function dtcollision(p::Particle, VW::Vertical)
    #La pared siempre va a estar acotada por números positivos
    dt = Inf
    if p.v[1] > 0
        if p.r[1] < VW.x
            dt = (VW.x - p.r[1])/p.v[1]
        end
    elseif p.v[1] < 0
        if p.r[1] > VW.x
            dt = (p.r[1] - VW.x)/-p.v[1]
        end
    end
    dt
end

function dtcollision(p::Particle, HW::HorizontalWall)
    dt = Inf
    if p.v[2] > 0
        if p.r[2] < HW.y
            dt = (HW.y - p.r[2])/p.v[2]
        end
    elseif p.v[2] < 0
        if p.r[2] > HW.y
            dt = (p.r[2] - HW.y)/-p.v[2]
        end
    end
    dt
end




@doc doc"""Calculates the time of collision between two Disks."""->
function dtcollision(p::Particle,d::Disk)
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
    #dt = min((-rdotv+ sqrt(d))/vcuadrado, (-rdotv - sqrt(d))/vcuadrado)
    dt = (rcuadrado - (d.radius)^2)/(-rdotv + sqrt(dis))
    return dt
end


function dtcollision(p::Particle,c::Cell)
    time = zeros(5)
    index = 1
    for wall in c.walls
        dt = dtcollision(p,wall)
        time[index] = dt
        index += 1
    end
    time[end] = dtcollision(p,c.disk)
    dt,k = findmin(time)
    dt,k
end

==(w1::Wall,w2::Wall) = (w1.x == w2.x && w1.y == w2.y)

function dtcollision_without_wall(p::Particle,c::Cell, w::Wall)
    time = zeros(5)
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
    time[end] = dtcollision(p,c.disk)
    dt,k = findmin(time)
    dt,k
end



function dtcollision_without_disk(p::Particle,c::Cell)
    time = zeros(4)
    index = 1
    for wall in c.walls
        dt = dtcollision(p,wall)
        time[index] = dt
        index += 1
    end
    dt,k = findmin(time)
    dt,k
end




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

function updatelabel(p::Particle, VSW::VerticalSharedWall)
    update = false
    Ly1Hole = VSW.y[2]
    Ly2Hole = VSW.y[3]
    if Ly1Hole < p.r[2] < Ly2Hole
        plabel = p.numberofcell
        for label in VSW.label
            if plabel != label
                p.numberofcell = label
            end
        end
        update = true
    end
    update
end


function collision(p::Particle, VSW::VerticalSharedWall )
    if updatelabel(p,VSW)
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

function collision(d::Disk, p::Particle)
    deltar = p.r - d.r
    deltav = p.v - d.v
    h = dot(deltar,deltav)
    sigma = d.radius
    J = 2*p.mass*d.mass*h/(sigma*(p.mass + d.mass))
    p.v += J*deltar/(sigma*p.mass)
    d.v -= J*deltar/(sigma*d.mass)
end

function collision(p1::Disk, p2::Disk)
    deltar = p1.r - p2.r
    deltav = p1.v - p2.v
    h = dot(deltar,deltav)
    sigma = p1.radius+p2.radius
    J = 2*p1.mass*p2.mass*h/(sigma*(p1.mass + p2.mass))
    p1.v -= J*deltar/(sigma*p1.mass)
    p2.v += J*deltar/(sigma*p2.mass)
end

end
