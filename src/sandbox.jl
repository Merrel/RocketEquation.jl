
abstract type Super end

struct TypeA <: Super
    name::Symbol
end

struct TypeB <: Super
    name::Symbol
end

struct TypeC <: Super
    name::Symbol
end


struct Alphabet
    a::Super
    b::Super
    c::Super
end


function i_am(x::Super)
    println("I am a Super type")
end

function i_am(x::TypeA)
    println("I am TypeA")
end

function i_am(x::TypeB)
    println("I am TypeB")
end

A = TypeA(:A)
B = TypeB(:B)
C = TypeC(:C)


i_am(A)
i_am(B)
i_am(C)


ABC = Alphabet(A, B, C)

