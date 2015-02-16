module Objects

VERSION < v"0.4-" && using Docile

export Wall, Disk, Object, DynamicObject
export VerticalWall, HorizontalWall, Event, Cell, VerticalSharedWall, Particle, Board, Vertical

abstract Object
abstract DynamicObject <: Object
abstract Wall <: Object
abstract Vertical <: Wall



type Particle <: DynamicObject
    r::Array{Float64,1}
    v::Array{Float64,1}
    mass::Float64
    numberofcell::Int
    lastcollision::Int
end

Particle(r,v) = Particle(r,v,1.,1,0)  #Default values: mass equal to 1; numberofcell: 1; lastcollision:0.
Particle(r,v,mass) = Particle(r,v,mass,1,0)

type Disk <: DynamicObject
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
    numberofcell::Int
end

#Cell(walls,label) = Cell(walls,label,Disk([-100.,-100.],[0.,0.],0.))

type Board
    cells::Vector{Cell}
end

@doc doc"""Type with attributes x and y. x corresponds to its horizontal position in a Cartesian Plane
(just a number) and y represents its initial and final height in the Plane (Array of length equal to 2)."""  ->
immutable VerticalWall <: Vertical
  x :: Float64
  y :: Array{Float64,1}
end

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
  sharedcells::(Int,Int)
end

@doc doc"""Type with attributes time, collider1, collider2 and label. The label makes reference to the cycle
within the main loop in which the event was predicted (see simulacionanimada in main.jl)."""->
type Event
    time :: Number
    referenceobject::DynamicObject
    diskorwall ::Object
    whenwaspredicted:: Int
end


end
