using Unitful
using Unitful.DefaultSymbols
# Load sub-modules
include("../src/physics.jl")
include("../src/components.jl")
include("../src/vehicles.jl")
include("../src/maneuvers.jl")
include("../src/properties.jl")

# Demo Rocket- Starship
# - Tank/Structure
mᵢ =   120_000.0kg
mₚ = 1_200_000.0kg
ss_tank = Tank(mᵢ, mᵢ+mₚ)
# - Engines
Raptor = SingleEngine("RaptorVacuum", 2200.0kN, 380.0s, 1500.0kg, 0.4)
# - Payload definition
PL = SpaceProbe(100_000.0kg)
# - Assemble Stage
Starship = Rocket(PL, ss_tank, EngineCluster(Raptor, 6))

# ---------------------------------
# Boiloff FUNCTIONS

using OrdinaryDiffEq
using Unitful

# Add additional units to the namespace
hr = u"hr"

# function boiloff(init_mass::typeof(kg), rate::typeof(u"s^-1"), duration::typeof(s))
function compute_boiloff(init_mass, rate, duration)
    f(mass, p, t) = -rate * mass
    tspan = (0.0s, duration)
    prob = ODEProblem(f, init_mass, tspan)
    sol = solve(prob, Tsit5())
    return init_mass - sol.u[end]
end

mᵢ = 2000.0kg  # kg
r  = 0.01/hr  # 1% per day
d  = 10.00hr

compute_boiloff(mᵢ, r, d)

function boiloff!(r::Rocket, rate, duration)
    r.propellant -= compute_boiloff(r.propellant, rate, duration)
    return nothing
end

@show Starship.propellant
boiloff!(Starship, 0.01/hr, 10hr)
@show Starship.propellant
