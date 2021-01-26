using OrdinaryDiffEq
using Unitful
using Unitful.DefaultSymbols

# Add additional units to the namespace
hr = u"hr"

# Load sub-modules
include("physics.jl")
include("components.jl")
include("vehicles.jl")
include("maneuvers.jl")
include("properties.jl")
include("boiloff.jl")