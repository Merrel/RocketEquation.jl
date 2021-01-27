using OrdinaryDiffEq
using Unitful
using Unitful.DefaultSymbols

# Add additional units to the namespace
hr =  3600s
day = 24hr

# Load sub-modules
include("physics.jl")
include("components.jl")
include("vehicles.jl")
include("maneuvers.jl")
include("properties.jl")
include("boiloff.jl")
include("utils.jl")