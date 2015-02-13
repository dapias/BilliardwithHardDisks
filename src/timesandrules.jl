#include("./objects.jl")

module Rules


VERSION < v"0.4-" && using Docile

importall Objects

export move, dtcollision, collision

@doc doc"""Update the position of the Disk through moving it as a free particle with velocity Disk.v
during a time interval dt"""->
move(d::Disk, dt::Real) = d.r += d.v * dt

@doc doc"""Calculates the time of collision between the Disk and a VerticalWall"""->
function dtcollision(d::Disk, VW::VerticalWall)
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

#Parece ser igual para la pared independiente de la velocidad
@doc doc"""Calculates the time of collision between a Particle and a VerticalWall"""->
function dtcollision(p::Particle, VW::VerticalWall)
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
    dt = (rcuadrado - (d.radius)^2)/(-rdotv + sqrt(dist))
    return dt
end


@doc doc"""Update the velocity vector of a disk (Disk.v) after it collides with a VerticalWall."""->
function collision(d1::Disk, V::VerticalWall )
    p1.v = [-d1.v[1], d1.v[2]]
end

@doc doc"""Update the velocity vector of a disk (Disk.v) after it collides with a HorizontallWall."""->
function collision(d1::Disk, H::HorizontalWall )
    p1.v = [d1.v[1],-d1.v[2]]
end

function collision(p1::Particle, V::VerticalWall )
    p1.v = [-p1.v[1], p1.v[2]]
end

function collision(p1::Particle, VH::VerticalHoleWall )
    Ly1Hole = VH.y[2]
    Ly2Hole = VH.y[3]
    if Ly1Hole < p1.r[2] < Ly2Hole
        nothing
    else
        p1.v = [-p1.v[1], p1.v[2]]
    end
end


@doc doc"""Update the velocity vector of two Disks after they collides."""->
function collision(p::Particle, d::Disk)
    deltar = p.r - d.r
    deltav = p.v - d.v
    h = dot(deltar,deltav)
    sigma = d.radius
    J = 2*p.mass*d.mass*h/(sigma*(p.mass + d.mass))
    p.v -= J*deltar/(sigma*p.mass)
    d.v += J*deltar/(sigma*d.mass)
end

end
