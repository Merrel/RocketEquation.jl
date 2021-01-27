using DataFrames
include("../src/RocketEquation.jl")

# -------------------------------------------------------------------------------------------------
# Assembly Define Payload
crew      = 100kg
eva_tools = 100kg
Crew = CrewPayload("Crew", 4crew + 1eva_tools)

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
Starship = Rocket("Starship", nopayload, tank_starship, EngineCluster(Raptor, 6))

# Orion
# - Tank/Structure
mᵢ_orion =   9_300kg - gross(Crew)
mₚ_orion =   1_100kg
tank_orion = Tank(mᵢ_orion, mᵢ_orion+mₚ_orion)
# - Engines
engine_orion = SingleEngine(320.0s)
# - Assemble
Orion = Rocket("Orion", nopayload, tank_orion, engine_orion)

# ESM: European service module
mᵢ_esm =   6_900kg
mₚ_esm =   8_600kg
tank_esm = Tank(mᵢ_esm, mᵢ_esm+mₚ_esm)
# - Engines
engine_esm = SingleEngine(320.0s)
# - Assemble
ESM = Rocket("ESM", nopayload, tank_esm, engine_esm)

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
df = DataFrame(
    Event = Type[], Start=String[], End=String[], ΔV = [], VehicleName=String[], VehicleGross=[], ActiveName=String[], ActiveProp = []
)
status(Starship_ESM_Orion)
print_location("LEO")


# 1. Earth Departure: LEO to TLI
burn!(Starship_ESM_Orion, leo_2_tli, verbose=true, missionlog=df)
# action = leo_2_tli; vehicle = Starship_ESM_Orion;
# push!(df, [typeof(action) action.src action.dst action.dV name(vehicle) gross(vehicle) split(vehicle.name, " >> ")[1] propellant(vehicle)])

# 2. NRHO Arrival: TLI to NRHO
burn!(Starship_ESM_Orion, tli_2_nrho, verbose=true, missionlog=df)
# action = tli_2_nrho; vehicle = Starship_ESM_Orion;
# push!(df, [typeof(action) action.src action.dst action.dV name(vehicle) gross(vehicle) split(vehicle.name, " >> ")[1] propellant(vehicle)])
# print_location("NRHO")

# 3. Stage and leave ORION in NRHO
# println("\n\n--- STAGE: Crew -> Starship\n")
# (Starship, ESM_Orion) =         stage!(Starship_ESM_Orion)
# push!(df, [Staging last(df).End last(df).End 0m/s name(Starship) gross(Starship) split(Starship.name, " >> ")[1] propellant(Starship)])
# push!(df, [Staging last(df).End last(df).End 0m/s name(ESM_Orion) gross(ESM_Orion) split(ESM_Orion.name, " >> ")[1] propellant(ESM_Orion)])

# # 3b. Crew transfer
# (Starship, ESM_Orion) = transfer_crew!(ESM_Orion, Starship)
# push!(df, [CrewTransfer last(df).End last(df).End 0m/s name(Starship) gross(Starship) split(Starship.name, " >> ")[1] propellant(Starship)])
# push!(df, [CrewTransfer last(df).End last(df).End 0m/s name(ESM_Orion) gross(ESM_Orion) split(ESM_Orion.name, " >> ")[1] propellant(ESM_Orion)])

# # 4. To LLO: NRHO to LLO
# burn!(Starship, nrho_2_llo)
# action = nrho_2_llo; vehicle = Starship;
# push!(df, [typeof(action) action.src action.dst action.dV name(vehicle) gross(vehicle) split(vehicle.name, " >> ")[1] propellant(vehicle)])

# #Fixes #3
