include("../src/HardDiskBilliardModel.jl")

using HardDiskBilliardModel
using FactCheck





#HardDiskBilliardModel.move(disk,1.0)

function update_x_disk(disk,Lx1,size_x)
  ###Ver qué pasa si son exactamente iguales
  bx1 = Lx1 + disk.radius
  bx2 = Lx1 + size_x - disk.radius
  width = bx2 - bx1
  if disk.r[1] >= bx2
    distance = disk.r[1] - bx2
    k = mod(distance,width)
    if !iseven(int(fld(distance, width)))
      disk.r[1] = bx1 + k
    else
      disk.r[1] = bx2 - k
    end
  else
    distance = abs(disk.r[1] - bx1)
    k = mod(distance,width)
    if !iseven(int(fld(distance, width)))
      disk.r[1] = bx2 - k
    else
      disk.r[1] = bx1 + k
    end
  end
  disk.r
end


function update_y_disk(disk,Ly1,size_y)
  ###Ver qué pasa si son exactamente iguales
  by1 = Ly1 + disk.radius
  by2 = Ly1 + size_y - disk.radius
  height = by2 - by1
  if disk.r[2] >= by2
    distance = disk.r[2] - by2
    k = mod(distance,height)
    if !iseven(int(fld(distance, height)))
      disk.r[2] = by1 + k
    else
      disk.r[2] = by2 - k
    end
  else
    distance = abs(disk.r[2] - by1)
    k = mod(distance,height)
    if !iseven(int(fld(distance, height)))
      disk.r[2] = by2 - k
    else
      disk.r[2] = by1 + k
    end
  end
  disk.r
end

cell, particle = HardDiskBilliardModel.create_initial_cell_with_particle(Lx1, Ly1,size_x,size_y,radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, windowsize)
disk = cell.disk
disk.r = [1.5, 1.5]
disk.v = [0,1.0]



by1 = Ly1 + disk.radius
by2 = size_y - disk.radius

facts("Disk update tests") do
  Lx1 = 5
  Ly1 = 5
  size_x = 3.                     #Size of the cell in x
  size_y = 3.
  radiusdisk = 1.0
  massdisk = 1.0
  disk = HardDiskBilliardModel.Disk([6.5.,6.5],[1.,1.],radiusdisk,massdisk,0)



  D =
    @fact D.r => [2.0,3.0]
    @fact D.v => [4.0,6.0]
    @fact D.radius => 6.0
    @fact D.mass => 4.0
    @fact D.numberofcell => 0
    @fact D.lastcollision => 0
end

