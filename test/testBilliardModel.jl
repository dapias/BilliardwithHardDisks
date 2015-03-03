include("../src/HardDiskBilliardModel.jl")

using HardDiskBilliardModel
using FactCheck
using DataStructures

facts("Disk tests") do
  D = HardDiskBilliardModel.Disk([2.,3.],[4.,6.],6.,4,0)
    @fact D.r => [2.0,3.0]
    @fact D.v => [4.0,6.0]
    @fact D.radius => 6.0
    @fact D.mass => 4.0
    @fact D.numberofcell => 0
    @fact D.lastcollision => 0
end


facts("Create Board with Particle test") do
    board, particle = create_board_with_particle(0.0,0.0,10.0,10.0,1.0,1.0,1.0,1.0,1.0,0.05)
    cell = pop!(board.cells)
    @fact cell.walls[1].x => 0.0
    @fact cell.walls[2].y => 0.0
    @fact cell.walls[3].y => 10.0
    @fact cell.walls[4].x => 10.0

    @fact particle.mass => 1.0
    @fact particle.numberofcell => 0
end

facts("Create new cell test") do
    cell, particle = HardDiskBilliardModel.create_initial_cell_with_particle(0.0,0.0,10.0,10.0,1.0,1.0,1.0,1.0,1.0,0.05)
    cell = HardDiskBilliardModel.create_new_right_cell(cell,particle)
    @fact cell.walls[1].x => 10.0
    @fact cell.walls[2].y => 0.0
    @fact cell.walls[3].y => 10.0
    @fact cell.walls[4].x => 20.0
    @fact length(cell.walls[4].y) => 4
    @fact cell.numberofcell => 1
end


facts("Create disk test") do
    cell, particle = HardDiskBilliardModel.create_initial_cell_with_particle(10.0,10.0,10.0,10.0,1.0,1.0,1.0,1.0,1.0,0.05)
    disk = HardDiskBilliardModel.create_disk(0.0,10,0.0,10.0,0.04,1.0,1.0,0)

    @fact disk.radius => 0.04
    @fact disk.mass => 1.0
    @fact disk.numberofcell => 0
end


facts("Collision Disk-Particle") do
    disk = HardDiskBilliardModel.Disk([0.0,0.0],[0.0,0.0],1.0,1.0,0)
    particle = HardDiskBilliardModel.Particle([2.0,0.0],[-1.0,0.0],1.0,0)

    @fact HardDiskBilliardModel.dtcollision(particle,disk) => 1.0
end


facts("Collision Particle-VerticalSharedWall") do
    p1 = HardDiskBilliardModel.Particle([2.0,0.0],[-1.0,0.0],1.0,0)
    vw1 = HardDiskBilliardModel.VerticalSharedWall(0.0,[0.0,1.075,2.25,3.],(-1,0))
    p2 = HardDiskBilliardModel.Particle([2.0,0.0],[1.0,0.0],1.0,0)
    vw2 = HardDiskBilliardModel.VerticalSharedWall(3.0,[0.0,1.075,2.25,3.],(0,1))


    @fact HardDiskBilliardModel.dtcollision(p1,vw1) => 2.0
    @fact HardDiskBilliardModel.dtcollision(p2,vw2) => 1.0
end


facts("Collision Particle-HorizontalWall") do
    p1 = HardDiskBilliardModel.Particle([2.0,1.0],[0,-1.0],1.0,0)
    vw1 = HardDiskBilliardModel.HorizontalWall([0.0,3.],0)
    p2 = HardDiskBilliardModel.Particle([2.0,1.0],[0.0,1.0],1.0,0)
    vw2 = HardDiskBilliardModel.HorizontalWall([0.0,3.],3.)


    @fact HardDiskBilliardModel.dtcollision(p1,vw1) => 1.0
    @fact HardDiskBilliardModel.dtcollision(p2,vw2) => 2.0
end
