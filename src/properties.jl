
"""
    propellant(r::Rocket)
Total propellant mass in core stage of a rocket, excluding side boosters
"""
propellant(r::Rocket)          = r.propellant

max_propellant(t::Tank)        = t.total_mass - t.dry_mass

gross(r::Rocket) = r.payload.mass + r.tank.total_mass
inert(r::Rocket) = r.payload.mass + r.tank.dry_mass
