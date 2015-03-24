include("./HardDiskBilliardModel.jl")

module HardDiskBilliardSimulation

#VERSION < v"0.4-" && using Docile

importall HardDiskBilliardModel
using DataStructures
import Base.isless
importall Base.Collections
export simulation, animatedsimulation, heatsimulation

#This allows to use the PriorityQueue providing a criterion to select the priority of an Event.
isless(e1::Event, e2::Event) = e1.time < e2.time


@doc """#initialcollisions!(board::Board,particle::Particle,t_initial::Real,t_max::Real,pq)
Calculates the initial feasible Events and push them into the PriorityQueue with label `whenwaspredicted`
equal to 0."""->
function initialcollisions!(board::Board,particle::Particle,t_initial::Real,t_max::Real,pq::PriorityQueue)
  whenwaspredicted = 0
  for cell in board.cells
    enqueuecollisions!(pq, cell.disk,cell, t_initial, whenwaspredicted, t_max)
    enqueuecollisions!(pq, particle, cell, t_initial, whenwaspredicted, t_max)
    enqueuecollisions!(pq, particle, cell.disk, t_initial, whenwaspredicted, t_max)
  end
end

@doc """#enqueuecollisions!(pq::PriorityQueue,disk::Disk,cell::Cell, t_initial::Real, whenwaspredicted::Int, t_max::Real)
Calculates the feasible events that might occur in a time less than t_max involving a disk and a cell, and push them into the PriorityQueue. """->
function enqueuecollisions!(pq::PriorityQueue,disk::Disk,cell::Cell, t_initial::Real, whenwaspredicted::Int, t_max::Real)
  dt,k = dtcollision(disk,cell)
  if t_initial + dt < t_max
    enqueue!(pq,Event(t_initial+dt, disk, cell.walls[k],whenwaspredicted),t_initial+dt)
  end
end

@doc """#enqueuecollisions!(pq::PriorityQueue,particle::Particle,cell::Cell, t_initial::Real, whenwaspredicted::Int, t_max::Real)
Calculates the feasible events that might occur in a time less than t_max involving a particle and a cell, and push them into the PriorityQueue. """->
function enqueuecollisions!(pq::PriorityQueue,particle::Particle,cell::Cell, t_initial::Real, whenwaspredicted::Int, t_max::Real)
  dt,k = dtcollision(particle,cell)
  if t_initial + dt < t_max
    enqueue!(pq,Event(t_initial+dt, particle, cell.walls[k],whenwaspredicted),t_initial+dt)
  end
end

@doc """#enqueuecollisions!(pq::PriorityQueue,particle::Particle,disk::Disk, t_initial::Real, whenwaspredicted::Int, t_max::Real)
Calculates the feasible events that might occur in a time less than t_max involving a particle and a disk, and push them into the PriorityQueue. """->
function enqueuecollisions!(pq::PriorityQueue,particle::Particle,disk::Disk, t_initial::Real, whenwaspredicted::Int, t_max::Real)
  dt = dtcollision(particle,disk)
  if t_initial + dt < t_max
    enqueue!(pq,Event(t_initial+dt, particle, disk,whenwaspredicted),t_initial+dt)
  end
end


@doc """#futurecollisions!(::Event,::Board, t_initial::Real,t_max::Real,::PriorityQueue,
whenwaspredicted::Int,:: Particle, isanewcell)
Updates the PriorityQueue pushing into it all the feasible Events that can occur after a valid collision"""->
function futurecollisions!(event::Event,board::Board, t_initial::Real,t_max::Real,pq::PriorityQueue,
                           whenwaspredicted::Int,particle::Particle, isanewcell)
  ##This loop allows to analyze the cell in which the particle is located.
  cell = nothing
  for c in board.cells
    if c.numberofcell == event.dynamicobject.numberofcell
      cell = c
      break
    end
  end

  #This function updates the PriorityQueue taking account that the current event was between a particle and a disk
  function future(particle::Particle, disk::Disk)
    enqueuecollisions!(pq, particle, cell, t_initial, whenwaspredicted, t_max)
    enqueuecollisions!(pq, disk,cell, t_initial, whenwaspredicted, t_max)

  end

  #This function updates the PriorityQueue taking account that the current event was between a particle and a wall
  function future(particle::Particle, wall::Wall)
    dt,k = dtcollision(particle,cell, wall)
    if t_initial + dt < t_max
      enqueue!(pq,Event(t_initial+dt, particle, cell.walls[k],whenwaspredicted),t_initial+dt)
    end
    enqueuecollisions!(pq, particle, cell.disk, t_initial, whenwaspredicted, t_max)

    #If the wall was a VerticalSharedWall that implied to create a new cell, this is invoked
    if isanewcell == true
      enqueuecollisions!(pq, cell.disk,cell, t_initial, whenwaspredicted, t_max)
    end
  end

  #This function updates the PriorityQueue taking account that the current event was between a disk and a wall
  function future(disk::Disk, wall::Wall)
    enqueuecollisions!(pq, disk,cell, t_initial, whenwaspredicted, t_max)
    if  is_particle_in_cell(particle,cell)
      enqueuecollisions!(pq, particle, disk, t_initial, whenwaspredicted, t_max)
    end
  end

  #Here, the function future is invoked
  future(event.dynamicobject,event.diskorwall)
end

function is_particle_in_cell(p::Particle,c::Cell)
  contain = false
  if c.numberofcell == p.numberofcell
    contain = true
  end
  contain
end


@doc """#validatecollision(event::Event)
Returns true if the event was predicted after the last collision of the Particle and/or of the Disk took place"""->
function validatecollision(event::Event)
  validcollision = false
  function validate(d::Disk)
    if (event.whenwaspredicted >= event.diskorwall.lastcollision)
      validcollision = true
    end
  end
  function validate(w::Wall)
    validcollision  = true
  end

  if event.whenwaspredicted >= event.dynamicobject.lastcollision
    validate(event.diskorwall)
  end
  validcollision
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


@doc """#move(:Board,::Particle,delta_t::Real)
Update the position of all the objects on the board, including the particle, by moving them
an interval of time delta_t"""->
function move(board::Board,particle::Particle,delta_t::Real)
  for cell in board.cells
    move(cell.disk,delta_t)
  end
  move(particle,delta_t)
end


@doc """#startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1,
                         size_x, size_y, windowsize)
Initialize the important variables to perform the simulation. Returns `board, particle, t, time, pq`. With t equals to t_initial
and time an array initialized with the t value.
                        """->
function startsimulation(t_initial::Real, t_max::Real, radiusdisk::Real, massdisk::Real, velocitydisk::Real,
                         massparticle::Real, velocityparticle::Real, Lx1::Real, Ly1::Real,
                         size_x::Real, size_y::Real, windowsize::Real)
  board, particle = create_board_with_particle(Lx1, Ly1,size_x,size_y,radiusdisk, massdisk, velocitydisk,
                                               massparticle, velocityparticle, windowsize)
  pq = PriorityQueue()
  enqueue!(pq,Event(0., Particle([0.,0.],[0.,0.],1.0,0),Disk([0.,0.],[0.,0.],1.0,1.0,0), 0),0.) #Just to init pq
  initialcollisions!(board,particle,t_initial,t_max,pq)
  event = dequeue!(pq) #It's deleted the event at time 0.0
  t = event.time
  time = [event.time]
  return board, particle, t, time, pq
end






@doc """#simulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,windowsize)
Contains the main loop of the project. The PriorityQueue is filled at each step with Events associated
to a DynamicObject; and the element with the highest physical priority (lowest time) is removed
from the Queue and ignored if it is physically meaningless. The loop goes until the last Event is removed
from the Data Structure, which is delimited by the maximum time(t_max). Just to clarify Lx1 and Ly1 are the coordiantes
(Lx1,Ly1) of the left bottom corner of the initial cell.

Returns `board, particle, particle_positions, particle_velocities, time`"""->
function simulation(; t_initial = 0, t_max = 100, radiusdisk = 1.0, massdisk = 1.0, velocitydisk =1.0,massparticle = 1.0, velocityparticle =1.0,
                    Lx1 = 0., Ly1=0., size_x = 3., size_y = 3.,windowsize = 0.5)


  board, particle, t, time, pq = startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                                                 windowsize)


  particle_positions, particle_velocities =  createparticlelists(particle)


  #Solo voy a trabajar con la posición en x para analizar la difusión
  particle_xpositions = [particle_positions[1]]
  particle_xvelocities = [particle_velocities[1]]
  #

  label = 0
  while(!isempty(pq))
    label += 1
    event = dequeue!(pq)
    validcollision = validatecollision(event)
    if validcollision
      updatelabels(event,label)
      move(board,particle,event.time-t)
      t = event.time
      push!(time,t)
      new_cell = collision(event.dynamicobject,event.diskorwall, board) #Sólo es un booleano (= true) en el caso de que se cree una nueva celda
      e2 = energy(event.dynamicobject,event.diskorwall)
      #updateparticlelists!(particle_positions, particle_velocities,particle)
      updateparticlexlist!(particle_xpositions, particle_xvelocities, particle)
      futurecollisions!(event, board, t,t_max,pq, label, particle, new_cell)
    end
  end

  push!(time, t_max)
  board, particle_xpositions, particle_xvelocities, time
end


@doc doc"""#animatedsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,windowsize)
Implements the simulation main loop but adds the storing of the back and front disk positions and velocities, together
with a delta of energy for each collision.

Returns `board, particle, particle_positions, particle_velocities, time, disk_positions_front,
disk_velocities_front, initialcell.disk, disk_positions_back,disk_velocities_back, delta_e`"""->
function animatedsimulation(; t_initial = 0, t_max = 100, radiusdisk = 1.0, massdisk = 1.0, velocitydisk =1.0,massparticle = 1.0, velocityparticle =1.0,
                            Lx1 = 0., Ly1=0., size_x = 3., size_y = 3.,windowsize = 0.5)
  board, particle, t, time, pq = startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                                                 windowsize)
  particle_positions, particle_velocities =  createparticlelists(particle)
  disk_positions_front, disk_velocities_front, disk_positions_back, disk_velocities_back = creatediskslists(board)
  initialcell = front(board.cells)
  label = 0
  delta_e = [0.]
  while(!isempty(pq))
    label += 1
    event = dequeue!(pq)
    validcollision = validatecollision(event)
    ##si se crea una nueva celda cambio el estatus de las variables
    if validcollision
      updatelabels(event,label)
      move(board,particle,event.time-t)
      t = event.time
      push!(time,t)
      e1 = energy(event.dynamicobject,event.diskorwall)
      new_cell = collision(event.dynamicobject,event.diskorwall, board)  #Sólo es un booleano (= true) en el caso de que se cree una nueva celda
      e2 = energy(event.dynamicobject,event.diskorwall)
      push!(delta_e, e2 - e1)
      updateparticlelists!(particle_positions, particle_velocities,particle)
      updatediskslists!(disk_positions_front, disk_velocities_front,front(board.cells))
      updatediskslists!(disk_positions_back,disk_velocities_back,back(board.cells))
      futurecollisions!(event, board, t,t_max,pq, label, particle, new_cell)
    end
  end
  push!(time, t_max)
  board, particle, particle_positions, particle_velocities, time, disk_positions_front, disk_velocities_front, initialcell.disk, disk_positions_back,disk_velocities_back, delta_e
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

function updatediskslists!(disk_positions, disk_velocities,cell::Cell)
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

function creatediskslists(board::Board)
  disk_positions_front =  [front(board.cells).disk.r]
  disk_velocities_front = [front(board.cells).disk.v]
  disk_positions_back =  [back(board.cells).disk.r]
  disk_velocities_back = [back(board.cells).disk.v]
  disk_positions_front, disk_velocities_front, disk_positions_back, disk_velocities_back
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

function heatsimulation(; t_initial = 0, t_max = 100, radiusdisk = 1.0, massdisk = 1.0, velocitydisk =1.0,massparticle = 1.0, velocityparticle =1.0,
                        Lx1 = 0., Ly1=0., size_x = 3., size_y = 3.,windowsize = 0.5)

  board, particle, t, time, pq = startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                                                 windowsize)


  particle_positions, particle_velocities =  createparticlelists(particle)

  disk0_energy = float64([energy(front(board.cells).disk)])

  dict = Dict("disk0" => disk0_energy)


  #Solo voy a trabajar con la posición en x para analizar la difusión
  particle_xpositions = [particle_positions[1]]
  particle_xvelocities = [particle_velocities[1]]
  #

  label = 0
  while(!isempty(pq))
    label += 1
    event = dequeue!(pq)
    validcollision = validatecollision(event)
    if validcollision
      updatelabels(event,label)
      move(board,particle,event.time-t)
      t = event.time
      push!(time,t)
      new_cell = collision(event.dynamicobject,event.diskorwall, board) #Sólo es un booleano (= true) en el caso de que se cree una nueva celda
      if new_cell == true
        dict["disk$(event.dynamicobject.numberofcell)"] = float64([0.0])
      end

      #            for k in board.cells
      #                push!(dict["disk$(k.disk.numberofcell)"],energy(k.disk))
      #            end

      #updateparticlelists!(particle_positions, particle_velocities,particle)
      updateparticlexlist!(particle_xpositions, particle_xvelocities, particle)
      futurecollisions!(event, board, t,t_max,pq, label, particle, new_cell)
    end
  end

  for k in board.cells
    dict["disk$(k.disk.numberofcell)"][1] = energy(k.disk)
  end

  push!(time, t_max)  #Note that the positions of the disks don't correspond exactly with the position
  # at time t_max, but the difference is not important for what we want
  dict
end


function createdisklists(board::Board)
  disk_positions =  [front(board.cells).disk.r]
  disk_velocities = [front(board.cells).disk.v]
  disk_positions, disk_velocities
end

function move(cell::Cell,particle::Particle,delta_t::Real)
  move(cell.disk,delta_t)
  move(particle,delta_t)
end

function futurecollisions!(event::Event,cell::Cell, particle::Particle, t_initial::Real,t_max::Real,pq::PriorityQueue,
                           whenwaspredicted::Int)

  #This function updates the PriorityQueue taking account that the current event was between a particle and a disk
  function future(particle::Particle, disk::Disk)
    enqueuecollisions!(pq, particle, cell, t_initial, whenwaspredicted, t_max)
    enqueuecollisions!(pq, disk,cell, t_initial, whenwaspredicted, t_max)

  end

  #This function updates the PriorityQueue taking account that the current event was between a particle and a wall
  function future(particle::Particle, wall::Wall)
    dt,k = dtcollision(particle,cell, wall)
    if t_initial + dt < t_max
      enqueue!(pq,Event(t_initial+dt, particle, cell.walls[k],whenwaspredicted),t_initial+dt)
    end
    enqueuecollisions!(pq, particle, cell.disk, t_initial, whenwaspredicted, t_max)

    #If the wall was a VerticalSharedWall that implied to create a new cell, this is invoked
    if isanewcell == true
      enqueuecollisions!(pq, cell.disk,cell, t_initial, whenwaspredicted, t_max)
    end
  end

  #This function updates the PriorityQueue taking account that the current event was between a disk and a wall
  function future(disk::Disk, wall::Wall)
    enqueuecollisions!(pq, disk,cell, t_initial, whenwaspredicted, t_max)
    if  is_particle_in_cell(particle,cell)
      enqueuecollisions!(pq, particle, disk, t_initial, whenwaspredicted, t_max)
    end
  end

  #Here, the function future is invoked
  future(event.dynamicobject,event.diskorwall)
end

function is_particle_in_cell(p::Particle,c::Cell)
  contain = false
  if c.numberofcell == p.numberofcell
    contain = true
  end
  contain
end


function validatecoll(event::Event, particle::Particle)
  validcollision = false
  function validate(d::Disk)
    if (event.whenwaspredicted >= event.diskorwall.lastcollision)
      validcollision = true
    end
  end
  function validate(w::Wall)
    validcollision  = true
  end

  if event.whenwaspredicted >= event.dynamicobject.lastcollision
    validate(event.diskorwall)
  end

  if event.dynamicobject.numberofcell !== particle.numberofcell
    validcollision = false
  end

  validcollision
end


function update_position_disk(cell, t)
  delta_t = t - cell.last_t
  move(disk,delta_t)
  Lx1 = cell.walls[1][1]
  Lx2 = cell.walls[4][1]
  Ly1 = cell.walls[2][2]
  Ly2 = cell.walls[3][3]
  size_y = Ly2 - Ly1
  size_x = Lx2 - Lx1
  update_y_disk(disk,Ly1,size_y)
  update_x_disk(disk,Lx1,size_x)
end

function simplifiedsimulation(; t_initial = 0, t_max = 100, radiusdisk = 1.0, massdisk = 1.0, velocitydisk =1.0,massparticle = 1.0, velocityparticle =1.0,
                              Lx1 = 0., Ly1=0., size_x = 3., size_y = 3.,windowsize = 0.5)
  board, particle, t, time, pq = startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                                                 windowsize)
  particle_positions, particle_velocities =  createparticlelists(particle)
  disk_positions, disk_velocities = createdisklists(board)
  initialcell = front(board.cells)
  label = 0
  delta_e = [0.]
  while(!isempty(pq))
    label += 1
    event = dequeue!(pq)
    validcollision = validatecoll(event, particle)
    ##si se crea una nueva celda cambio el estatus de las variables
    if validcollision
      updatelabels(event,label)
      cell = get_cell(board, particle.numberofcell)
      move(cell,particle,event.time-t)
      t = event.time
      push!(time,t)
      e1 = energy(event.dynamicobject,event.diskorwall)
      collision(event.dynamicobject,event.diskorwall, board)
      is_new_cell = is_cell_in_board(board, particle)
      if !is_new_cell
        cell =new_cell!(board, particle)
      else
        cell = get_cell(board,particle.numberofcell)
        update_position_disk!(cell, t)
      end

      e2 = energy(event.dynamicobject,event.diskorwall)
      push!(delta_e, e2 - e1)
      updateparticlelists!(particle_positions, particle_velocities,particle)
      updatediskslists!(disk_positions, disk_velocities, cell)
      futurecollisions!(event, cell, particle, t,t_max,pq, label)
    end
  end
  push!(time, t_max)
  board, particle, particle_positions, particle_velocities, time, disk_positions_front, disk_velocities_front, initialcell.disk, disk_positions_back,disk_velocities_back, delta_e
end





end
