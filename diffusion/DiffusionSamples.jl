push!(LOAD_PATH,"../src/")

using HDF5
using HardDiskBilliardSimulation
using RegularTimes

export time, lenofarray, nofruns, nofsamples

parameters = include("parameters.jl")
nofruns = 10000
time = parameters[:t_max]
nofsamples = 20


function rms!(hdf5file, nofsample,nofruns)
    file = h5open(hdf5file, "r+")
    particle1data = file["sample-$nofsample/particle-1"]
    x = read(particle1data,"x")
    Δx = x - x[1]
    file["sample-$nofsample/particle-1/Δx"] =  Δx
    close(file)

    if nofruns > 1
        for run in 2:nofruns
            file = h5open(hdf5file, "r+")
            particle = file["sample-$nofsample/particle-$run"]
            x = read(particle, "x")
            Δx = x - x[1]
            file["sample-$nofsample/particle-$run/Δx"] =  Δx
            close(file)
        end
    end

    file = h5open(hdf5file, "r+")
    deltax = zeros(length(x))
    deltaxsquare = zeros(length(x))
    for i in 1:length(x)
        Δx = 0.0
        Δxsquare = 0.0
        for group in file["sample-$nofsample"]
               particle = read(group)
               Δx += particle["Δx"][i]
               Δxsquare += particle["Δx"][i]*particle["Δx"][i]
        end
        deltax[i] = Δx
        deltaxsquare[i] = Δxsquare
    end
    deltaxpromedio = deltax/nofruns
    deltaxsquarepromedio = deltaxsquare/nofruns
    file["sample-$nofsample/rms/rms"] = deltaxsquarepromedio - deltaxpromedio
    close(file)
end


file = h5open("diffusiont_max$time.hdf5", "w")
for (key,value) in parameters
    attrs(file)[string(key)] = value
end
attrs(file)["Nofsamples"] = nofsamples
close(file)


file = h5open("diffusiont_max$time.hdf5", "r+")
sim = simulation(;parameters...)
x, dt = xtoregulartimes(sim)
lenofarray = length(x)
file["sample-1/particle-1/x"] = x
attrs(file["sample-1/particle-1"])["Numberofrun"] = 1
attrs(file)["Δt"] = dt
close(file)

for j in 2:nofsamples
        file = h5open("diffusiont_max$time.hdf5", "r+")
        sim = simulation(;parameters...)
        x, = xtoregulartimes(sim)
        file["sample-$j/particle-1/x"] = x
        attrs(file["sample-$j/particle-1"])["Numberofrun"] = 1
        close(file)
end



for j in 1:nofsamples
    if nofruns > 1
        for i in 2:nofruns
            file = h5open("diffusiont_max$time.hdf5", "r+")
            sim = simulation(;parameters...)
            x, dt = xtoregulartimes(sim)
            file["sample-$j/particle-$i/x"] = x
            attrs(file["sample-$j/particle-$i"])["Numberofrun"] = i
            close(file)
        end
    end

    rms!("diffusiont_max$time.hdf5",j,nofruns)

end
