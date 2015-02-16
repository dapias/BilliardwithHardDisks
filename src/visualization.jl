include("../src/objects.jl")
include("../src/createobjects.jl")

VERSION < v"0.4-" && using Docile


#Cuadrar Lx1 y Lx2 en general
module Visual

#export visualize

using Init
using PyPlot
using PyCall

pygui(true)

@pyimport matplotlib.path as mpath
@pyimport matplotlib.patches as patch
@pyimport matplotlib.lines as lines
@pyimport matplotlib.animation as animation

#numberofcells = 3
#size_x = 3.
#size_y = 3.
radius = 1.0


function visualize(simulation_results,numberofcells,size_x,size_y)
    board, disks_positions, particle_x, particle_y, disks_velocities, particle_vx, particle_vy, time = simulation_results
    d_pos = [[disks_positions[k] for k in j:numberofcells:length(disks_positions)] for j in 1:numberofcells]
    d_vel = [[disks_velocities[k] for k in j:numberofcells:length(disks_velocities)] for j in 1:numberofcells]

    fig = plt.figure()
    ax = fig[:add_axes]([0.05, 0.05, 0.9, 0.9])
    ax[:set_xlim](0, numberofcells*size_x)
    ax[:set_ylim](0, size_y)
    plt.gca()[:set_aspect]("equal")


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

    c = patch.Circle(d_pos[1][1],radius) #En pos[1][1] el primer 1 se refiere a la particula, en tanto que el
    #segundo se refiere al evento.
    c[:set_color]((rand(),rand(),rand()))
    circles = [c]
    ax[:add_patch](c)


    for i in 2:numberofcells
        c = patch.Circle(d_pos[i][1],radius)
        c[:set_color]((rand(),rand(),rand()))
        push!(circles,c)
        ax[:add_patch](c)
    end


    #ax[:plot]([particle_x[1]], [particle_y[1]], markersize = 5., "go")

    particle = patch.Circle([particle_x[1],particle_y[1]],0.03)
    ax[:add_patch](particle)





    function animate(i)

        z = [i/10 > t for t in time]
        k = findfirst(z,false) - 1

        if k == 0
            for j in 1:numberofcells
                circles[j][:center] = (d_pos[j][1][1], d_pos[j][1][2])
            end
            particle[:center] = (particle_x[1],particle_y[1])



        else
            #if time[k] < i/10 < time[k+1]
            for j in 1:numberofcells
                circles[j][:center] = (d_pos[j][k][1] + d_vel[j][k][1]*(i/10-time[k]), d_pos[j][k][2] + d_vel[j][k][2]*(i/10-time[k]))
                particle[:center] = (particle_x[k] + particle_vx[k]*(i/10-time[k]),particle_y[k]+particle_vy[k]*(i/10-time[k]))

                #circulos[2][:center] = (pos2[k][1] + vel2[k][1]*(i/10-time[k]), pos2[k][2] + vel2[k][2]*(i/10-time[k]))
            end

            #  energy_text[:set_text]("energy = $(energy(masas, [vel[j][k] for j in 1:N]))")

        end
        return (circles,particle,)
    end

    anim = animation.FuncAnimation(fig, animate, frames=1000, interval=20, blit=false, repeat = false)
end


end








