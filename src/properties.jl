
"""
    propellant(r::Rocket)
Total propellant mass in core stage of a rocket, excluding side boosters
"""
propellant(r::Rocket)          = r.propellant

max_propellant(t::Tank)        = t.total_mass - t.dry_mass

gross(p::Payload) = p.mass
gross(r::Rocket) = gross(r.payload) + r.tank.dry_mass + r.propellant
# inert(r::Rocket) = r.payload.mass + r.tank.dry_mass

