include("./objects.jl")
include("./timesandrules.jl")
include("./createobjects.jl")

module Simulation

VERSION < v"0.4-" && using Docile


cellforinitialparticle = 1


importall Objects
importall Rules
importall Init
import Base.isless
#export simulation, energy

#This allow to use the PriorityQueue providing a criterion to select the priority of an Event.
isless(e1::Event, e2::Event) = e1.time < e2.time


@doc doc"""Calculates the initial feasible Events and push them into the PriorityQueue with label
equal to 0"""->
function initialcollisions!(board::Board,particle::Particle,t_initial::Number,t_max::Number,pq)
    for cell in board.cells
        dt,k = dtcollision(cell.disk,cell)
        if t_initial + dt < t_max
            Collections.enqueue!(pq,Event(t_initial+dt, cell.disk, cell.walls[k],0),t_initial+dt)
        end
    end

    cell = board.cells[particle.numberofcell]
    dt,k = dtcollision(particle,cell)
    if t_initial + dt < t_max
            Collections.enqueue!(pq,Event(t_initial+dt, particle, cell.walls[k],0),t_initial+dt)
    end

    dt = dtcollision(particle,cell.disk)
    if t_initial + dt < t_max
                Collections.enqueue!(pq,Event(t_initial+dt, particle, cell.disk,0),t_initial+dt)
    end
end


@doc doc"""Updates the PriorityQueue pushing into it all the feasible Events that can occur after a valid collision"""->
function futurecollisions!(event::Event,board::Board, t_initial::Number,t_max::Number,pq, labelprediction, particle :: Particle)
    cell = board.cells[event.referenceobject.numberofcell]

    function future(particle::Particle, disk::Disk)
        dt,k = dtcollision(particle,cell)
        if t_initial + dt < t_max
            Collections.enqueue!(pq,Event(t_initial+dt, particle, cell.walls[k],labelprediction),t_initial+dt)
        end

        dt,k = dtcollision(disk,cell)
        if t_initial + dt < t_max
            Collections.enqueue!(pq,Event(t_initial+dt, disk, cell.walls[k],labelprediction),t_initial+dt)
        end
    end

    function future(particle::Particle, wall::Wall)
        dt,k = dtcollision(particle,cell, wall)
        if t_initial + dt < t_max
                Collections.enqueue!(pq,Event(t_initial+dt, particle, cell.walls[k],labelprediction),t_initial+dt)
        end

        dt = dtcollision(particle,cell.disk)
         if t_initial + dt < t_max
                Collections.enqueue!(pq,Event(t_initial+dt, particle, cell.disk,labelprediction),t_initial+dt)
        end
    end

    function future(disk::Disk, wall::Wall)
        dt,k = dtcollision(disk,cell)
        if t_initial + dt < t_max
            Collections.enqueue!(pq,Event(t_initial+dt, disk, cell.walls[k],labelprediction),t_initial+dt)
        end

        if  is_particle_in_cell(particle,cell)
            dt = dtcollision(particle,disk)
            if t_initial + dt < t_max
                Collections.enqueue!(pq,Event(t_initial+dt, particle, disk,labelprediction),t_initial+dt)
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




function startingsimulation(numberofcells,size_x,size_y,particle_mass,particle_velocity, t_initial, t_max)
    board = create_board(numberofcells,size_x,size_y)
    particle = create_particle(board, particle_mass, particle_velocity,size_x,size_y,cellforinitialparticle)
    disks_positions = [board.cells[i].disk.r for i in 1:numberofcells ]
    particle_x = [particle.r[1]]
    particle_y = [particle.r[2]]
    disks_velocities = [board.cells[i].disk.v for i in 1:numberofcells ]
    particle_vx = [particle.v[1]]
    particle_vy = [particle.v[2]]
    #masas = [particula.mass for particula in particulas]
    pq = Collections.PriorityQueue()
    Collections.enqueue!(pq,Event(0.0, Particle([0.,0.],[0.,0.],1.0),Disk([0.,0.],[0.,0.],1.0), 0),0.)
    initialcollisions!(board,particle,t_initial,t_max,pq)
    event = Collections.dequeue!(pq)
    t = event.time
    time = [event.time]
    return board, particle, t, time, disks_positions, particle_x, particle_y, disks_velocities, particle_vx, particle_vy, pq
end



@doc """Returns true if the event was predicted after the last collision label of the Disk(s)"""->
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



function move(board::Board,particle::Particle,delta_t, numberofcells)
    for i in 1:numberofcells
        move(board.cells[i].disk,delta_t)
    end
    move(particle,delta_t)
end


function updateanimationlists(board::Board,particle::Particle, disks_positions, particle_x, particle_y, disks_velocities, particle_vx, particle_vy, numberofcells)
    for i in 1:numberofcells
        push!(disks_positions,board.cells[i].disk.r)
        push!(disks_velocities, board.cells[i].disk.v)
    end
    push!(particle_x, particle.r[1])
    push!(particle_y, particle.r[2])
    push!(particle_vx, particle.v[1])
    push!(particle_vy, particle.v[2])
end


@doc doc"""Contains the main loop of the project. The PriorityQueue is filled at each step with Events associated
to the collider Disk(s); and the element with the highest physical priority (lowest time) is removed
from the Queue and ignored if it is physically meaningless. The loop goes until the last Event is removed
from the Data Structure, which is delimited by the maximum time(t_max)."""->
function simulation(numberofcells,size_x,size_y,particle_mass,particle_velocity, t_initial, t_max)
    board, particle, t, time, disks_positions, particle_x, particle_y, disks_velocities, particle_vx, particle_vy, pq =
        startingsimulation(numberofcells,size_x,size_y,particle_mass,particle_velocity, t_initial, t_max)
    label = 0
    while(!isempty(pq))
        label += 1
        event = Collections.dequeue!(pq)
        validcollision = validatecollision(event)
        if validcollision
            updatelabels(event,label)
            move(board,particle,event.time-t,numberofcells)
            t = event.time
            push!(time,t)
            collision(event.referenceobject,event.diskorwall)
            updateanimationlists(board,particle,disks_positions, particle_x, particle_y, disks_velocities, particle_vx, particle_vy, numberofcells)
            futurecollisions!(event, board, t,t_max,pq, label, particle)
        end
    end
    push!(time, t_max)
    board, disks_positions, particle_x, particle_y, disks_velocities, particle_vx, particle_vy, time
end

function energy(mass_disks, mass_particle, v_particle, v_disks)
    e = 0
    e += mass_particle * dot(v_particle, v_particle)/2.
    for i in 1:length(v_disks)
        e+= mass_disks*dot(v_disks[i],v_disks[i])/2.
    end
    e
end

#Fin del módulo
end
