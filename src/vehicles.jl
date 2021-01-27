import Base.show
export  SpaceVehicle, 
        Payload, NoPayload, nopayload, GenericPayload,
        Rocket, Capsule, SpaceProbe, Satellite

"""
Anything a stage pushes into the air/space with its booster. Could be e.g. a sattelite or another rocket stage
"""
abstract type Payload end

"Rocket with no payload, such as a detached booster."
struct NoPayload <: Payload
    mass::typeof(1.0kg)
end

NoPayload() = NoPayload(0.0kg)
const nopayload = NoPayload()
name(p::NoPayload) = nothing

# -------------------------------------------------------------------------------------------------
# Rockets

"""
A single stage rocket, with a payload which could potentially be another rocket 
thus making it multi-stage.
"""
mutable struct Rocket <: Payload
    name::String
    payload::Payload
    tank::Tank
    engine::Engine
    throttle::Float64		# Either 0 or in range (min_throttle, 1)
    propellant::typeof(1.0kg)     # Amount of propellant mass left
    sideboosters::Array{Rocket} # Side booster can fire engines along with core stage
end

function Rocket(name::String, payload::Payload, tank::Tank, engine::Engine; throttle::Number = 1.0)
    Rocket(name, payload, tank, engine, throttle, max_propellant(tank), Rocket[])
end

function Rocket(tank::Tank, engine::Engine; throttle::Number = 1.0)
    Rocket("unnamed", nopayload, tank, engine, throttle, max_propellant(tank), Rocket[])
end

function Rocket(name::String, tank::Tank, engine::Engine; throttle::Number = 1.0)
    Rocket(name, nopayload, tank, engine, throttle, max_propellant(tank), Rocket[])
end

function Rocket(payload::Payload, tank::Tank, engine::Engine; throttle::Number = 1.0)
    Rocket("unnamed", payload, tank, engine, throttle, max_propellant(tank), Rocket[])
end

function without_payload(r::Rocket)
    new_name = split(r.name, " >> ")[1]
    Rocket(new_name, nopayload, r.tank, r.engine, r.throttle, r.propellant, r.sideboosters)
end

function with_payload(r::Rocket, new_payload::Payload)
    new_name = r.name * " >> " * new_payload.name
    Rocket(r.name, new_payload, r.tank, r.engine, r.throttle, r.propellant, r.sideboosters)
end

function Base.show(io::IO, r::Rocket)
    println("Rocket: $(r.name)")
    println(" - Current Gross  = $(round(typeof(1kg), gross(r)))")
    println(" - Prop Available = $(round(typeof(1kg), r.propellant))")
    percent_available = r.propellant / max_propellant(r.tank) * 100
    println("                  = $(round(percent_available, digits=3)) %")
    println(" - Payload: $(r.payload)")
end

# -------------------------------------------------------------------------------------------------
# Payloads

struct GenericPayload <: Payload
    name::String
	mass::typeof(1.0kg)
end

"""
Heat shield below and typically no rocket engines or fuel tanks
"""
mutable struct Capsule <: Payload
    name::String
	mass::typeof(1.0kg)
end

struct SpaceProbe <: Payload
    name::String
    mass::typeof(1.0kg)
end

mutable struct Satellite <: Payload
    name::String
	mass::typeof(1.0kg)
end

struct CrewPayload <: Payload
    name::String
	mass::typeof(1.0kg)
end

# function Base.show(io::IO, p::Payload)
#     println("Payload: $(p.name)")
#     println(" - Mass  = $(round(typeof(1kg), gross(r)))")
#     try
#         println(" - Payload: $(r.payload)")
#     catch
#         println(" - Payload: NONE")
#     end
# end

####################### SpaceVehicle #####################################

"Represents a rocket in flight, with all its stages and payload."
mutable struct SpaceVehicle
	active_stage::Payload
    # body::RigidBody
	# gravity::Bool		# Is rocket affected by gravity
end

SpaceVehicle() = SpaceVehicle(nopayload)

# function SpaceVehicle(r::Payload, gravity::Bool = true)
# 	# body = RigidBody(mass(r), 0.0)
# 	SpaceVehicle(r, gravity)
# end

# function SpaceVehicle(rockets::Array{Rocket})
#     ship = SpaceVehicle()
#     pushfirst!(ship, rockets...)
#     return ship
# end


