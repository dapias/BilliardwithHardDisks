include("../src/objects.jl")
include("../src/createobjects.jl")


#Cuadrar Lx1 y Lx2 en general

using Init
using PyPlot
using PyCall

pygui(true)

@pyimport matplotlib.path as mpath
@pyimport matplotlib.patches as patch
@pyimport matplotlib.lines as lines
@pyimport matplotlib.animation as animation

numberofcells = 3
size_x = 3.
size_y = 3.
board = Init.create_board(numberofcells,size_x,size_y)


fig = plt.figure()
ax = fig[:add_axes]([0.05, 0.05, 0.9, 0.9])

for i in 1:numberofcells
    disk = board.cells[i].disk
    c = patch.Circle((disk.r),disk.radius)
    ax[:add_patch](c)
end

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

particula = Init.create_particle(board, 1.0, 1.0 ,size_x,size_y)
ax[:plot]([particula.r[1]], [particula.r[2]], markersize = 5., "go")


ax[:set_xlim](0, numberofcells*size_x)
ax[:set_ylim](0, size_y)
plt.gca()[:set_aspect]("equal")

#l1 = lines.Line2D([-L + i*espacio, -L + i*espacio],[-espacio,-0.5])
