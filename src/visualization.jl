module Visual

using Init
using PyPlot
using PyCall

pygui(true)

@pyimport matplotlib.path as mpath
@pyimport matplotlib.patches as patch
@pyimport matplotlib.lines as lines
@pyimport matplotlib.animation as animation


radius_disks = 1.
radius_puntual_particle = 0.02

function visualize(simulation_results, numberofcells, size_x, size_y)
    board, disks_positions, particle_x, particle_y, disks_velocities, particle_vx, particle_vy, time = simulation_results

    d_pos = [[disks_positions[k] for k in j:numberofcells:length(disks_positions)] for j in 1:numberofcells];
    d_vel = [[disks_velocities[k] for k in j:numberofcells:length(disks_velocities)] for j in 1:numberofcells];



    fig = plt.figure()
    ax = fig[:add_axes]([0.05, 0.05, 0.9, 0.9])

    ax[:set_xlim](0, numberofcells*size_x)
    ax[:set_ylim](0, size_y)
    plt.gca()[:set_aspect]("equal")

    c = patch.Circle(d_pos[1][1],radius_disks) #En pos[1][1] el primer 1 se refiere a la particula, en tanto que el
    #segundo se refiere al evento.
    c[:set_color]((rand(),rand(),rand()))
    circles = [c]
    ax[:add_patch](c)

    for k in 2:numberofcells
        c = patch.Circle(d_pos[k][1],radius_disks)
        c[:set_color]((rand(),rand(),rand()))
        push!(circles,c)
        ax[:add_patch](c)
    end

    p = patch.Circle([particle_x[1],particle_y[1]],radius_puntual_particle)
    puntual = [p]
    ax[:add_patch](p)


    walls = board.cells[1].walls
    line1 = lines.Line2D([walls[1].x,walls[1].x],[walls[1].y[1],walls[1].y[2]])
    line2 = lines.Line2D([walls[2].x[1],walls[2].x[2]],[walls[2].y,walls[2].y])
    line3 = lines.Line2D([walls[3].x[1],walls[3].x[2]],[walls[3].y,walls[3].y])
    line4 = lines.Line2D([walls[4].x,walls[4].x],[walls[4].y[1],walls[4].y[2]])
    line5 = lines.Line2D([walls[4].x,walls[4].x],[walls[4].y[3],walls[4].y[4]])
    ax[:add_line](line1)
    ax[:add_line](line2)
    ax[:add_line](line3)
    ax[:add_line](line4)
    ax[:add_line](line5)

    if numberofcells > 2
        for i in 2:numberofcells-1
            walls = board.cells[i].walls
            line2 = lines.Line2D([walls[2].x[1],walls[2].x[2]],[walls[2].y,walls[2].y])
            line3 = lines.Line2D([walls[3].x[1],walls[3].x[2]],[walls[3].y,walls[3].y])
            line4 = lines.Line2D([walls[4].x,walls[4].x],[walls[4].y[1],walls[4].y[2]])
            line5 = lines.Line2D([walls[4].x,walls[4].x],[walls[4].y[3],walls[4].y[4]])
            ax[:add_line](line2)
            ax[:add_line](line3)
            ax[:add_line](line4)
            ax[:add_line](line5)
        end
    end

    walls = board.cells[end].walls
    line2 = lines.Line2D([walls[2].x[1],walls[2].x[2]],[walls[2].y,walls[2].y])
    line3 = lines.Line2D([walls[3].x[1],walls[3].x[2]],[walls[3].y,walls[3].y])
    line4 = lines.Line2D([walls[4].x,walls[4].x],[walls[4].y[1],walls[4].y[2]])
    ax[:add_line](line2)
    ax[:add_line](line3)
    ax[:add_line](line4)

    #particula = Init.create_particle(board, 1.0, 1.0 ,size_x,size_y)
    #ax[:plot]([particula.r[1]], [particula.r[2]], markersize = 5., "go")

    function animate(i)

        z = [i/10 > t for t in time]
        k = findfirst(z,false) - 1

        if k == 0
            for j in 1:numberofcells
                circles[j][:center] = (d_pos[j][1][1], d_pos[j][1][2])
            end

            p[:center] = (particle_x[1], particle_y[1])
            #circles[2][:center] = (pos2[1][1],pos2[1][2])

        else
            #if time[k] < i/10 < time[k+1]
            for j in 1:numberofcells
                circles[j][:center] = (d_pos[j][k][1] + d_vel[j][k][1]*(i/10-time[k]), d_pos[j][k][2] + d_vel[j][k][2]*(i/10-time[k]))
            end

            puntual[1][:center] = (particle_x[k] + particle_vx[k]*(i/10-time[k]), particle_y[k]+particle_vy[k]*(i/10-time[k]))
        end

        return (circles, puntual,)
    end


    anim = animation.FuncAnimation(fig, animate, frames=1000, interval=20, blit=false, repeat = false)
end

end
