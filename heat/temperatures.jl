push!(LOAD_PATH,"../src/")
using HardDiskBilliardSimulation
using PyPlot

parameters = include("parameters.jl")

parameters[:t_max] = 1000
@time sim = simulation(;parameters...);

celda = []
t_final = []

for k in keys(sim[end])
    push!(t_final,sim[end][k][end])
    push!(celda,k[5:end])
end

celda = int(celda)
t_final = float64(t_final)


plot(celda,t_final,"*")


