module Visual

VERSION < v"0.4-" && using Docile

using Simulation
using Objects
using PyPlot
using PyCall
using DataStructures
#using Formatting


export visualize, visualize_localenergy

pygui(true)

@pyimport matplotlib.path as mpath
@pyimport matplotlib.patches as patch
@pyimport matplotlib.lines as lines
@pyimport matplotlib.animation as animation

#function create_walls



function visualize(simulation_results, radiusparticle)
    #board, particle, disks_positions, particle_positions, disks_velocities, particle_velocities, time = simulation_results

board, particle, particle_positions, particle_velocities, time, disk_positions_front,
    disk_velocities_front, disk, disk_positions_back,disk_velocities_back, delta_e = simulation_results

    radiusdisk = disk.radius
    #numberofcells = length(board.cells)
    #size_x = board.cells[1].walls[4].x  - board.cells[1].walls[1].x
    #size_y = board.cells[1].walls[3].y  - board.cells[1].walls[2].y
    #radiusdisk = board.cells[1].disk.radius
    #massdisk = board.cells[1].disk.mass
    massparticle = particle.mass
    #Lx1 = board.cells[1].walls[1].x
    #Ly1 = board.cells[1].walls[2].y

    #d_pos = [[disks_positions[k] for k in j:numberofcells:length(disks_positions)] for j in 1:numberofcells];
    #d_vel = [[disks_velocities[k] for k in j:numberofcells:length(disks_velocities)] for j in 1:numberofcells];

    px = [particle_positions[2i-1] for i in 1:floor(length(particle_positions)/2)]
    py = [particle_positions[2i] for i in 1:floor(length(particle_positions)/2)]

    xmax, = findmax(px)
    ymax, = findmax(py)
    xmin, = findmin(px)
    ymin, = findmin(py)

    #fig = plt.figure()
    #ax = fig[:add_axes]([0.05, 0.05, 0.8, 0.8])

    fig = plt.figure()
    ax = fig[:add_subplot](111)
    energy_text = ax[:text](0.02,0.88,"",transform=ax[:transAxes])
    time_text = ax[:text](0.60,0.88,"",transform=ax[:transAxes])
    #ax[:set_xlim](Lx1, Lx1 + numberofcells*size_x)
    #ax[:set_ylim](Ly1, Ly1 + size_y + 1.0)



    c = patch.Circle([disk_positions_front[1],disk_positions_front[2]],radiusdisk) #En pos[1][1] el primer 1 se refiere a la particula, en tanto que el
        #segundo se refiere al evento.
    c[:set_color]((rand(),rand(),rand()))
    circles = [c]
    ax[:add_patch](c)

    c = patch.Circle([disk_positions_back[1],disk_positions_back[2]],radiusdisk) #En pos[1][1] el primer 1 se refiere a la particula, en tanto que el
        #segundo se refiere al evento.
    c[:set_color]((rand(),rand(),rand()))
    push!(circles,c)
    ax[:add_patch](c)

    #     for k in 2:numberofcells
    #         c = patch.Circle(d_pos[k][1],radiusdisk)
    #         c[:set_color]((rand(),rand(),rand()))
    #         push!(circles,c)
    #         ax[:add_patch](c)
    #     end

    p = patch.Circle([particle_positions[1],particle_positions[2]],radiusparticle)
    puntual = [p]
    ax[:add_patch](p)
    plt.gca()[:set_aspect]("equal")

    drawwalls(board, ax)

    #     initialenergy = energy(massdisk,massparticle, [particle_velocities[1], particle_velocities[2]],
    #                            [d_vel[j][1] for j in 1:numberofcells])
    #     #fig_energy = plt.figure()
    #     ax_energy = fig[:add_subplot](212)
    #     #ax_energy = fig[pl]([0.1, 0.1, 0.8, 0.8])
    #     ax_energy[:set_xlabel]("Number of cell")
    #     ax_energy[:set_ylabel]("Local Energy")

    #     ax_energy[:set_xlim](0, numberofcells+1)
    #     ax_energy[:set_ylim](0, initialenergy/2.)

    #     l, = ax_energy[:plot]([], [], ".-")

    function animate(i)

        z = [i/10 > t for t in time]
        k = findfirst(z,false) - 1

        if k == 0
            circles[1][:center] = (disk_positions_front[1],disk_positions_front[2])
            circles[2][:center] = (disk_positions_back[1],disk_positions_back[2])

            #             for j in 1:numberofcells
            #                 circles[j][:center] = (d_pos[j][1][1], d_pos[j][1][2])
            #             end
            p[:center] = (particle_positions[1], particle_positions[2])

            #             l[:set_data](update_line(d_vel,1, numberofcells, massdisk))
        else
            #if time[k] < i/10 < time[k+1]
            #             for j in 1:numberofcells
            #                 circles[j][:center] = (d_pos[j][k][1] + d_vel[j][k][1]*(i/10-time[k]), d_pos[j][k][2] + d_vel[j][k][2]*(i/10-time[k]))
            #             end
            circles[1][:center] = (disk_positions_front[1+2*(k-1)] + disk_velocities_front[1+2*(k-1)]*(i/10-time[k]), disk_positions_front[2+2*(k-1)]+disk_velocities_front[2+2*(k-1)]*(i/10-time[k]))
            puntual[1][:center] = (particle_positions[1+2*(k-1)] + particle_velocities[1+2*(k-1)]*(i/10-time[k]), particle_positions[2+2*(k-1)]+particle_velocities[2+2*(k-1)]*(i/10-time[k]))
             circles[2][:center] = (disk_positions_back[1+2*(k-1)] + disk_velocities_back[1+2*(k-1)]*(i/10-time[k]), disk_positions_back[2+2*(k-1)]+disk_velocities_back[2+2*(k-1)]*(i/10-time[k]))
            e_text = delta_e[k]
            t_text = time[k]
            energy_text[:set_text]("Delta_E = $(e_text)")
            time_text[:set_text]("Time = $(t_text)")

            #             l[:set_data](update_line(d_vel,k, numberofcells, massdisk))
        end

        return (puntual, circles, )

        #         return (circles, puntual,l)
    end

    anim = animation.FuncAnimation(fig, animate, frames=int(time[end]*10), interval=20, blit=false, repeat = false)

end

function drawwalls(board::Board, ax)
    cell = front(board.cells)
    label2 = cell.numberofcell

    cell = back(board.cells)
    label1 = cell.numberofcell

    size_x = abs(cell.walls[4].x - cell.walls[1].x)
    size_y = abs(cell.walls[3].y - cell.walls[2].y)
    #     radiusdisk = cell.disk.radius
    #     massdisk = cell.disk.mass
    #     velocitydisk = norm(cell.disk.v)
    #     windowsize = cell.walls[1].y[3] - cell.walls[1].y[2]

    ##Notation for lines: from x1,y1, to x2, y2, Line2D([x1,x2],[y1,y2])
    walls = cell.walls
    line1 = lines.Line2D([walls[1].x,walls[1].x],[walls[1].y[1],walls[1].y[2]])
    line2 = lines.Line2D([walls[2].x[1],walls[2].x[2]],[walls[2].y,walls[2].y])
    line3 = lines.Line2D([walls[3].x[1],walls[3].x[2]],[walls[3].y,walls[3].y])
    line4 = lines.Line2D([walls[4].x,walls[4].x],[walls[4].y[1],walls[4].y[2]])
    line5 = lines.Line2D([walls[4].x,walls[4].x],[walls[4].y[3],walls[4].y[4]])
    line6 = lines.Line2D([walls[1].x,walls[1].x],[walls[1].y[3],walls[1].y[4]])
    ax[:add_line](line1)
    ax[:add_line](line2)
    ax[:add_line](line3)
    ax[:add_line](line4)
    ax[:add_line](line5)
    ax[:add_line](line6)

    xmin = walls[1].x
    ymin = walls[2].y
    ymax = walls[3].y

    numberofcells = abs(label2 - label1)

    if label1 == 0 || label2 == 0
        numberofcells = abs(label2 - label1) + 1
    end

    xmax = walls[4].x + (numberofcells-1)*size_x




    if numberofcells >= 2
        line2 = lines.Line2D([walls[2].x[1],walls[2].x[2] + (numberofcells-1)*size_x],[walls[2].y,walls[2].y])
        line3 = lines.Line2D([walls[3].x[1],walls[3].x[2]+ (numberofcells-1)*size_x],[walls[3].y,walls[3].y])
        ax[:add_line](line2)
        ax[:add_line](line3)
        for i in 1:numberofcells
            line4 = lines.Line2D([walls[4].x+ i*size_x,walls[4].x+ i*size_x],[walls[4].y[1],walls[4].y[2]])
            line5 = lines.Line2D([walls[4].x+ i*size_x,walls[4].x+ i*size_x],[walls[4].y[3],walls[4].y[4]])
            ax[:add_line](line4)
            ax[:add_line](line5)
        end

    end

    ax[:set_xlim](xmin,xmax)
    ax[:set_ylim](ymin,ymax+1.)
end


function localenergy(massdisk,v_disk)
    energy = massdisk*dot(v_disk,v_disk)/2
end


function update_line(d_vel,k, numberofcells, massdisk)
    x = [1:numberofcells]
    y = zeros(numberofcells)
    for i in 1:numberofcells
        y[i] = localenergy(massdisk, d_vel[i][k])
    end
    x,y
end

end

