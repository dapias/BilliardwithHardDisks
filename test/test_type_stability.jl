include("../src/HardDiskBilliardSimulation.jl")
using DataStructures

radiusdisk = 1.
massdisk = 1.

disk = HardDiskBilliardModel.Disk([6.5,6.5],[-1.,-1.],radiusdisk, massdisk, 0)

@code_warntype HardDiskBilliardSimulation.update_x_disk(disk, 0., 3.)
@code_warntype HardDiskBilliardSimulation.update_y_disk(disk, 0., 3.)

Lx1 = 0.
Ly1 = 0.
size_x = 3.
size_y = 3.
velocitydisk = 1.
massparticle = 1.
velocityparticle = 1.
windowsize = 0.5
t_initial = 0.

board, particle = HardDiskBilliardSimulation.create_board_with_particle(Lx1, Ly1, size_x, size_y, radiusdisk, massdisk, velocitydisk, massparticle, velocityparticle, windowsize, t_initial)

@code_warntype HardDiskBilliardSimulation.get_cell(board,0)

cell = front(board.cells)

@code_warntype HardDiskBilliardSimulation.update_position_disk(cell, 10.)





