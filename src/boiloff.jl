
abstract type AbstractBoiloff end
struct Boiloff <: AbstractBoiloff end

# ---------------------------------
# Boiloff FUNCTIONS

"""
compute_boiloff(init_mass, rate, duration)

Returns the total quantity of propellant lost to boiloff given a specified `init_mass`, 
`rate`, and `duration`. All inputs specified via unitful.
"""
function compute_boiloff(init_mass, rate, duration)
    # Solve ODE
    f(mass, p, t) = -rate * mass
    tspan = (0.0s, duration)
    prob = ODEProblem(f, init_mass, tspan)
    sol = solve(prob, Tsit5())
    return init_mass - sol.u[end]
end

"""
boiloff!(r::Rocket, rate, duration)

Compute boiloff for given rocket and update its propellant load.
"""
function boiloff!(r::Rocket, rate, duration; verbose=false, missionlog=nothing)
    if verbose
        init_prop = r.propellant
    end
    r.propellant -= compute_boiloff(r.propellant, rate, duration)
    if verbose
        end_prop = r.propellant
        δ_prop = init_prop - end_prop
        println("\n  $(r.name)")
        println(  "    > Boiloff (rate=$(uconvert(u"hr^-1", rate)) for $duration -> $(round(typeof(1kg), δ_prop))")
    end

    if missionlog != nothing
        push!(missionlog, [Boiloff last(missionlog).End last(missionlog).End 0m/s name(r) gross(r) split(r.name, " >> ")[1] propellant(r)])
    end

    return nothing
end

