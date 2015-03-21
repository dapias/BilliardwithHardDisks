include("../src/HardDiskBilliardModel.jl")

using HardDiskBilliardModel
using FactCheck

t_initial = 0
t_max = 100
radiusdisk = 1.0
massdisk = 1.0
velocitydisk = 1.0
Lx1 = 0                         #x position of the first cell
Ly1 = 0                         #y position of the first cell
windowsize = 0.5
massparticle = 1.0
size_x = 3.                     #Size of the cell in x
size_y = 3.                     #Size of the cell in y
velocityparticle = 1.0


cell, particle = HardDiskBilliardModel.create_initial_cell_with_particle(Lx1, Ly1,size_x,size_y,radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, windowsize)
disk = cell.disk
disk.r = [1.5, 1.5]
disk.v = [1.0,0.]

bx1 = Lx1 + disk.radius
bx2 = size_x - disk.radius

HardDiskBilliardModel.move(disk,1.0)

function update_x_disk(disk,bx1,bx2)
  if disk.r[1] > bx2
    k = mod(disk.r[1],bx2)
    if !iseven(int(fld(disk.r[1],bx1)))
      disk.r[1] = bx2 - k
    else
      disk.r[1] = bx1 + k
    end
  end
  disk.r
end

