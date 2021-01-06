using Unitful
using Unitful.DefaultSymbols
# Load sub-modules
include("./src/physics.jl")
include("./src/components.jl")
include("./src/vehicles.jl")
include("./src/maneuvers.jl")
include("./src/properties.jl")

# Starship
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

# Maneuvers
leo_2_tli  =   Transfer("LEO",  "TLI",  3250m/s )
tli_2_nrho =   Transfer("TLI",  "NRHO",  450m/s )
# nrho_2_llo =   Transfer("NRHO", "LLO",    90m/s )
nrho_2_llo =   Transfer("NRHO", "LLO",   650m/s )
llo_2_moon =   Transfer("LLO",  "Moon", 2060m/s )
moon_2_LLO =   Transfer("Moon", "LLO",  1860m/s )
llo_2_nrho =   Transfer("LLO",  "NRHO",  670m/s )
# llo_2_nrho =   Transfer("LLO",  "NRHO",  180m/s )
nrho_2_earth = Transfer("NRHO", "Earth", 450m/s )

Starship.propellant

burn!(Starship, leo_2_tli)
burn!(Starship, tli_2_nrho)
# burn!(Starship, nrho_2_llo)
# burn!(Starship, llo_2_moon)

Starship.propellant