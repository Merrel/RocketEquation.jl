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


"""
A single stage rocket, with a payload which could potentially be another rocket 
thus making it multi-stage.
"""
mutable struct Rocket <: Payload
    payload::Payload
    tank::Tank
    engine::Engine
    throttle::Float64		# Either 0 or in range (min_throttle, 1)
    propellant::typeof(1.0kg)     # Amount of propellant mass left
    sideboosters::Array{Rocket} # Side booster can fire engines along with core stage
end

function Rocket(payload::Payload, tank::Tank, engine::Engine; throttle::Number = 1.0)
    Rocket(payload, tank, engine, throttle, max_propellant(tank), Rocket[])
end

function without_payload(r::Rocket)
    Rocket(nopayload, r.tank, r.engine, r.throttle, r.propellant, r.sideboosters)
end

function with_payload(r::Rocket, new_payload::Payload)
    Rocket(new_payload, r.tank, r.engine, r.throttle, r.propellant, r.sideboosters)
end

"""
Heat shield below and typically no rocket engines or fuel tanks
"""
mutable struct Capsule <: Payload
	mass::typeof(1.0kg)
end

struct SpaceProbe <: Payload
    mass::typeof(1.0kg)
end

mutable struct Satellite <: Payload
	mass::typeof(1.0kg)
end

struct GenericPayload <: Payload
	mass::typeof(1.0kg)
end

struct CrewPayload <: Payload
	mass::typeof(1.0kg)
end

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


