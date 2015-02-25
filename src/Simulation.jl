include("./Objects.jl")
include("./Initialize.jl")
include("./Rules.jl")

module Simulation

VERSION < v"0.4-" && using Docile

using Objects
#using Rules
using Initialize

importall Rules
import Base.isless
importall Base.Collections
export simulation, energy

#This allows to use the PriorityQueue providing a criterion to select the priority of an Event.
isless(e1::Event, e2::Event) = e1.time < e2.time


@doc doc"""Calculates the initial feasible Events and push them into the PriorityQueue with label (whenwaspredicted)
equal to 0"""->
function initialcollisions!(board::Board,particle::Particle,t_initial::Number,t_max::Number,pq)
    ####dt, k = dtcollision (objeto1,objeto2) podrían estar en una sola función
    for cell in board.cells
        dt,k = dtcollision(cell.disk,cell)
        if t_initial + dt < t_max
            enqueue!(pq,Event(t_initial+dt, cell.disk, cell.walls[k],0),t_initial+dt)
        end

        dt,k = dtcollision(particle,cell)
        if t_initial + dt < t_max
            enqueue!(pq,Event(t_initial+dt, particle, cell.walls[k],0),t_initial+dt)
        end

        dt = dtcollision(particle,cell.disk)
        if t_initial + dt < t_max
            enqueue!(pq,Event(t_initial+dt, particle, cell.disk,0),t_initial+dt)
        end
    end
end


@doc doc"""Updates the PriorityQueue pushing into it all the feasible Events that can occur after a valid collision"""->
function futurecollisions!(event::Event,board::Board, t_initial::Number,t_max::Number,pq, labelprediction, particle :: Particle)
    cell = nothing
    for c in board.cells
        if c.numberofcell == event.referenceobject.numberofcell
            cell = c
            break
        end
    end


    function future(particle::Particle, disk::Disk)
        dt,k = dtcollision(particle,cell)
        if t_initial + dt < t_max
            enqueue!(pq,Event(t_initial+dt, particle, cell.walls[k],labelprediction),t_initial+dt)
        end

        dt,k = dtcollision(disk,cell)
        if t_initial + dt < t_max
            enqueue!(pq,Event(t_initial+dt, disk, cell.walls[k],labelprediction),t_initial+dt)
        end
    end

    function future(particle::Particle, wall::Wall)
        dt,k = dtcollision(particle,cell, wall)
        if t_initial + dt < t_max
            enqueue!(pq,Event(t_initial+dt, particle, cell.walls[k],labelprediction),t_initial+dt)
        end

        dt = dtcollision(particle,cell.disk)
        if t_initial + dt < t_max
            enqueue!(pq,Event(t_initial+dt, particle, cell.disk,labelprediction),t_initial+dt)
        end
    end

    function future(disk::Disk, wall::Wall)
        dt,k = dtcollision(disk,cell)
        if t_initial + dt < t_max
            enqueue!(pq,Event(t_initial+dt, disk, cell.walls[k],labelprediction),t_initial+dt)
        end

        if  is_particle_in_cell(particle,cell)
            dt = dtcollision(particle,disk)
            if t_initial + dt < t_max
                enqueue!(pq,Event(t_initial+dt, particle, disk,labelprediction),t_initial+dt)
            end
        end
    end

    future(event.referenceobject,event.diskorwall)
end

function is_particle_in_cell(p::Particle,c::Cell)
    contain = false
    if c.numberofcell == p.numberofcell
        contain = true
    end
    contain
end

function createanimationlists(particle::Particle)
    #disks_positions = [board.cells[i].disk.r for i in 1:numberofcells ]
    #disks_velocities = [board.cells[i].disk.v for i in 1:numberofcells ]
    particle_positions = [particle.r]
    particle_velocities = [particle.v]
    particle_positions, particle_velocities
end

function createanimationlists(board::Board)
    disk_positions =  [front(board.cells).disk.r]
    disk_velocities = [front(board.cells).disk.v]
#     particle_positions = [particle.r]
#     particle_velocities = [particle.v]
#     particle_positions, particle_velocities
    disk_positions, disk_velocities
end



@doc """Returns true if the event was predicted after the last collision of the Particle and/or Disk """->
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

    if event.whenwaspredicted >= event.referenceobject.lastcollision
        validate(event.diskorwall)
    end
    validcollision
end

@doc """Update the lastcollision label of the Disk(s) with the label of the loop"""->
function updatelabels(event::Event,label)
    function update(p::Particle,d::Disk)
        event.diskorwall.lastcollision = label
        event.referenceobject.lastcollision = label
    end

    function update(d::Disk,w::Wall)
        event.referenceobject.lastcollision = label
    end

    function update(p::Particle,w::Wall)
        event.referenceobject.lastcollision = label
    end

    update(event.referenceobject,event.diskorwall)
end



function move(board::Board,particle::Particle,delta_t)
    for cell in board.cells
        move(cell.disk,delta_t)
    end
    move(particle,delta_t)
end


function updateanimationlists!(particle::Particle,particle_positions, particle_velocities, initialcell::Cell)
        push!(disk_positions,initialcell.disk.r)
        push!(disk_velocities,initialcell.disk.v)
#         end
    for i in 1:2
        push!(particle_positions, particle.r[i])
        push!(particle_velocities, particle.v[i])
    end
end



function startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1,
                         size_x, size_y, windowsize)
    board, particle = create_board_with_particle(Lx1, Ly1,size_x,size_y,radiusdisk, massdisk, velocitydisk,
                                                 massparticle, velocityparticle, windowsize)
    pq = PriorityQueue()
    enqueue!(pq,Event(0.0, Particle([0.,0.],[0.,0.],1.0,0),Disk([0.,0.],[0.,0.],1.0,1.0,0), 0),0.)
    initialcollisions!(board,particle,t_initial,t_max,pq)
    event = dequeue!(pq)
    t = event.time
    time = [event.time]
    return board, particle, t, time, pq
end


@doc doc"""Contains the main loop of the project. The PriorityQueue is filled at each step with Events associated
to the collider Disk or Particle; and the element with the highest physical priority (lowest time) is removed
from the Queue and ignored if it is physically meaningless. The loop goes until the last Event is removed
from the Data Structure, which is delimited by the maximum time(t_max)."""->


function simulation(; t_initial = 0, t_max = 100, radiusdisk = 1.0, massdisk = 1.0, velocitydisk =1.0,massparticle = 1.0, velocityparticle =1.0,
                    Lx1 = 0., Ly1=0., size_x = 3., size_y = 3.,windowsize = 0.5)
    board, particle, t, time, pq = startsimulation(t_initial, t_max, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, Lx1, Ly1, size_x, size_y,
                                                   windowsize)
    particle_positions, particle_velocities =  createanimationlists(particle)
    disk_positions, disk_velocities = createanimationlists(board)
    initialcell = front(board.cells)
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
            collision(event.referenceobject,event.diskorwall, board)
            updateanimationlists!(particle, particle_positions, particle_velocities, initialcell)
            futurecollisions!(event, board, t,t_max,pq, label, particle)
        end
    end
    push!(time, t_max)
    board, particle, particle_positions, particle_velocities, time, disk_positions, disk_velocities, initialcell.disk
end

# function energy(mass_disks, mass_particle, v_particle, v_disks)
#     e = 0
#     e += mass_particle * dot(v_particle, v_particle)/2.
#     for i in 1:length(v_disks)
#         e+= mass_disks*dot(v_disks[i],v_disks[i])/2.
#     end
#     e
# end

function energy(mass_disks, mass_particle, v_particle, v_disks)
    e = 0
    e += mass_particle * dot(v_particle, v_particle)/2.
    e += mass_disks*dot(v_disks,v_disks)/2.

    e
end

#Fin del módulo
end
