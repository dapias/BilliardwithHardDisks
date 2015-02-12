module Objects

VERSION < v"0.4-" && using Docile

export Object, Wall, Disk, VerticalWall, HorizontalWall, Event

abstract Object
abstract Wall <: Object

@doc doc"""Type with attributes position(r), velocity, radius, mass and label. Both position and velocity
are vectors. The label attribute corresponds to the cycle within the main loop in which the Disk suffered
its last collision (see simulacionanimada in *main.jl*) """->
type Disk <:Object
  r::Array{Float64,1}
  v::Array{Float64,1}
  radius::Float64
  mass::Float64
  lastcollision ::Int
end

Disk(r,v,radius) = Disk(r,v,radius,1.0,0) #Fixed mass of 1.0 and label equal to 0 (by default)
Disk(r,v,radius, mass) = Disk(r,v,radius, mass ,0) #Label equal to 0 (by default)

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

#gf,msfklmgflmgklm