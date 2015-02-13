module Objects

VERSION < v"0.4-" && using Docile

export Object, Wall, Disk
export VerticalWall, HorizontalWall, Event, Cell, VerticalHoleWall, Particle, Board

abstract Object
abstract Wall <: Object








type Particle <: Object
    r::Array{Float64,1}
    v::Array{Float64,1}
    mass::Float64
    numberofcell::Int
end

Particle(r,v) = Particle(r,v,1.0,1) #Number of cell and mass equal to 1 by default
Particle(r,v,mass) = Particle(r,v,mass,1)

type Disk <:Object
  r::Array{Float64,1}
  v::Array{Float64,1}
  radius::Float64
  mass::Float64
  numberofcell::Int
  lastcollision ::Int
end


Disk(r,v,radius) = Disk(r,v,radius,1.0,1,0) #Fixed mass of 1.0.
Disk(r,v,radius, mass) = Disk(r,v,radius, mass , 1, 0)
Disk(r,v,radius, mass, numberofcell) = Disk(r,v,radius, mass , numberofcell, 0)



type Cell
    walls::Vector{Wall}
    disk::Disk
    label
end

#Cell(walls,label) = Cell(walls,label,Disk([-100.,-100.],[0.,0.],0.))

type Board
    cells::Vector{Cell}
end

@doc doc"""Type with attributes x and y. x corresponds to its horizontal position in a Cartesian Plane
(just a number) and y represents its initial and final height in the Plane (Array of length equal to 2)."""  ->
type VerticalWall <:Wall
  x :: Float64
  y :: Array{Float64,1}
end

@doc doc"""Type with attributes x and y. x corresponds to its horizontal extension in a Cartesian plane
(initial and final position -Array of length equal to 2- and y corresponds to its vertical position
(a number).""" ->
type HorizontalWall <:Wall
  x :: Array{Float64,1}
  y :: Float64

end


type VerticalHoleWall <:Wall
  x :: Float64
  y :: Array{Float64,1}  #Array of a length greater than the VerticalWall
end

end
