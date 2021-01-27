#
# Console logging functions
#

function print_location(loc::String)
    loc_to_console = "\n" * "-"^(45 - length(loc) - 1) * " " * loc
    println(loc_to_console)
end