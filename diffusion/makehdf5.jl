push!(LOAD_PATH,"../src/")

using HDF5
using HardDiskBilliardSimulation
using Docile

include("regulartimes.jl")

function createhdf5(nameoffile, parameters, nofensembles, nofrealizations)
    h5open("./HDF5/$nameoffile.hdf5", "w") do file
        attrs(file)["Nofensembles"] = nofensembles
        attrs(file)["Nofrealizations"] = nofrealizations
        for (key,value) in parameters
            attrs(file)[string(key)] = value
        end
    end
end



@doc """#initializefile(nameoffile, parameters, nofensembles)
Generate the data for the first particle (realization) in each ensemble according
to the passed parameters."""->
function initializefile!(nameoffile, parameters, nofensembles)
    file = h5open("./HDF5/$nameoffile.hdf5", "r+")
    sim = simulation(;parameters...)
    x, dt = xtoregulartimes(sim)
    lenofarray = length(x)
    file["ensemble-1/particle-1/x"] = x
    attrs(file["ensemble-1/particle-1"])["Numberofrealization"] = 1
    attrs(file)["Δt"] = dt
    close(file)

    for j in 2:nofensembles
        file = h5open("./HDF5/$nameoffile.hdf5", "r+")
        sim = simulation(;parameters...)
        x, = xtoregulartimes(sim)
        file["ensemble-$j/particle-1/x"] = x
        attrs(file["ensemble-$j/particle-1"])["Numberofrealization"] = 1
        close(file)
    end
end


function runallrealizations!(nameoffile, nofensembles, nofrealizations)
    for ensemble in 1:nofensembles
        if nofrealizations > 1
            for realization in 2:nofrealizations
                file = h5open("./HDF5/$nameoffile.hdf5", "r+")
                sim = simulation(;parameters...)
                x, dt = xtoregulartimes(sim)
                file["ensemble-$ensemble/particle-$realization/x"] = x
                attrs(file["ensemble-$ensemble/particle-$realization"])["Numberofrealization"] = realization
                close(file)
            end
        end
    end
end

@doc """#deltaxandmsd!(nameoffile,nofensembles,nofrealizations)
Returns the value for Δx for each realization and the statistical mean of the msd (mean square displacement)
calculated over the ensemble (that acts like the ensemble in the sense that contains different realizations) """->
function deltaxandmsd!(nameoffile,nofensembles,nofrealizations)
    for ensemble in 1:nofensembles
        deltax!("./HDF5/$nameoffile.hdf5", ensemble,nofrealizations)
        msd!("./HDF5/$nameoffile.hdf5", ensemble,nofrealizations)
    end
end

@doc """#deltax!(nameoffile, nofensemble,nofrealizations)
Calculates the value of Δx for each realization in the specified number of ensemble"""->
function deltax!(nameoffile, nofensemble,nofrealizations)
    #Initialize for particle-1 (first realization)
    file = h5open(nameoffile, "r+")
    particle1data = file["ensemble-$nofensemble/particle-1"]
    x = read(particle1data,"x")
    Δx = x - x[1]
    file["ensemble-$nofensemble/particle-1/Δx"] =  Δx
    close(file)
    if nofrealizations > 1
        for realization in 2:nofrealizations
            file = h5open(nameoffile, "r+")
            particle = file["ensemble-$nofensemble/particle-$realization"]
            x = read(particle, "x")
            Δx = x - x[1]
            file["ensemble-$nofensemble/particle-$realization/Δx"] =  Δx
            close(file)
        end
    end
end


@doc """#msd!(nameoffile, nofensemble,nofrealizations)
Calculates the msd (mean square displacement) of Δx for the specified number of ensemble (the group that contains `nofrealizations` number
of realizations)"""->
function msd!(nameoffile, nofensemble,nofrealizations)
    file = h5open(nameoffile, "r+")
    particle1data = file["ensemble-$nofensemble/particle-1"]
    x = read(particle1data,"x")

    # length(x) indicates the number of data per realization

    deltax = zeros(length(x))
    deltaxsquare = zeros(length(x))

    for i in 1:length(x)
        Δx = 0.0
        Δxsquare = 0.0
        for group in file["ensemble-$nofensemble"]
            #In this loop add the values for Δx and Δx^2 for all the realizations in a ensemble in a fixed time
            particle = read(group)
            Δx += particle["Δx"][i]
            Δxsquare += particle["Δx"][i]*particle["Δx"][i]
        end
        deltax[i] = Δx
        deltaxsquare[i] = Δxsquare
    end

    deltaxpromedio = deltax/nofrealizations
    deltaxsquarepromedio = deltaxsquare/nofrealizations
    file["ensemble-$nofensemble/meansquaredisplacement/<(Δx)^2>"] = deltaxsquarepromedio
    close(file)
end
