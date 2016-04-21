include("./HardDiskBilliardModel.jl")
include("../myDataStructures/MyCollections.jl")
#push!(LOAD_PATH,"../myDataStructures/")

#using DataStructures


module HardDiskBilliardSimulation

VERSION < v"0.4-" && using Docile


importall HardDiskBilliardModel
import DataStructures.Deque, DataStructures.push!, DataStructures.unshift!, DataStructures.front, DataStructures.back, MyCollections.PriorityQueue, MyCollections.enqueue!, MyCollections.dequeue!
using Compat
export simulation, animatedsimulation, heatsimulation


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
    enqueue!(pq,Event( disk, cell.walls[k],prediction),t_initial+dt)
  end
end

@doc """#enqueuecollisions!(pq::PriorityQueue,particle::Particle,cell::Cell, t_initial::Real, prediction::Int, t_max::Real)
Calculates the feasible events that might occur in a time less than t_max involving a particle and a cell, and push them into the PriorityQueue. """->
function enqueuecollisions!(pq::PriorityQueue,particle::Particle,cell::Cell, t_initial::Real, prediction::Int, t_max::Real)
  dt,k = dtcollision(particle,cell)
  if t_initial + dt < t_max
    enqueue!(pq,Event( particle, cell.walls[k],prediction),t_initial+dt)
  end
end

@doc """#enqueuecollisions!(pq::PriorityQueue,particle::Particle,disk::Disk, t_initial::Real, prediction::Int, t_max::Real)
Calculates the feasible events that might occur in a time less than t_max involving a particle and a disk, and push them into the PriorityQueue. """->
function enqueuecollisions!(pq::PriorityQueue,particle::Particle,disk::Disk, t_initial::Real, prediction::Int, t_max::Real)
  dt = dtcollision(particle,disk)
  if t_initial + dt < t_max
    enqueue!(pq,Event( particle, disk,prediction),t_initial+dt)
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
                           prediction::Int, change_cell::Bool)
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
      enqueue!(pq,Event( particle, cell.walls[k],prediction),t_initial+dt)
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
  Lx1::Float64; Ly1::Float64; Lx2::Float64;Ly2::Float64; size_x::Float64; size_y::Float64
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
  cell::Cell{Float64}
  if numberofcell < 0
    cell = deque.head.data[end+numberofcell+1]
  else
    cell = deque.rear.data[numberofcell+1]
  end
  cell
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
                                               massparticle, velocityparticle, windowsize, t_initial)

  pq = PriorityQueue{Event,Float64}()
  enqueue!(pq,Event(Particle([0.,0.],[0.,0.],1.0,0),Disk([0.,0.],[0.,0.],1.0,1.0,0), 0),0.) #Just to init pq
  initialcollisions!(board,particle,t_initial,t_max,pq)
  event, t = dequeue!(pq) #It's deleted the event at time 0.0
  time = [t]
  return board, particle, t, time, pq
end

@doc """#simulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,windowsize)
Contains the main loop of the project. The PriorityQueue is filled at each step with Events associated
to a DynamicObject; and the element with the highest physical priority (lowest time) is removed
from the Queue and ignored if it is physically meaningless. The loop goes until the last Event is removed
from the Data Structure, which is delimited by the maximum time(t_max). Just to clarify Lx1 and Ly1 are the coordiantes
(Lx1,Ly1) of the left bottom corner of the initial cell.

Returns `board, particle, particle_positions, particle_velocities, time`"""->
function simulation(; t_initial = 0, t_max = 1000, radiusdisk = 1.0, massdisk = 1.0, velocitydisk =1.0,massparticle = 1.0, velocityparticle =1.0,
                    Lx1 = 0., Ly1=0., size_x = 3., size_y = 3.,windowsize = 0.5, vnewdisk = 0.0)
  board, particle, t, time, pq = startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                                                 windowsize)


  particle_positions, particle_velocities =  createparticlelists(particle)

  #Solo voy a trabajar con la posición en x para analizar la difusión
  particle_xpositions = [particle_positions[1]]
  particle_xvelocities = [particle_velocities[1]]
  label = 0

  while(!isempty(pq))
    label += 1
    event, event_time = dequeue!(pq)
    validcollision = validatecollision(event, particle)

    if validcollision
      updatelabels(event,label)
      cell = get_cell(board, particle.numberofcell)
      move(particle,event_time - t)
      update_position_disk(cell,event_time)
      t = event_time
      cell.last_t = t
      push!(time,t)

      collision(event.dynamicobject,event.diskorwall, board)
      change_cell = false
      is_new_cell = !is_cell_in_board(board, particle)
      if particle.numberofcell != cell.numberofcell ###Si la partícula cambió de celda
        change_cell = true
        if is_new_cell
          cell = newcell!(board, particle, t, vnewdisk)
        else
          cell = get_cell(board,particle.numberofcell)
          update_position_disk(cell, t)
          cell.last_t = t
        end
      end

      updateparticlexlist!(particle_xpositions, particle_xvelocities, particle)
      futurecollisions!(event, cell, particle, t,t_max,pq, label, change_cell)
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
function animatedsimulation(; t_initial = 0, t_max = 1000, radiusdisk = 1.0, massdisk = 1.0, velocitydisk =1.0,massparticle = 1.0, velocityparticle =1.0,
                            Lx1 = 0., Ly1=0., size_x = 3., size_y = 3.,windowsize = 0.5, vnewdisk = 0.0)

  board, particle, t, time, pq = startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                                                 windowsize)

  particle_positions, particle_velocities =  createparticlelists(particle)
  disk_positions, disk_velocities = createdisklists(board)
  initialcell = front(board.cells) #La necesito para la animación
  label = 0
  delta_e = [0.]
  while(!isempty(pq))
    label += 1
    event, event_time  = dequeue!(pq)
    validcollision = validatecollision(event, particle)
    if validcollision
      updatelabels(event,label)
      cell = get_cell(board, particle.numberofcell)
      move(particle,event_time -t)
      update_position_disk(cell,event_time)
      t = event_time

      cell.last_t = t
      push!(time,t)
      e1 = energy(event.dynamicobject,event.diskorwall)
      collision(event.dynamicobject,event.diskorwall, board)
      change_cell = false
      is_new_cell = !is_cell_in_board(board, particle)
      if particle.numberofcell != cell.numberofcell
        change_cell = true
        if is_new_cell
          cell = newcell!(board, particle, t, vnewdisk)
        else
          cell = get_cell(board,particle.numberofcell)
          update_position_disk(cell, t)
          cell.last_t = t
        end
      end
      e2 = energy(event.dynamicobject,event.diskorwall)
      push!(delta_e, e2 - e1)
      updateparticlelists!(particle_positions, particle_velocities,particle)
      updatedisklists!(disk_positions, disk_velocities, cell)

      futurecollisions!(event, cell, particle, t,t_max,pq, label, change_cell)
    end
  end
  push!(time, t_max)
  board, particle, particle_positions, particle_velocities, time, disk_positions, disk_velocities, delta_e, initialcell.disk
end



@doc """#heatsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,windowsize)
Implements the simulation main loop but returns a dictionary with the energies of the disks at time t_max"""->
function heatsimulation(; t_initial = 0, t_max = 1000, radiusdisk = 1.0, massdisk = 1.0, velocitydisk =1.0,massparticle = 1.0, velocityparticle =1.0,
                        Lx1 = 0., Ly1=0., size_x = 3., size_y = 3.,windowsize = 0.5, vnewdisk = 0.0)
  board, particle, t, time, pq = startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                                                 windowsize)

  @compat dict = Dict("disk0" => [0.0])
  label = 0

  while(!isempty(pq))
    label += 1
    event, event_time = dequeue!(pq)
    validcollision = validatecollision(event, particle)
    if validcollision
      updatelabels(event,label)
      cell = get_cell(board, particle.numberofcell)
      move(particle,event_time -t)
      update_position_disk(cell,event_time)
      t = event_time
      cell.last_t = t
      push!(time,t)
      collision(event.dynamicobject,event.diskorwall, board)

      change_cell = false
      is_new_cell = !is_cell_in_board(board, particle)
      if particle.numberofcell != cell.numberofcell ###Si la partícula cambió de celda
        change_cell = true
        if is_new_cell
          cell = newcell!(board, particle, t, vnewdisk)
          dict["disk$(cell.numberofcell)"] = [0.0]
        else
          cell = get_cell(board,particle.numberofcell)
          update_position_disk(cell, t)
          cell.last_t = t
        end
      end

      futurecollisions!(event, cell, particle, t,t_max,pq, label, change_cell)
    end
  end

  for cell in board.cells
    dict["disk$(cell.numberofcell)"][1] = energy(cell.disk)
  end

  push!(time,t_max)
  dict
end


end
