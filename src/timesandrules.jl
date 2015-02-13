#include("./objects.jl")

module Rules


VERSION < v"0.4-" && using Docile

importall Objects

export move, dtcollision, collision

@doc doc"""Update the position of the Disk through moving it as a free particle with velocity Disk.v
during a time interval dt"""->
move(p::Disk, dt::Real) = p.r += p.v * dt

@doc doc"""Calculates the time of collision between the Disk and a VerticalWall"""->
function dtcollision(p::Disk, V::VerticalWall)
    #La pared siempre va a estar acotada por números positivos
    dt = Inf
    if p.v[1] > 0
        if p.r[1] < V.x
            dt = (V.x - (p.r[1] + p.radius))/p.v[1]
        end
    elseif p.v[1] < 0
        if p.r[1] > V.x
            dt = ((p.r[1] - p.radius) - V.x)/-p.v[1]
        end
    end
    dt
end


#Hacer esto con metaprogramming o con un macro!

@doc doc"""Calculates the time of collision between the Disk and a HorizontallWall"""->
function dtcollision(p::Disk, H::HorizontalWall)
    dt = Inf
    if p.v[2] > 0
        if p.r[2] < H.y
            dt = (H.y - (p.r[2] + p.radius))/p.v[2]
        end
    elseif p.v[2] < 0
        if p.r[2] > H.y
            dt = ((p.r[2] - p.radius) - H.y)/-p.v[2]
        end
    end
    dt
end

@doc doc"""Calculates the time of collision between two Disks."""->
function dtcollision(p1::Disk,p2::Disk)
    deltar = p1.r - p2.r
    deltav = p1.v - p2.v
    rdotv = dot(deltar, deltav)
    rcuadrado = dot(deltar,deltar)
    vcuadrado = dot(deltav, deltav)
    if rdotv >= 0
        return Inf
    end
    d = (rdotv)^2 -(vcuadrado)*(rcuadrado - (p1.radius + p2.radius)^2)
    if d < 0
        return Inf
    end
    #dt = min((-rdotv+ sqrt(d))/vcuadrado, (-rdotv - sqrt(d))/vcuadrado)
    dt = (rcuadrado - (p1.radius + p2.radius)^2)/(-rdotv + sqrt(d))
    return dt
end

@doc doc"""Update the velocity vector of a disk (Disk.v) after it collides with a VerticalWall."""->
function collision(p1::Disk, V::VerticalWall )
    p1.v = [-p1.v[1], p1.v[2]]
end

@doc doc"""Update the velocity vector of a disk (Disk.v) after it collides with a HorizontallWall."""->
function collision(p1::Disk, H::HorizontalWall )
    p1.v = [p1.v[1],-p1.v[2]]
end

@doc doc"""Update the velocity vector of two Disks after they collides."""->
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
