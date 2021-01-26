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
function boiloff!(r::Rocket, rate, duration)
    r.propellant -= compute_boiloff(r.propellant, rate, duration)
    return nothing
end

