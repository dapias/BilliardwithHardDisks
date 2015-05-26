module Visual

VERSION < v"0.4-" && using Docile

using HardDiskBilliardSimulation
using HardDiskBilliardModel
using PyPlot
using PyCall
using DataStructures



export visualize

pygui(true)
#pygui(false)

@pyimport matplotlib.path as mpath
@pyimport matplotlib.patches as patch
@pyimport matplotlib.lines as lines
@pyimport matplotlib.animation as animation



function visualize(simulation_results, radiusparticle)

  board, particle, particle_positions, particle_velocities, time, disk_positions, disk_velocities, delta_e, disk = simulation_results

  radiusdisk = disk.radius
  massparticle = particle.mass

  fig = plt.figure()
  ax = fig[:add_subplot](111)
  energy_text = ax[:text](0.02,0.88,"",transform=ax[:transAxes])
  time_text = ax[:text](0.60,0.88,"",transform=ax[:transAxes])

  c = patch.Circle([disk_positions[1],disk_positions[2]],radiusdisk)
  c[:set_color]((rand(),rand(),rand()))
  circles = [c]
  ax[:add_patch](c)

  #     c = patch.Circle([disk_positions_back[1],disk_positions_back[2]],radiusdisk)
  #     c[:set_color]((rand(),rand(),rand()))
  #     push!(circles,c)
  #     ax[:add_patch](c)

  p = patch.Circle([particle_positions[1],particle_positions[2]],radiusparticle)
  puntual = [p]
  ax[:add_patch](p)
  plt.gca()[:set_aspect]("equal")

  drawwalls(board, ax)


  function animate(i)
    z = [i/10 > t for t in time]
    k = findfirst(z,false) - 1

    if k == 0
      circles[1][:center] = (disk_positions[1],disk_positions[2])
      #       #             circles[2][:center] = (disk_positions_back[1],disk_positions_back[2])
      puntual[1][:center] = (particle_positions[1], particle_positions[2])

    else
      #  circles[1][:center] = (disk_positions[1+2*(k-1)] + disk_velocities[1+2*(k-1)]*(i/10-time[k]), disk_positions[2+2*(k-1)]+disk_velocities[2+2*(k-1)]*(i/10-time[k]))
      puntual[1][:center] = (particle_positions[1+2*(k-1)] + particle_velocities[1+2*(k-1)]*(i/10-time[k]), particle_positions[2+2*(k-1)]+particle_velocities[2+2*(k-1)]*(i/10-time[k]))
      circles[1][:center] = (disk_positions[1+2*(k-1)] + disk_velocities[1+2*(k-1)]*(i/10-time[k]), disk_positions[2+2*(k-1)]+disk_velocities[2+2*(k-1)]*(i/10-time[k]))
      e_text = delta_e[k]
      t_text = time[k]
      energy_text[:set_text]("Delta_E = $(e_text)")
      time_text[:set_text]("Time = $(t_text)")
    end

    return (puntual, circles, )
    #        return (puntual, )
  end

  anim = animation.FuncAnimation(fig, animate, frames=int(time[end]*10), interval=20, blit=false, repeat = false) #In interval 10 is faster than 20. 200 is pretty slow
#   mywriter = animation.MencoderWriter()
#   anim[:save]("/home/maquinadt/Documentos/NewBilliard/src/gas.avi", writer = mywriter)

end




function drawwalls(board::Board, ax)
  cell = back(board.cells)
  label2 = cell.numberofcell

  cell = front(board.cells)
  label1 = cell.numberofcell

  size_x = abs(cell.walls[4].x - cell.walls[1].x)
  size_y = abs(cell.walls[3].y - cell.walls[2].y)

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

  numberofcells = abs(label2 - label1)+1

  #     if label1 == 0 || label2 == 0
  #         numberofcells = abs(label2 - label1) + 1
  #     end

  xmax = walls[4].x + (numberofcells-1)*size_x

  if label1 == -1
    xmax = walls[4].x + (numberofcells)*size_x
  end

  if numberofcells >= 2
    if label1 == -1
      line2 = lines.Line2D([walls[2].x[1],walls[2].x[2] + (numberofcells)*size_x],[walls[2].y,walls[2].y])
      line3 = lines.Line2D([walls[3].x[1],walls[3].x[2]+ (numberofcells)*size_x],[walls[3].y,walls[3].y])
      ax[:add_line](line2)
      ax[:add_line](line3)
    end

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


# function localenergy(massdisk,v_disk)
#     energy = massdisk*dot(v_disk,v_disk)/2
# end


# function update_line(d_vel,k, numberofcells, massdisk)
#     x = [1:numberofcells]
#     y = zeros(numberofcells)
#     for i in 1:numberofcells
#         y[i] = localenergy(massdisk, d_vel[i][k])
#     end
#     x,y
# end

end

