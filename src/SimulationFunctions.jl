include("./HardDiskBilliardModel.jl")
include("./HardDiskBilliardSimulation.jl")
importall HardDiskBilliardModel
importall HardDiskBilliardSimulation

VERSION < v"0.4-" && using Docile
using Lexicon
using DataStructures
using Compat
import Base.isless
importall Base.Collections

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
function simulation(; t_initial = 0, t_max = 1000, radiusdisk = 1.0, massdisk = 1.0, velocitydisk =1.0,massparticle = 1.0, velocityparticle =1.0,
                    Lx1 = 0., Ly1=0., size_x = 3., size_y = 3.,windowsize = 0.5)
  board, particle, t, time, pq = startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                                                 windowsize)


  particle_positions, particle_velocities =  createparticlelists(particle)

  #Solo voy a trabajar con la posición en x para analizar la difusión
  particle_xpositions = [particle_positions[1]]
  particle_xvelocities = [particle_velocities[1]]
  label = 0

  while(!isempty(pq))
    label += 1
    event = dequeue!(pq)
    validcollision = validatecollision(event, particle)

    if validcollision
      updatelabels(event,label)
      cell = get_cell(board, particle.numberofcell)
      move(particle,event.time -t)
      update_position_disk(cell,event.time)
      t = event.time
      cell.last_t = t
      push!(time,t)

      collision(event.dynamicobject,event.diskorwall, board)
      change_cell = false
      is_new_cell = !is_cell_in_board(board, particle)

      if particle.numberofcell != cell.numberofcell ###Si la partícula cambió de celda
        change_cell = true
        if is_new_cell
          cell = newcell!(board, particle, t)
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
                            Lx1 = 0., Ly1=0., size_x = 3., size_y = 3.,windowsize = 0.5)

  board, particle, t, time, pq = startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                                                 windowsize)

  particle_positions, particle_velocities =  createparticlelists(particle)
  disk_positions, disk_velocities = createdisklists(board)
  initialcell = front(board.cells) #La necesito para la animación
  label = 0
  delta_e = [0.]
  while(!isempty(pq))
    label += 1
    event = dequeue!(pq)
    validcollision = validatecollision(event, particle)
    if validcollision
      updatelabels(event,label)
      cell = get_cell(board, particle.numberofcell)
      move(particle,event.time -t)
      update_position_disk(cell,event.time)
      t = event.time
      cell.last_t = t
      push!(time,t)
      e1 = energy(event.dynamicobject,event.diskorwall)
      collision(event.dynamicobject,event.diskorwall, board)
      change_cell = false
      is_new_cell = !is_cell_in_board(board, particle)
      if particle.numberofcell != cell.numberofcell
        change_cell = true
        if is_new_cell
          cell = newcell!(board, particle, t)
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
                        Lx1 = 0., Ly1=0., size_x = 3., size_y = 3.,windowsize = 0.5)
  board, particle, t, time, pq = startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                                                 windowsize)

  @compat dict = Dict("disk0" => [0.0])
  label = 0

  while(!isempty(pq))
    label += 1
    event = dequeue!(pq)
    validcollision = validatecollision(event, particle)
    if validcollision
      updatelabels(event,label)
      cell = get_cell(board, particle.numberofcell)
      move(particle,event.time -t)
      update_position_disk(cell,event.time)
      t = event.time
      cell.last_t = t
      push!(time,t)
      collision(event.dynamicobject,event.diskorwall, board)

      change_cell = false
      is_new_cell = !is_cell_in_board(board, particle)
      if particle.numberofcell != cell.numberofcell ###Si la partícula cambió de celda
        change_cell = true
        if is_new_cell
          cell = newcell!(board, particle, t)
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
