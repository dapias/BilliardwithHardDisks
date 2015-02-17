module Visual

VERSION < v"0.4-" && using Docile

using Simulation
using PyPlot
using PyCall
#using Formatting

include("./input_parameters.jl")

export visualize

pygui(true)

@pyimport matplotlib.path as mpath
@pyimport matplotlib.patches as patch
@pyimport matplotlib.lines as lines
@pyimport matplotlib.animation as animation


function visualize(simulation_results)
     board, disks_positions, particle_positions, disks_velocities, particle_velocities, time = simulation_results

    d_pos = [[disks_positions[k] for k in j:numberofcells:length(disks_positions)] for j in 1:numberofcells];
    d_vel = [[disks_velocities[k] for k in j:numberofcells:length(disks_velocities)] for j in 1:numberofcells];



    fig = plt.figure()
    ax = fig[:add_axes]([0.05, 0.05, 0.9, 0.9])
    energy_text = plt.text(0.02,0.9,"",transform=ax[:transAxes])



    #ax[:set_xlim](0, (numberofcells-2)*size_x)
    ax[:set_xlim](0, numberofcells*size_x)
    ax[:set_ylim](0, size_y+1.0)
    plt.gca()[:set_aspect]("equal")

    c = patch.Circle(d_pos[1][1],radius_disk) #En pos[1][1] el primer 1 se refiere a la particula, en tanto que el
    #segundo se refiere al evento.
    c[:set_color]((rand(),rand(),rand()))
    circles = [c]
    ax[:add_patch](c)

    for k in 2:numberofcells
        c = patch.Circle(d_pos[k][1],radius_disk)
        c[:set_color]((rand(),rand(),rand()))
        push!(circles,c)
        ax[:add_patch](c)
    end

    p = patch.Circle([particle_positions[1],particle_positions[2]],radius_puntual_particle)
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


    function animate(i)

        z = [i/10 > t for t in time]
        k = findfirst(z,false) - 1

        if k == 0
            for j in 1:numberofcells
                circles[j][:center] = (d_pos[j][1][1], d_pos[j][1][2])
            end
            p[:center] = (particle_positions[1], particle_positions[2])

        else
            #if time[k] < i/10 < time[k+1]
            for j in 1:numberofcells
                circles[j][:center] = (d_pos[j][k][1] + d_vel[j][k][1]*(i/10-time[k]), d_pos[j][k][2] + d_vel[j][k][2]*(i/10-time[k]))
            end

            puntual[1][:center] = (particle_positions[1+2*(k-1)] + particle_velocities[1+2*(k-1)]*(i/10-time[k]), particle_positions[2+2*(k-1)]+particle_velocities[2+2*(k-1)]*(i/10-time[k]))

            e_text = energy(mass_disk,mass_particle, [particle_velocities[1+2*(k-1)], particle_velocities[2+2*(k-1)]],
                                                                 [d_vel[j][k] for j in 1:numberofcells])
            #e_textt = format(e_text,precision=6)

            energy_text[:set_text]("Energy = $(e_text)")

#         if particle_x[k] > (numberofcells-4)*size_x+0.01
#             ax[:set_xlim](0, (numberofcells)*size_x)
#         end


        end




        return (circles, puntual,)
    end


    anim = animation.FuncAnimation(fig, animate, frames=1000, interval=20, blit=false, repeat = false)
end

end

