export ΔVonly, Transfer, StationKeep, TrajCorrection, RPOD,
       burn!, mass_ratio, prop_burned
# -------------------------------------------------------------------------------------------------
# TYPES

abstract type Maneuver end
abstract type AbstractDocking <: Maneuver end
abstract type AbstractStaging <: Maneuver end
abstract type ΔV <: Maneuver end

struct Docking <: AbstractDocking end
struct Staging <: AbstractStaging end

struct ΔVonly <: ΔV
    dV::typeof(1.0m/s)
end

struct Transfer <: ΔV
    src::String
    dst::String
    dV::typeof(1.0m/s)
end

struct StationKeep <: ΔV
    dV::typeof(1.0m/s)
end

struct TrajCorrection <: ΔV
    dV::typeof(1.0m/s)
end

struct RPOD <: ΔV
    vehicleA::SpaceVehicle
    vehicleB::SpaceVehicle
    dV::typeof(1.0m/s)
end

# -------------------------------------------------------------------------------------------------
# FUNCTIONS - Diagnostics

function status(r::Rocket)
    println("  Status")
    println("  - Gross:           $(round(typeof(1kg), gross(r)))")
    println("  - Prop Available:  $(round(typeof(1kg), r.propellant))")
    println("  - Prop Used:       $(round(typeof(1kg), (Starship.tank.total_mass - Starship.tank.dry_mass) - r.propellant))")
end

function mass_ratio(r::Rocket, ΔV::typeof(1.0m/s))
    mf_mo = exp(-ΔV / (g₀ * r.engine.Isp))
    return mf_mo
end

function prop_burned(r::Rocket, ΔV::typeof(1.0m/s))
    m₀ = gross(r)
    mₚ = m₀ - m₀ * exp(-ΔV / (g₀ * r.engine.Isp))
    return mₚ
end

function prop_burned(r::Rocket, ΔV)
    prop_burned(r, ΔV.dV)
end

# -------------------------------------------------------------------------------------------------
# FUNCTIONS - Actions

function burn!(r::Rocket, ΔV::typeof(1.0m/s))
    m₀ = gross(r)
    mₚ = m₀ - m₀ * exp(-ΔV / (g₀ * r.engine.Isp))
    r.propellant -= mₚ
    # try
    #     @assert r.propellant >= 0kg
    # catch
    #     println("!!! ERROR: used too much propellant")
    #     println("    _______________________________")
    # end
    return nothing
end

function burn!(r::Rocket, ΔV)
    burn!(r, ΔV.dV)
end

function burn!(r::Rocket, ΔV; verbose::Bool=false)
    if verbose
        println("\nSegment from $(ΔV.src) -> $(ΔV.dst): $(ΔV.dV)")
    end
    burn!(r, ΔV.dV)
    if verbose
        status(r)
    end
end

function burn!(r::Rocket, ΔV::ΔVonly; verbose::Bool=false)
    if verbose
        println("\nΔV = $(ΔV.dV)")
    end
    burn!(r, ΔV.dV)
    if verbose
        status(r)
    end
end

function burn!(r::Rocket, ΔV::StationKeep; verbose::Bool=false)
    if verbose
        println("\nStationkeepingin $(ΔV.orbit): $(ΔV.dV)")
    end
    burn!(r, ΔV.dV)
    if verbose
        status(r)
    end
end

function burn!(r::Rocket, ΔV::StationKeep; verbose::Bool=false)
    if verbose
        println("\nTrajectory correction during $(ΔV.src) -> $(ΔV.dst): $(ΔV.dV)")
    end
    burn!(r, ΔV.dV)
    if verbose
        status(r)
    end
end


function stage!(r::Rocket)
    # Get the payload as a new standalone object
    upper = r.payload
    # "separate" the active stage by setting it to nopayload
    lower = Rocket(r.name, nopayload, r.tank, r.engine, r.throttle, r.propellant, r.sideboosters)
    return (lower, upper)
end


function dock!(new_primary::Payload, new_payload::Payload)
    new_name = "$(new_primary.name)_$(new_payload.name)"
    Rocket(new_name, new_payload, new_primary.tank, new_primary.engine)
end


function transfer_prop!(recipient::Rocket, donor::Rocket)
    # Add prop to the recipient
    recipient.propellant += donor.propellant
    donor.propellant = 0kg
end

# -------------------------------------------------------------------------------------------------
# Crew Movements

function transfer_crew!(crewed::Rocket, uncrewed::Rocket)
    # Extract the crew
    crew = get_crew(crewed)
    # remove the crew from the old crewed
    new_uncrewed = pop(crewed)
    # Add the crew to the old uncrewed
    new_crewed = add_crew(uncrewed, crew)
    return (new_crewed, new_uncrewed)
end


function pop(r::Rocket)
    elements = Rocket[]
    has_payload = true
    while has_payload
        if hasproperty(r, :payload)
            push!(elements, without_payload(r))
            r = r.payload
        else
            has_payload = false
        end
    end

    # reverse!(elements)
    new_rocket = elements[1]
    for stage in elements[2:end]
        new_rocket = dock!(new_rocket, stage)
    end

    return new_rocket
end

function get_crew(r::Rocket)
    notcrew = true
    while notcrew

        try
            crew = r.payload::CrewPayload
            return crew
        catch TypeError
            r = r.payload
        end
    end
end

function add_crew(r::Rocket, crew::CrewPayload)
    elements = Rocket[]
    has_payload = true
    while has_payload
        if hasproperty(r, :payload)
            push!(elements, without_payload(r))
            r = r.payload
        else
            has_payload = false
        end
    end

    reverse!(elements)
    new_rocket = with_payload(elements[1], crew)
    for stage in elements[2:end]
        new_rocket = dock!(stage, new_rocket)
    end

    return new_rocket
end
