export  Engine, EngineCluster, Tank

"""
Keeps track of information needed to calculate the thrust a rocket performs, as well as how much
it weighs. The weight of the rocket engines is an imporant part of the total weight of the rocket.
"""
abstract type Engine end

struct SingleEngine <: Engine
    name::String			# An identifier such as Merlin 1D, RD-180
    thrust::typeof(1.0N)		    # Max amount of thrust engine can produce, measured in Newton.
    Isp::typeof(1.0s)    		# Specific Impulse. A measure of propellant efficiency of engine.
    mass::typeof(1.0kg)			# Mass of rocket engine in Kg
    min_throttle::Float64	# Minimum amount engine can be throttled down, before it has to be shut down entirely
end

struct EngineCluster <: Engine
    engine::SingleEngine
    count::Int8
    Isp::typeof(1.0s)
end

function EngineCluster(e::SingleEngine, c::Number)
    EngineCluster(e, c, e.Isp)
end

struct Tank
   dry_mass::typeof(1.0kg)			# Mass of tank without propellant
   total_mass::typeof(1.0kg)			# Mass of tank with propellant
end


########### Constructors #############################################################################
function Engine(name::AbstractString, thrust::Number, Isp::Number; mass::Number = 0.0, throttle::Number = 1.0, count::Integer = 1)
    engine = SingleEngine(name, thrust, Isp, mass, throttle)
    
    if count > 1
        EngineCluster(engine, count)
    else
       return engine 
    end
end
