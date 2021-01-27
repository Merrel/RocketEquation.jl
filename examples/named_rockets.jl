include("../src/RocketEquation.jl")

# =============================================================================
# Docket definitions

# - Unnamed stages
PL = GenericPayload("generic", 1000kg)
S1 = Rocket(PL, Tank(15000kg, 75000kg), SingleEngine(450.0s))
S2 = Rocket(PL, Tank(1500kg, 7500kg), SingleEngine(450.0s))

name(S1)

# - Unnamed stages
Orion  = Capsule("Orion", 1000kg)
DIVupp = Rocket("DeltaIVUpper", PL, Tank(15000kg, 75000kg), SingleEngine(450.0s))
DIVlow = Rocket("DeltaIVLower", PL, Tank(1500kg, 7500kg), SingleEngine(450.0s))

vehicle = dock!(DIVupp, Orion)
# vehicle = dock!(DIVlow, vehicle)

leo_2_tli  =   Transfer("LEO",  "TLI",  3250m/s )
tli_2_nrho =   Transfer("TLI",  "NRHO",  450m/s )

println("+++++++++")



burn!(vehicle, tli_2_nrho, verbose=true)

