using Unitful
using Unitful.DefaultSymbols
# Load sub-modules
include("../src/physics.jl")
include("../src/components.jl")
include("../src/vehicles.jl")
include("../src/maneuvers.jl")
include("../src/properties.jl")

# -------------------------------------------------------------------------------------------------
# Assembly Define Payload
crew      = 100kg
eva_tools = 100kg
Crew = CrewPayload("CrewCapsule", 4crew + 1eva_tools)

# -------------------------------------------------------------------------------------------------
# Define Vehicles

# Starship
# - Tank/Structure
mᵢ_starship =   108_000kg
mₚ_starship = 1_135_000kg
tank_starship = Tank(mᵢ_starship, mᵢ_starship+mₚ_starship)
# - Engines
Raptor = SingleEngine("RaptorVacuum", 2200.0kN, 380.0s, 1500.0kg, 0.4)
# - Assemble Stage
Starship = Rocket(nopayload, tank_starship, EngineCluster(Raptor, 6))

# Orion
# - Tank/Structure
mᵢ_orion =   9_300kg - gross(Crew)
mₚ_orion =   1_100kg
tank_orion = Tank(mᵢ_orion, mᵢ_orion+mₚ_orion)
# - Engines
engine_orion = SingleEngine(320.0s)
# - Assemble
Orion = Rocket(nopayload, tank_orion, engine_orion)

# ESM: European service module
mᵢ_esm =   6_900kg
mₚ_esm =   8_600kg
tank_esm = Tank(mᵢ_esm, mᵢ_esm+mₚ_esm)
# - Engines
engine_esm = SingleEngine(320.0s)
# - Assemble
ESM = Rocket(nopayload, tank_esm, engine_esm)

# -------------------------------------------------------------------------------------------------
# Assembly Vehicles
# - Orion+Crew
Orion = dock!(Orion, Crew)
# - Orion+ESM
ESM_Orion = dock!(ESM, Orion)
gross(ESM_Orion)
# - Orion+ESM+Starship
Starship_ESM_Orion = dock!(Starship, ESM_Orion)
gross(Starship_ESM_Orion)

# -------------------------------------------------------------------------------------------------
# Define Mission
leo_2_tli  =   Transfer("LEO",  "TLI",  3250m/s )
tli_2_nrho =   Transfer("TLI",  "NRHO",  450m/s )
# nrho_2_llo =   Transfer("NRHO", "LLO",    90m/s )
nrho_2_llo =   Transfer("NRHO", "LLO",   650m/s )
llo_2_moon =   Transfer("LLO",  "Moon", 2060m/s )
moon_2_LLO =   Transfer("Moon", "LLO",  1860m/s )
llo_2_nrho =   Transfer("LLO",  "NRHO",  670m/s )
# llo_2_nrho =   Transfer("LLO",  "NRHO",  180m/s )
# nrho_2_earth = Transfer("NRHO", "Earth", 450m/s )

# -------------------------------------------------------------------------------------------------
# Fly Mission

# 0. Initial Status
println("\n=============================================\nBegin Mission")
status(Starship_ESM_Orion)
gross(Starship_ESM_Orion)


# 1. Earth Departure: LEO to TLI
burn!(Starship_ESM_Orion, leo_2_tli, verbose=true)

# 2. NRHO Arrival: TLI to NRHO
burn!(Starship_ESM_Orion, tli_2_nrho, verbose=true)

# 3. Stage and leave ORION in NRHO
println("\n\n--- STAGE: Crew -> Starship\n")
(Starship, ESM_Orion) =         stage!(Starship_ESM_Orion)
(Starship, ESM_Orion) = transfer_crew!(ESM_Orion, Starship)

# 4. To LLO: NRHO to LLO
burn!(Starship, nrho_2_llo, verbose=true)

# 5. Descent & Landing: LLO to Moon
burn!(Starship, llo_2_moon, verbose=true)

# 6. Ascent: Moon to LLO
burn!(Starship, moon_2_LLO, verbose=true)

# 6. Depart LLO: LLO to NRHO
burn!(Starship, llo_2_nrho, verbose=true)

# 7. Stage and leave ORION in NRHO
println("\n\n--- TRANSFER: Crew -> Orion+ESM\n")
(ESM_Orion, Starship) = transfer_crew!(Starship, ESM_Orion)

# 6. Orion Leaves NRHO: NRHO to Earth
nrho_2_earth = Transfer("NRHO", "Earth", 450m/s )
burn!(ESM_Orion, nrho_2_earth, verbose=true)

# # (ESM, Orion) = stage!(ESM_Orion)

# # nrho_2_earth_orion = Transfer("NRHO", "Earth", 100m/s )
# # burn!(Orion, nrho_2_earth_orion, verbose=true)

# # crewed = Starship
# # uncrewed = ESM_Orion    
