
include("../src/RocketEquation.jl")

# =============================================================================
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

# =============================================================================
# Demo boiloff calculations in various units
mᵢ = 2000.0kg  # k
r  = 0.01/hr  # 1% per day

d  = 1hr
compute_boiloff(mᵢ, r, d)

d  = 3600s
compute_boiloff(mᵢ, r, d)

mᵢ = uconvert(u"lb", 2000kg)
uconvert(kg, compute_boiloff(mᵢ, r, d))

# =============================================================================
# Demo using boiloff with a rocket
@show Starship.propellant
boiloff!(Starship, 0.01/hr, 10hr)
@show Starship.propellant

boiloff!(Starship, 0.01/hr, 10hr, verbose=true)
