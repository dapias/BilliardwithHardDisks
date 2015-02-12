include("objects.jl")
include("createobjects.jl")

using Init
using PyCall
using PyPlot

pygui(true)

@pyimport matplotlib.path as mpath
@pyimport matplotlib.patches as patch
@pyimport matplotlib.lines as lines
@pyimport matplotlib.animation as animation

numberofcells = 3
size_x = 10
size_y = 10
board = Init.create_board(numberofcells,size_x,size_y)
println(board)



for i in 1:4
println(board.cells[1].walls[i])
end

nDiscos= 5
radio = 1
espacio = 3
L = nDiscos*espacio/2.0
dizq = -L + radio/2.0 + radio
fig2 = plt.figure()
ax = fig2[:add_axes]([0.1, 0.1, 0.8, 0.8])

for i in 0:nDiscos-1
    c = patch.Circle((dizq + i*espacio,2*rand()*rand(-1:2:1)),radio)
    l1 = lines.Line2D([-L + i*espacio, -L + i*espacio],[-espacio,-0.5])
    l2 = lines.Line2D([-L + i*espacio, -L + i*espacio],[0.5,espacio])
     ax[:add_patch](c)
    ax[:add_line](l1)
    ax[:add_line](l2)
end
#c1= patch.Circle((dizq + espacio/2,0),radio)
#ax[:add_patch](c1)
#l = lines.Line2D([-L,L],[-espacio,espacio])
#ax[:add_line](l)

#line, = ax[:plot](0.-2.5)
part = patch.Circle((0,-2.5),0.01)
ax[:plot]([1.0],[1.0],"+",markersize=8)
ax[:add_patch](part)
ax[:set_xlim](-L, L)
ax[:set_ylim](-espacio, espacio)
plt.gca()[:set_aspect]("equal")
