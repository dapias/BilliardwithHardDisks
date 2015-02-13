include("./objects.jl")
include("./timesandrules.jl")
include("./creatingobjects.jl")

module Simulation

VERSION < v"0.4-" && using Docile

# radius = 1.0
# mass = 1.0
# velocity = 1.0
# Lx1 = 0
# Ly1 = 0
# hole_size = 0.5*radius


importall Objects
importall Rules
importall Init
import Base.isless
export simulation, energy

#This allow to use the PriorityQueue providing a criterion to select the priority of an Event.
isless(e1::Event, e2::Event) = e1.time < e2.time


@doc doc"""Calculates the initial feasible Events and push them into the PriorityQueue with label
equal to 0"""->
function initialcollisions!(board::Board,particle::Particle,tinicial::Number,tmax::Number,pq)
    for cell in board.cells
        dt,k = dtcollision(cell.disk,cell)
        if tinicial + dt < tmax
            Collections.enqueue!(pq,Event(tinicial+dt, cell.disk, cell.walls[k],0),tinicial+dt)
        end
    end
    cell = board.cells[1]
    dt,k = dtcollision(particle,cell)
    if tinicial + dt < tmax
        if k == 5
            Collections.enqueue!(pq,Event(tinicial+dt, particle, cell.disk,0),tinicial+dt)
        else
            Collections.enqueue!(pq,Event(tinicial+dt, particle, cell.walls[k],0),tinicial+dt)
        end
    end
end

@doc doc"""Updates the PriorityQueue pushing into it all the feasible Events that can occur after a valid collision"""->
function futurecollisions!(particle::Particle,board::Board, tinicial::Number,tmax::Number,pq, labelprediction)
    cell = board.cells[particle.numberofcell]
    dt,k = dtcollision(particle,cell)
    if tinicial + dt < tmax
        if k == 5
            Collections.enqueue!(pq,Event(tinicial+dt, particle, cell.disk,labelprediction),tinicial+dt)
        else
            Collections.enqueue!(pq,Event(tinicial+dt, particle, cell.walls[k],labelprediction),tinicial+dt)
        end
    end
end


function futurecollisions!(disk::Disk,board::Board, tinicial::Number,tmax::Number,pq, labelprediction)
    cell = board.cells[disk.numberofcell]
    dt,k = dtcollision(disk,cell)
    if tinicial + dt < tmax
        if k == 5
            Collections.enqueue!(pq,Event(tinicial+dt, particle, cell.disk,labelprediction),tinicial+dt)
        else
            Collections.enqueue!(pq,Event(tinicial+dt, particle, cell.walls[k],labelprediction),tinicial+dt)
        end
    end
end



# @doc doc"""Calculates the total energy (kinetic) of the system."""->
# function energy(masas,velocidades)
#     e = 0.
#     for i in 1:length(masas)
#         e += masas[i]*norm(velocidades[i])^2/2.
#     end
#     e
# end

function startingsimulation(numberofcells,size_x,size_y,particle_mass,particle_velocity)
    board = create_board(numberofcells,size_x,size_y)
    particle = create_particle(board, particle_mass, particle_velocity,size_x,size_y)
    disks_positions = [board.cells[i].disk.r for i in 1:numberofcells ]
    particle_positions = [particle.r]
    disks_velocities = [board.cells[i].disk.v for i in 1:numberofcells ]
    particle_velocities = [particle.v]
    #masas = [particula.mass for particula in particulas]
    pq = Collections.PriorityQueue()
    Collections.enqueue!(pq,Event(0.0, Particle([0.,0.],[0.,0.],1.0),Disk([0.,0.],[0.,0.],1.0), 0),0.)
    pq = initialcollisions!(board,particle,tinicial,tmax,pq)
    evento = Collections.dequeue!(pq)
    t = evento.time
    tiempo = [evento.time]
    return board, particle, t, time, disks_positions, particle_positions, disks_velocities, particle_velocities
end



@doc doc"""Contains the main loop of the project. The PriorityQueue is filled at each step with Events associated
to the collider Disk(s); and at the same time the element with the highest physical priority (lowest time) is removed
from the Queue and ignored if it is physically meaningless. The loop goes until the last Event is removed
from the Data Structure, which is delimited by the maximum time(tmax)."""->
function simulation(tinicial, tmax, N, Lx1, Lx2, Ly1, Ly2, vmin, vmax)
    particulas, paredes, posiciones, velocidades, masas, pq, t, tiempo = startingsimulation(tinicial, tmax, N, Lx1, Lx2, Ly1, Ly2, vmin, vmax)
    label = 0

    while(!isempty(pq))
        label += 1
        evento = Collections.dequeue!(pq)
        if (evento.predictedcollision >= evento.referencedisk.lastcollision)
            if typeof(evento.diskorwall) == Disk
                if (evento.predictedcollision >= evento.diskorwall.lastcollision)
                    evento.diskorwall.lastcollision = label
                    evento.referencedisk.lastcollision = label
                    for particula in particulas
                        move(particula,evento.tiempo - t)
                    end
                    t = evento.tiempo
                    push!(tiempo,t)
                    collision(evento.referencedisk,evento.diskorwall)
                    for i in 1:N
                        push!(posiciones, particulas[i].r)
                        push!(velocidades, particulas[i].v)
                    end
                    futurecollisions!(evento.referencedisk, evento.diskorwall, particulas, paredes, t, tmax, pq,label)
                end
            else
                evento.referencedisk.lastcollision = label
                for particula in particulas
                    move(particula,evento.tiempo - t)
                end
                t = evento.tiempo
                push!(tiempo,t)
                collision(evento.referencedisk,evento.diskorwall)
                for i in 1:N
                    push!(posiciones, particulas[i].r)
                    push!(velocidades, particulas[i].v)
                end
                futurecollisions!(evento.referencedisk, particulas, paredes, t, tmax, pq, label)
            end
        end
    end
    push!(tiempo, tmax)
    posiciones, velocidades, tiempo, particulas, masas
end

#Fin del módulo
end
