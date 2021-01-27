using Unitful
using Unitful.DefaultSymbols
import Base.-
export ΔVonly, Transfer, StationKeep, TrajCorrection, RPOD,
       burn!, mass_ratio, prop_burned
# -------------------------------------------------------------------------------------------------
# TYPES

abstract type Maneuver end
abstract type AbstractDocking <: Maneuver end
abstract type AbstractStaging <: Maneuver end
abstract type AbstractCrewTransfer <: Maneuver end
abstract type ΔV <: Maneuver end

struct Docking <: AbstractDocking end
struct Staging <: AbstractStaging end
struct CrewTransfer <: AbstractCrewTransfer end

struct ΔVonly <: ΔV
    dV::typeof(1.0m/s)
end

struct Transfer <: ΔV
    src::String
    dst::String
    dV::typeof(1.0m/s)
end

struct StationKeep <: ΔV
    orbit::String
    dV::typeof(1.0m/s)
end

struct TrajCorrection <: ΔV
    transfer::Transfer
    dV::typeof(1.0m/s)
end

struct RPOD <: ΔV
    vehicleA::SpaceVehicle
    vehicleB::SpaceVehicle
    dV::typeof(1.0m/s)
end

-(x::ΔV, y::ΔV) = ΔVonly(x.dV - y.dV)
-(x::Transfer, y::Transfer) = Transfer(y.src, y.dst, x.dV - y.dV)

# -------------------------------------------------------------------------------------------------
# FUNCTIONS - Diagnostics

function status(r::Rocket)
    println("  $(r.name)")
    println("  - Gross:           $(round(typeof(1kg), gross(r)))")
    println("  - Prop Available:  $(round(typeof(1kg), r.propellant))")
    println("  - Prop Used:       $(round(typeof(1kg), (r.tank.total_mass - r.tank.dry_mass) - r.propellant))")
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

function begin_mission()
    println("\n=============================================\nBegin Mission")
    missionlog = DataFrame(
        Event = Type[], Start=String[], End=String[], ΔV = [], VehicleName=String[], VehicleGross=[], ActiveName=String[], ActiveProp = []
    )
    return missionlog
end


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

function burn!(r::Rocket, ΔV::Transfer; verbose::Bool=false, missionlog=nothing)
    if verbose
        println("\nSegment from $(ΔV.src) -> $(ΔV.dst): $(ΔV.dV)")
    end
    burn!(r, ΔV.dV)
    if verbose
        status(r)
    end
    # Mission Logging
    if missionlog != nothing
        push!(missionlog, [typeof(ΔV) ΔV.src ΔV.dst ΔV.dV name(r) gross(r) split(r.name, " >> ")[1] propellant(r)])
    end
    return nothing
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

function burn!(r::Rocket, ΔV::StationKeep; verbose::Bool=false, missionlog=nothing)
    if verbose
        println("\nStation-keeping $(ΔV.orbit): $(ΔV.dV)")
    end
    burn!(r, ΔV.dV)
    if verbose
        status(r)
    end
    # Mission Logging
    if missionlog != nothing
        push!(missionlog, [typeof(ΔV) ΔV.orbit ΔV.orbit ΔV.dV name(r) gross(r) split(r.name, " >> ")[1] propellant(r)])
    end
    return nothing
end

function burn!(r::Rocket, ΔV::TrajCorrection; verbose::Bool=false, missionlog=nothing)
    if verbose
        println("\nTrajectory correction during $(ΔV.transfer.src) -> $(ΔV.transfer.dst): $(ΔV.transfer.dV)")
    end
    burn!(r, ΔV.dV)
    if verbose
        status(r)
    end
    # Mission Logging
    if missionlog != nothing
        push!(missionlog, [typeof(ΔV) ΔV.transfer.src ΔV.transfer.dst ΔV.transfer.dV name(r) gross(r) split(r.name, " >> ")[1] propellant(r)])
    end
    return nothing
end


function stage!(r::Rocket; missionlog=nothing)
    # Get the payload as a new standalone object
    upper = r.payload
    # "separate" the active stage by setting it to nopayload
    lower = Rocket(split(r.name, " >> ")[1], nopayload, r.tank, r.engine, r.throttle, r.propellant, r.sideboosters)

    if missionlog != nothing
        push!(missionlog, [Staging last(missionlog).End last(missionlog).End 0m/s name(lower) gross(lower) split(lower.name, " >> ")[1] propellant(lower)])
        push!(missionlog, [Staging last(missionlog).End last(missionlog).End 0m/s name(upper) gross(upper) split(upper.name, " >> ")[1] propellant(upper)])
    end
    return (lower, upper)
end


function dock!(new_primary::Payload, new_payload::Payload)
    new_name = "$(new_primary.name) >> $(new_payload.name)"
    Rocket(new_name, new_payload, new_primary.tank, new_primary.engine)
end


function transfer_prop!(recipient::Rocket, donor::Rocket)
    # Add prop to the recipient
    recipient.propellant += donor.propellant
    donor.propellant = 0kg
end

# -------------------------------------------------------------------------------------------------
# Crew Movements

function transfer_crew!(crewed::Rocket, uncrewed::Rocket; missionlog=nothing)
    # Extract the crew
    crew = get_crew(crewed)
    # remove the crew from the old crewed
    new_uncrewed = pop(crewed)
    # Add the crew to the old uncrewed
    new_crewed = add_crew(uncrewed, crew)

    if missionlog != nothing
        push!(missionlog, [CrewTransfer last(missionlog).End last(missionlog).End 0m/s name(new_uncrewed) gross(new_uncrewed) split(new_uncrewed.name, " >> ")[1] propellant(new_uncrewed)])
        push!(missionlog, [CrewTransfer last(missionlog).End last(missionlog).End 0m/s name(new_crewed) gross(new_crewed) split(new_crewed.name, " >> ")[1] propellant(new_crewed)])
    end

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
    # new_rocket.name = split(new_rocket.name, " >> ")[1]
    new_rocket = elements[1]
    new_rocket.name = split(new_rocket.name, " >> ")[1]

    for stage in elements[2:end]
        stage.name = split(stage.name, " >> ")[1]
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
