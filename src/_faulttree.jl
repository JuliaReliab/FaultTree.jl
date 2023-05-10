export AbstractFTObject
export getft
export AbstractFTGate
export AbstractFTEvent
export FTAndGate
export FTOrGate
export FTKofNGate
export FTBasicEvent
export FTIntermediateEvent
export FTRepeatEvent
export ftree
export ftbasic
export ftintermediate
export ftrepeat
export ftand
export ftor
export ftkofn

"""
    AbstractFTObject

Abstract type for fault tree objects.
"""
abstract type AbstractFTObject end

"""
    AbstractFTGate <: AbstractFTObject

Abstract type for fault tree gates.

### Notes

Every concrete `AbstractFTGate` must have the following fields:
- `args`: a vector of FTNode
"""
abstract type AbstractFTGate <: AbstractFTObject end

"""
    AbstractFTEvent <: AbstractFTObject

Abstract type for fault tree events.

### Fileds
- `x`: the symbol indentifying the event
"""
abstract type AbstractFTEvent <: AbstractFTObject end

"""
    symbol(x)

Get a symbol of ftevent.
"""
function symbol(x::AbstractFTEvent)
    x.x
end

"""
    FTAndGate <: AbstractFTGate

AND gate

### Fileds
- `args`: a vector of FTNode
"""
mutable struct FTAndGate <: AbstractFTGate
    args::Vector{<:AbstractFTObject}

    function FTAndGate(args::Vector{<:AbstractFTObject})
        new(args)
    end
end

"""
    FTOrGate <: AbstractFTGate

OR gate

### Fileds
- `args`: a vector of FTNode
"""
mutable struct FTOrGate <: AbstractFTGate
    args::Vector{<:AbstractFTObject}

    function FTOrGate(args::Vector{<:AbstractFTObject})
        new(args)
    end
end

"""
    FTKofNGate <: AbstractFTGate

k-out-of-N gate

### Fileds
- `args`: a vector of FTNode
- `k`: an integer indicating K
"""
mutable struct FTKofNGate <: AbstractFTGate
    args::Vector{<:AbstractFTObject}
    k::Int

    function FTKofNGate(args::Vector{<:AbstractFTObject}, k::Int)
        new(args, k)
    end
end

"""
    FTBasicEvent <: AbstractFTEvent

Basic event

### Fileds
- `x`: the symbol indentifying the event
"""
mutable struct FTBasicEvent <: AbstractFTEvent
    x::Symbol

    function FTBasicEvent(x::Symbol)
        new(x)
    end
end

"""
    FTRepeatEvent <: AbstractFTEvent

Repeat event

### Fileds
- `x`: the symbol indentifying the event
"""
mutable struct FTRepeatEvent <: AbstractFTEvent
    x::Symbol

    function FTRepeatEvent(x::Symbol)
        new(x)
    end
end

"""
    FTIntermediateEvent <: AbstractFTEvent

Intermediate event

### Fileds
- `x`: the symbol indentifying the event
"""
mutable struct FTIntermediateEvent <: AbstractFTEvent
    x::AbstractFTGate

    function FTIntermediateEvent(x::AbstractFTGate)
        new(x)
    end
end

### constructors

"""
    ftbasic(x)

Create an FTBasicEvent.
"""
function ftbasic(x::Symbol)
    FTBasicEvent(x)
end

"""
    ftrepeat(x)

Create an FTRpeatEvent.
"""
function ftrepeat(x::Symbol)
    FTRepeatEvent(x)
end

"""
    ftintermediate(x)

Create an FTRpeatEvent.
"""
function ftintermediate(x::AbstractFTGate)
    FTIntermediateEvent(x)
end

"""
    ftand(x, y...)

Create an AND gate with x, y...
"""
function ftand(x::AbstractFTObject, y::Vararg{AbstractFTObject})
    args = AbstractFTObject[x, y...]
    FTAndGate(args)
end

"""
    ftor(x, y...)

Create an OR gate with x, y...
"""
function ftor(x::AbstractFTObject, y::Vararg{AbstractFTObject})
    args = AbstractFTObject[x, y...]
    FTOrGate(args)
end

"""
    ftkofn(k::Int, x, y...)

Create an K-out-of-N gate with x, y...
"""
function ftkofn(k::Int, x::AbstractFTObject, y::Vararg{AbstractFTObject})
    args = AbstractFTObject[x, y...]
    FTKofNGate(args, k)
end

### overloads

function Base.show(io::IO, x::AbstractFTEvent)
    Base.show(io, symbol(x))
end

function Base.show(io::IO, x::AbstractFTGate)
    Base.show(io, objectid(x))
end

function Base.:*(x::AbstractFTObject, y::AbstractFTObject)
    ftand(x, y)
end

function Base.:&(x::AbstractFTObject, y::AbstractFTObject)
    ftand(x, y)
end

function Base.:+(x::AbstractFTObject, y::AbstractFTObject)
    ftor(x, y)
end

function Base.:|(x::AbstractFTObject, y::AbstractFTObject)
    ftor(x, y)
end

# """
# macro
# """

# macro basic(m, block)
#     if Meta.isexpr(block, :block)
#         body = [_genbasic(x, m) for x = block.args]
#         esc(Expr(:block, body...))
#     else
#         esc(_genbasic(block, m))
#     end
# end

# function _genbasic(x::Any, m)
#     x
# end

# function _genbasic(x::Expr, m)
#     if Meta.isexpr(x, :(=))
#         label = x.args[1]
#         p = x.args[2]
#         Expr(:block,
#             Expr(:(=), Expr(:ref, m, Expr(:quote, label)), p),
#             Expr(:(=), label, Expr(:call, :ftbasic, Expr(:quote, label)))
#         )
#     else
#         throw(TypeError(x, "Invalid format for basic event"))
#     end
# end

# macro repeat(m, block)
#     if Meta.isexpr(block, :block)
#         body = [_genrepeat(x, m) for x = block.args]
#         esc(Expr(:block, body...))
#     else
#         esc(_genrepeat(block, m))
#     end
# end

# function _genrepeat(x::Any, m)
#     x
# end

# function _genrepeat(x::Expr, m)
#     if Meta.isexpr(x, :(=))
#         label = x.args[1]
#         p = x.args[2]
#         Expr(:block,
#             Expr(:(=), Expr(:ref, m, Expr(:quote, label)), p),
#             Expr(:(=), label, Expr(:call, :ftrepeat, Expr(:quote, label)))
#         )
#     else
#         throw(TypeError(x, "Invalid format for repeated event"))
#     end
# end

# macro ftree(f, block)
#     body = []
#     env = gensym()
#     top = gensym()
#     if Meta.isexpr(block, :block)
#         for x = block.args
#             push!(body, _replace_macro(x, env))
#         end
#     end
#     expr = Expr(:block,
#         Expr(:(=), env, Expr(:call, :Dict)),
#         Expr(:(=), top, Expr(:let, Expr(:block), Expr(:block, body...)))
#     )
#     esc(Expr(:function, f,
#         Expr(:block,
#             expr,
#             Expr(:call, :ftree, top, env)
#         )
#     ))
# end

# function _replace_macro(x::Any, env)
#     x
# end

# function _replace_macro(x::Expr, env)
#     if Meta.isexpr(x, :macrocall) && (x.args[1] == Symbol("@basic") || x.args[1] == Symbol("@repeat"))
#         Expr(:macrocall, x.args[1], x.args[2], env, [_replace_macro(u, env) for u = x.args[3:end]]...)
#     else
#         Expr(x.head, [_replace_macro(u, env) for u = x.args]...)
#     end
# end
