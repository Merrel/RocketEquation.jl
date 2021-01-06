using Unitful
using Unitful.DefaultSymbols
# Load sub-modules
include("../src/physics.jl")
include("../src/components.jl")
include("../src/vehicles.jl")
include("../src/maneuvers.jl")
include("../src/properties.jl")

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

# SpaceVehicle(PL)

@assert true PL::Payload
@assert true PL::SpaceProbe
@assert true Starship::Payload

typeof(nopayload) <: Payload


# p = NoPayload()

SpaceVehicle()
SpaceVehicle( GenericPayload(1000kg) )
SpaceVehicle( SpaceProbe(1000kg) )
SpaceVehicle( Starship )

Starship isa Rocket
Starship isa Payload

hasproperty(Starship, :engine)

# Multi-stage vehicles
nopayload
PL01       = GenericPayload(100_000kg)
Starship01 = Rocket(PL01, ss_tank, EngineCluster(Raptor, 6))
Starship02 = Rocket(Starship01, ss_tank, EngineCluster(Raptor, 6))

gross(PL01)
gross(Starship01)
gross(Starship02)

#
# Demonstrate Staging
#
(Starship02, Starship01) = stage!(Starship02)

gross(Starship02)
gross(Starship01)
gross(PL01)

(Starship01, PL01) = stage!(Starship01)

gross(Starship01)
gross(PL01)

#
# Demonstrate Docking
#
Starship01 = dock!(Starship01, PL01)

gross(Starship02)
gross(Starship01)
gross(PL01)

