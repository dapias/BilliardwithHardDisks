module Objects

VERSION < v"0.4-" && using Docile
using Lexicon
using DataStructures

export Wall, Disk, DynamicObject
export HorizontalWall, Event, Cell, VerticalSharedWall, Particle, Board, Vertical

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


end
