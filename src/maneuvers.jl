# -------------------------------------------------------------------------------------------------
# TYPES

abstract type ΔV end

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
# FUNCTIONS

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

function burn!(r::Rocket, ΔV::typeof(1.0m/s))
    m₀ = gross(r)
    mₚ = m₀ - m₀ * exp(-ΔV / (g₀ * r.engine.Isp))
    r.propellant -= mₚ
    return nothing
end

function burn!(r::Rocket, ΔV)
    burn!(r, ΔV.dV)
end

# r = Starship
# m₀ = gross(r)
# mₚ = m₀ - m₀ * exp(-(1000.0m/s) / (g₀ * r.engine.Isp))

# (mₚ)
# prop_burned(r, 1000.0m/s)

# r.propellant -= mₚ

# typeof(r.propellant)
# typeof(mₚ          )