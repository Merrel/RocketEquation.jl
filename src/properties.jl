
"""
    propellant(r::Rocket)
Total propellant mass in core stage of a rocket, excluding side boosters
"""
propellant(r::Rocket) = r.propellant

max_propellant(t::Tank) = t.total_mass - t.dry_mass

gross(p::Payload) = p.mass
gross(r::Rocket) = gross(r.payload) + r.tank.dry_mass + r.propellant
# inert(r::Rocket) = r.payload.mass + r.tank.dry_mass

pmf(t::Tank) = (t.total_mass-t.dry_mass) / t.total_mass
pmf(r::Rocket) = pmf(r.tank)

function available_ΔV(r::Rocket)
    mo_mf = gross(r) / (gross(r) - r.propellant)
    Δv = log(mo_mf) * g₀ * r.engine.Isp
end
