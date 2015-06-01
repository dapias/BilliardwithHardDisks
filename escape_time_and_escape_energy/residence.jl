push!(LOAD_PATH,"../src/")
push!(LOAD_PATH,"../myDataStructures/")
include("../src/HardDiskBilliardSimulation.jl")
#include("../myDataStructures/MyCollections.jl")

using HardDiskBilliardSimulation
using HardDiskBilliardModel
using MyCollections
using Docile


# importall HardDiskBilliardModel
# importall MyCollections
# importall HardDiskBilliardSimulation


@doc "Returns the escape-time and the energy of the particle that leaves the cell."->
function residencetime(parameters)

  t_initial = parameters["t_initial"]
  t_max = parameters["t_max"]
  radiusdisk = parameters["radiusdisk"]
  massdisk = parameters["massdisk"]
  velocitydisk = parameters["velocitydisk"]
  massparticle = parameters["massparticle"]
  velocityparticle = parameters["velocityparticle"]
  Lx1 =  parameters["Lx1"]
  Ly1 =  parameters["Ly1"]
  size_x =  parameters["size_x"]
  size_y =  parameters["size_y"]
  windowsize =  parameters["windowsize"]
  radius =  parameters["radius"]



  board, particle, t, time, pq = startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                                                 windowsize, radius)

  label = 0
  condicion = true

  while(condicion && !isempty(pq))
    label += 1
    event, event_time = dequeue!(pq)
    validcollision = validatecollision(event, particle)

    if validcollision
      #En este bloque se considera el movimiento de la celda actual.

      updatelabels(event,label)
      cell = get_cell(board, particle.numberofcell)
      move(particle,event_time - t)
      update_position_disk(cell,event_time)
      cell.last_t = t = event_time

      #Con esta función, aparte de actualizar las velocidades, se ve si la partícula cambia de número de celda.
      collision(event.dynamicobject,event.diskorwall, board)

      #Si cambia de celda rompe el loop.
      condicion = particle.numberofcell == cell.numberofcell

      #Calcula futuros eventos.
      futurecollisions!(event, cell, particle, t,t_max,pq, label, false)
    end
  end
  #Tiempo de la última colisión antes de cambiar de celda.
  e = energy(particle)
  t, e
end

function energy(particle::Particle)
  particle.mass*dot(particle.v,particle.v)/2.
end

