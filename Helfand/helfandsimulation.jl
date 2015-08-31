push!(LOAD_PATH,"../src/")
push!(LOAD_PATH,"../myDataStructures/")

using HardDiskBilliardSimulation
using HardDiskBilliardModel
using MyCollections

function deltaH(event::Event, helfand, previous_energy, time, event_time, x_particle)

  function deltaHelfand(dynamicobject::Disk, diskorwall::Wall, helfand,  previous_energy, time, event_time, x_particle)
    helfand, time, x_particle
  end

  function deltaHelfand(dynamicobject::Particle, diskorwall::Wall,  helfand,  previous_energy, time, event_time, x_particle)
    helfand, time, x_particle
  end

  function deltaHelfand(dynamicobject::Particle, diskorwall::Disk, helfand,  previous_energy, time, event_time, x_particle)
    deltah = helfand[end] + (-event.diskorwall.r[1] + event.dynamicobject.r[1])*(energy(event.dynamicobject)-previous_energy) + (dynamicobject.r[1] - x_particle[end])*previous_energy
    push!(helfand, deltah)
    push!(time, event_time)
    push!(x_particle, dynamicobject.r[1])
    helfand, time, x_particle
  end

  deltaHelfand(event.dynamicobject, event.diskorwall, helfand,  previous_energy, time, event_time, x_particle)

end

function energy(particle::Particle)
  particle.mass*dot(particle.v,particle.v)/2.
end

function energy(disk::Disk)
  disk.mass*dot(disk.v,disk.v)/2.
end


function helfandsimulation(parameters)

  t_initial  = parameters["t_initial"]
  t_max  = parameters["t_max"]
  radiusdisk =  parameters["radiusdisk"]
  massdisk  = parameters["massdisk"]
  Lx1 = parameters["Lx1"]
  Ly1 = parameters["Ly1"]
  windowsize = parameters["windowsize"]
  massparticle = parameters["massparticle"]
  size_x = parameters["size_x"]
  size_y = parameters["size_y"]
  velocityparticle = parameters["velocityparticle"]
  temperature = parameters["temperature"]

  board, particle, t, time, pq = startsimulation(t_initial, t_max, radiusdisk, massdisk, temperature, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                                                 windowsize)



  event_counter = 0
  helfand_0 = energy(particle)*particle.r[1]
  helfand = [helfand_0]

  x_particle = [particle.r[1]]

  while(!isempty(pq))

    event_counter += 1
    event, event_time  = dequeue!(pq)
    validcollision = validatecollision(event, particle)

    if validcollision
      updatelabels(event,event_counter)
      cell = get_cell(board, particle.numberofcell)
      move(particle,event_time -t)
      update_position_disk(cell,event_time)
      e1 = energy(event.dynamicobject)
      t = event_time
      cell.last_t = t
      #      push!(time,t)
      collision(event.dynamicobject,event.diskorwall, board)

      helfand, time, x_particle = deltaH(event, helfand, e1, time, event_time, x_particle)



      change_cell = false
      is_new_cell = !is_cell_in_board(board, particle)
      if particle.numberofcell != cell.numberofcell
        change_cell = true
        if is_new_cell
          cell = newcell!(board, particle, t, temperature)
        else
          cell = get_cell(board,particle.numberofcell)
          update_position_disk(cell, t)
          cell.last_t = t
        end
      end

      futurecollisions!(event, cell, particle, t,t_max,pq, event_counter, change_cell)
    end
  end
  # push!(time, t_max)
  helfand, time


end
