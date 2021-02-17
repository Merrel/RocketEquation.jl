
"""
    propellant(r::Rocket)
Total propellant mass in core stage of a rocket, excluding side boosters
"""
propellant(r::Rocket) = r.propellant

max_propellant(t::Tank) = t.total_mass - t.dry_mass

name(r::Rocket) = r.name
name(p::Payload) = p.name

gross(p::Payload) = p.mass
gross(r::Rocket) = gross(r.payload) + r.tank.dry_mass + r.propellant
# inert(r::Rocket) = r.payload.mass + r.tank.dry_mass

pmf(t::Tank) = (t.total_mass-t.dry_mass) / t.total_mass
pmf(r::Rocket) = pmf(r.tank)

#
# Thrust 
#
"""
Get the total thrust of a single engine with throttle at 100%
""" 
thrust(e::SingleEngine) = e.thrust
"""
Get the total thrust of an engine cluster with throttle at 100%. Total = count * thrust per engine
""" 
thrust(e::EngineCluster) = e.engine.thrust * e.count
"""
Get the total thrust of a rocket with throttle at 100%. Total = count * thrust per engine
""" 
thrust(r::Rocket) = thrust(r.engine)

#
# Rocket Thrust to Weight
#
"""
Compute the instantaneous thrust to weight for a rocket considering 100% throttle 
and full gross mass (including any payload)
"""
t2w(r::Rocket) = ustrip(thrust(r) / gross(r))



function available_ΔV(r::Rocket)
    mo_mf = gross(r) / (gross(r) - r.propellant)
    Δv = log(mo_mf) * g₀ * r.engine.Isp
end
