push!(LOAD_PATH,"../src/")
push!(LOAD_PATH,"../myDataStructures/")

using HardDiskBilliardSimulation
using HardDiskBilliardModel
using MyCollections
using Docile


@doc "Returns the escape-time and the energy of the particle that leaves the cell."->
function residencetime(; t_initial = 0., t_max = 100., radiusdisk = 1.0, massdisk = 1.0, velocitydisk =1.0,massparticle = 1.0, velocityparticle =1.0,
                    Lx1 = 0., Ly1=0., size_x = 3., size_y = 3.,windowsize = 0.5, vnewdisk=0.)

  board, particle, t, time, pq = HardDiskBilliardSimulation.startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                                                 windowsize)

  label = 0
  condicion = true

  while(condicion && !isempty(pq))
    label += 1
    event, event_time = dequeue!(pq)
    validcollision = HardDiskBilliardSimulation.validatecollision(event, particle)

    if validcollision
      #En este bloque se considera el movimiento de la celda actual.

      HardDiskBilliardSimulation.updatelabels(event,label)
      cell = HardDiskBilliardSimulation.get_cell(board, particle.numberofcell)
      HardDiskBilliardSimulation.move(particle,event_time - t)
      HardDiskBilliardSimulation.update_position_disk(cell,event_time)
      cell.last_t = t = event_time

      #Con esta función, aparte de actualizar las velocidades, se ve si la partícula cambia de número de celda.
      collision(event.dynamicobject,event.diskorwall, board)

      #Si cambia de celda rompe el loop.
      condicion = particle.numberofcell == cell.numberofcell

      #Calcula futuros eventos.
      HardDiskBilliardSimulation.futurecollisions!(event, cell, particle, t,t_max,pq, label, false)
    end
  end
#Tiempo de la última colisión antes de cambiar de celda.
  e = energy(particle)
  t, e
end

function energy(particle::Particle)
  particle.mass*dot(particle.v,particle.v)/2.
end

