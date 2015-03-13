push!(LOAD_PATH,"../src/")
using HardDiskBilliardSimulation
using PyPlot

parameters = include("parameters.jl")
nofrealizations = 1000
nofensembles = 1

time = [100, 1000, 10000]

fig = plt.figure()
ax = fig[:add_subplot](111)
ax[:set_xlabel]("Number of cell")
ax[:set_ylabel](L"E_{disk}")

for t in time
    parameters[:t_max] = t
    for j in 1:nofensembles
        dictionary = heatsimulation(;parameters...)

        for i in 2:nofrealizations
            dict = heatsimulation(;parameters...);
            for disk in keys(dict)
                if !haskey(dictionary, disk)
                    dictionary["$disk"] = dict[disk]
                else
                    push!(dictionary[disk],dict[disk][1])
                end
            end
        end


        for disk in keys(dictionary)
            push!(dictionary[disk],mean(dictionary[disk]))
        end

        cellmeanenergy = []
        numberofcell = []

        for disk in keys(dictionary)
            push!(cellmeanenergy,dictionary[disk][end])
            push!(numberofcell,disk[5:end])  #number associated to the disk string (-2 to "disk-2" for example)
        end

        numberofcell = int(numberofcell)
        index = sortperm(numberofcell)  #sort permutations to plot it connecting points
        #in the order of the numberofcell
        ax[:plot](numberofcell[index],cellmeanenergy[index],"*--", label = "time$t")
    end
    handles, labels = ax[:get_legend_handles_labels]()
    ax[:legend](handles, labels, loc =1)
end

