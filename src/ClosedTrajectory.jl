module ClosedTrajectory

VERSION < v"0.4-" && using Docile

using HardDiskBilliardSimulation
using HardDiskBilliardModel
using PyPlot
using PyCall
using DataStructures



export trajectory

pygui(true)
#pygui(false)

@pyimport matplotlib.path as mpath
@pyimport matplotlib.patches as patch
@pyimport matplotlib.lines as lines
@pyimport matplotlib.animation as animation



function trajectory(simulation_results, radiusparticle)

  board, particle, particle_positions, particle_velocities, time, disk_positions, disk_velocities, delta_e, disk = simulation_results

  radiusdisk = disk.radius
  massparticle = particle.mass

  fig = plt.figure()
  ax = fig[:add_subplot](111)
  drawwalls(board, ax)
  x = particle_positions[1:2:end]
  y = particle_positions[2:2:end]
  ax[:plot](x,y,"r.--")
  plt.gca()[:set_aspect]("equal")

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

  ax[:set_xlim](xmin,xmax)
  ax[:set_ylim](ymin,ymax+1.)
end

end

