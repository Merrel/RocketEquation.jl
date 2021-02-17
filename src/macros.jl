"""
Add missionlog call to each command
"""
macro mission(commands)
    for arg in commands.args
        if typeof(arg) === Expr
            if length(methods(eval(arg.args[1]))) >= 1
                push!(arg.args, :($(Expr(:kw, :missionlog, mission_log))))
            else
                push!(arg.args[2].args, :($(Expr(:kw, :missionlog, mission_log))))
            end
        end
    end
    # Evaluate the commands and escape them to protect rocket object names
    commands = esc(commands)

    return :($commands)
end

"""
Add verbose=true flag
"""
macro verbose(f)
    push!(f.args, :($(Expr(:ks, :verbose, true))))
    return :($f)
end