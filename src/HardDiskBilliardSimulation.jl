include("./HardDiskBilliardModel.jl")

module HardDiskBilliardSimulation

VERSION < v"0.4-" && using Docile

importall HardDiskBilliardModel
using DataStructures
using Compat
import Base.isless
importall Base.Collections
export initialcollisions!, futurecollisions!, validatecollision, createparticlelists, createdisklists
export updatelabels, get_cell, energy, update_position_disk, updatedisklists!, updateparticlexlist!
export updateparticlelists!

#This allows to use the PriorityQueue providing a criterion to select the priority of an Event.
isless(e1::Event, e2::Event) = e1.time < e2.time


@doc """#initialcollisions!(board::Board,particle::Particle,t_initial::Real,t_max::Real,pq)
Calculates the initial feasible Events and push them into the PriorityQueue with label `prediction`
equal to 0."""->
function initialcollisions!(board::Board,particle::Particle,t_initial::Real,t_max::Real,pq::PriorityQueue)
  prediction = 0
  cell = get_cell(board, 0)
  enqueuecollisions!(pq, cell.disk,cell, t_initial, prediction, t_max)
  enqueuecollisions!(pq, particle, cell, t_initial, prediction, t_max)
  enqueuecollisions!(pq, particle, cell.disk, t_initial, prediction, t_max)
end

@doc """#enqueuecollisions!(pq::PriorityQueue,disk::Disk,cell::Cell, t_initial::Real, prediction::Int, t_max::Real)
Calculates the feasible events that might occur in a time less than t_max involving a disk and a cell, and push them into the PriorityQueue. """->
function enqueuecollisions!(pq::PriorityQueue,disk::Disk,cell::Cell, t_initial::Real, prediction::Int, t_max::Real)
  dt,k = dtcollision(disk,cell)
  if t_initial + dt < t_max
    enqueue!(pq,Event(t_initial+dt, disk, cell.walls[k],prediction),t_initial+dt)
  end
end

@doc """#enqueuecollisions!(pq::PriorityQueue,particle::Particle,cell::Cell, t_initial::Real, prediction::Int, t_max::Real)
Calculates the feasible events that might occur in a time less than t_max involving a particle and a cell, and push them into the PriorityQueue. """->
function enqueuecollisions!(pq::PriorityQueue,particle::Particle,cell::Cell, t_initial::Real, prediction::Int, t_max::Real)
  dt,k = dtcollision(particle,cell)
  if t_initial + dt < t_max
    enqueue!(pq,Event(t_initial+dt, particle, cell.walls[k],prediction),t_initial+dt)
  end
end

@doc """#enqueuecollisions!(pq::PriorityQueue,particle::Particle,disk::Disk, t_initial::Real, prediction::Int, t_max::Real)
Calculates the feasible events that might occur in a time less than t_max involving a particle and a disk, and push them into the PriorityQueue. """->
function enqueuecollisions!(pq::PriorityQueue,particle::Particle,disk::Disk, t_initial::Real, prediction::Int, t_max::Real)
  dt = dtcollision(particle,disk)
  if t_initial + dt < t_max
    enqueue!(pq,Event(t_initial+dt, particle, disk,prediction),t_initial+dt)
  end
end


@doc """#updatelabels(::Event,label)
Update the lastcollision label of a Disk and/or a Particle with the label
passed (see *simulation* function)"""->
function updatelabels(event::Event,label::Int)
  #Update both particle and disk
  function update(p::Particle,d::Disk)
    event.diskorwall.lastcollision = label
    event.dynamicobject.lastcollision = label
  end

  #update disk
  function update(d::Disk,w::Wall)
    event.dynamicobject.lastcollision = label
  end

  #update particle
  function update(p::Particle,w::Wall)
    event.dynamicobject.lastcollision = label
  end

  update(event.dynamicobject,event.diskorwall)
end









function updateparticlexlist!(particle_xpositions,particle_xvelocities, particle::Particle)
  push!(particle_xpositions, particle.r[1])
  push!(particle_xvelocities, particle.v[1])
end


function updateparticlelists!(particle_positions, particle_velocities,particle::Particle)
  for i in 1:2
    push!(particle_positions, particle.r[i])
    push!(particle_velocities, particle.v[i])
  end
end

function updatedisklists!(disk_positions, disk_velocities,cell::Cell)
  for i in 1:2
    push!(disk_positions,cell.disk.r[i])
    push!(disk_velocities,cell.disk.v[i])
  end
end

function createparticlelists(particle::Particle)
  particle_positions = [particle.r]
  particle_velocities = [particle.v]
  particle_positions, particle_velocities
end

@doc """#energy(::Particle,::Wall)
Returns the kinetic energy of a Particle"""->
function energy(particle::Particle,wall::Wall)
  particle.mass*dot(particle.v,particle.v)/2.
end

@doc """#energy(::Disk,::Wall)
Returns the kinetic energy of a Disk"""->
function energy(disk::Disk,wall::Wall)
  disk.mass*dot(disk.v,disk.v)/2.
end

@doc """#energy(::Disk,::Wall)
Returns the kinetic energy of a Disk"""->
function energy(disk::Disk)
  disk.mass*dot(disk.v,disk.v)/2.
end

@doc """#energy(::Particle,::Disk)
Returns the total kinetic energy of a particle and a Disk """->
function energy(particle::Particle,disk::Disk)
  disk.mass*dot(disk.v,disk.v)/2. + particle.mass*dot(particle.v,particle.v)/2.
end

function createdisklists(board::Board)
  disk_positions =  [front(board.cells).disk.r]
  disk_velocities = [front(board.cells).disk.v]
  disk_positions, disk_velocities
end

function futurecollisions!(event::Event,cell::Cell, particle::Particle, t_initial::Real,t_max::Real,pq::PriorityQueue,
                           prediction::Int, change_cell)
  #This function updates the PriorityQueue taking account that the current event was between a particle and a disk
  function future(particle::Particle, disk::Disk)
    enqueuecollisions!(pq, particle, cell, t_initial, prediction, t_max)
    enqueuecollisions!(pq, disk, cell, t_initial, prediction, t_max)
    enqueuecollisions!(pq, particle, disk, t_initial, prediction, t_max)
  end

  #This function updates the PriorityQueue taking account that the current event was between a particle and a wall
  function future(particle::Particle, wall::Wall)
    dt,k = dtcollision(particle,cell, wall)
    if t_initial + dt < t_max
      enqueue!(pq,Event(t_initial+dt, particle, cell.walls[k],prediction),t_initial+dt)
    end
    enqueuecollisions!(pq, particle, cell.disk, t_initial, prediction, t_max)
    if change_cell
      enqueuecollisions!(pq, cell.disk, cell, t_initial, prediction, t_max)
    end

  end

  #This function updates the PriorityQueue taking account that the current event was between a disk and a wall
  function future(disk::Disk, wall::Wall)
    enqueuecollisions!(pq, disk,cell, t_initial, prediction, t_max)
    enqueuecollisions!(pq, particle, disk, t_initial, prediction, t_max)
  end


  future(event.dynamicobject,event.diskorwall)
end

function validatecollision(event::Event, particle::Particle)
  validcollision = false
  function validate(d::Disk)
    if (event.prediction >= event.diskorwall.lastcollision)
      validcollision = true
    end
  end
  function validate(w::Wall)
    validcollision  = true
  end

  if event.prediction >= event.dynamicobject.lastcollision
    validate(event.diskorwall)
  end

  validcollision
end

function update_x_disk(disk,Lx1,size_x)
  ###Ver qué pasa si son exactamente iguales
  bx1 = Lx1 + disk.radius
  bx2 = Lx1 + size_x - disk.radius
  width = bx2 - bx1
  if disk.r[1] >= bx2
    distance = disk.r[1] - bx2
    k = mod(distance,width)
    if !iseven(int(fld(distance, width)))
      disk.r[1] = bx1 + k
    else
      disk.r[1] = bx2 - k
    end
  else
    distance = abs(disk.r[1] - bx1)
    k = mod(distance,width)
    if !iseven(int(fld(distance, width)))
      disk.r[1] = bx2 - k
    else
      disk.r[1] = bx1 + k
    end
  end
  disk.r
end


function update_y_disk(disk,Ly1,size_y)
  ###Ver qué pasa si son exactamente iguales
  by1 = Ly1 + disk.radius
  by2 = Ly1 + size_y - disk.radius
  height = by2 - by1
  if disk.r[2] >= by2
    distance = disk.r[2] - by2
    k = mod(distance,height)
    if !iseven(int(fld(distance, height)))
      disk.r[2] = by1 + k
    else
      disk.r[2] = by2 - k
    end
  else
    distance = abs(disk.r[2] - by1)
    k = mod(distance,height)
    if !iseven(int(fld(distance, height)))
      disk.r[2] = by2 - k
    else
      disk.r[2] = by1 + k
    end
  end
  disk.r
end


function update_position_disk(cell, t)
  delta_t = t - cell.last_t
  move(cell.disk,delta_t)
  Lx1 = cell.walls[2].x[1]
  Lx2 = cell.walls[2].x[2]
  Ly1 = cell.walls[2].y
  Ly2 = cell.walls[3].y
  size_y = abs(Ly2 - Ly1)
  size_x = abs(Lx2 - Lx1)
  update_y_disk(cell.disk,Ly1,size_y)
  update_x_disk(cell.disk,Lx1,size_x)
end

@doc """Extract the cell from the board with the index passed. By convention 0 is the index for the initial cell, and
it goes growing negatively at left and positively at right."""->
function get_cell(board::Board, numberofcell::Int)
  deque = board.cells
  @assert -1023 <= numberofcell <= 1023
  if numberofcell < 0
    cell = deque.head.data[end+numberofcell+1]
  else
    cell = deque.rear.data[numberofcell+1]
  end
  cell
end




end
