push!(LOAD_PATH,"./")
push!(LOAD_PATH,"../src/")
using HDF5
using DiffusionSimulation


datafile = h5open("diffusiont_max$time.hdf5", "r+")
particle1data = datafile["particle-1"]
x = read(particle1data,"x")
Δx = x - x[1]
datafile["/particle-1/Δx"] =  Δx
close(datafile)


if nofruns > 1
    for run in 2:nofruns
        datafile = h5open("diffusiont_max$time.hdf5", "r+")
        particledata = datafile["particle-$run"]
        x = read(particledata,"x")
        Δx = x - x[1]
        datafile["/particle-$run/Δx"] =  Δx
        close(datafile)
    end
end

datafile = h5open("diffusiont_max$time.hdf5", "r+")
deltax = zeros(length(x))
deltaxsquare = zeros(length(x))

for i in 1:length(x)
    Δx = 0.0
    Δxsquare = 0.0
    for obj in datafile
           particle = read(obj)
           Δx += particle["Δx"][i]
           Δxsquare += particle["Δx"][i]*particle["Δx"][i]
    end
    deltax[i] = Δx
    deltaxsquare[i] = Δxsquare
end

deltaxpromedio = deltax/nofruns
deltaxsquarepromedio = deltaxsquare/nofruns
datafile["rms/rms"] = deltaxsquarepromedio - deltaxpromedio
datafile["root mean square"]

close(datafile)




# time = parameters[:t_max]
# t = linspace(0.0, tmin, nofsamples)

# datafile = h5open("diffusiont_max$time.hdf5", "r+")
# firstgroup = datafile["/particle-1"]
# x = read(firstgroup,"x")
# for k in 1:length(x)

#     for run in 2:nofruns
#         A = read(firstgroup,"particle_x-$run")
#         B = read(firstgroup,"time-$run")
#         ax[:plot](B,A,".-")
#     end
#     fig[:savefig]("./images/t_max$t.png")
#     close(dataset)






