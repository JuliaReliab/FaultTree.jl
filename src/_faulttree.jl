
abstract type AbstractFTNode end
abstract type AbstractFTOperation <: AbstractFTNode end

mutable struct FTOperation <: AbstractFTOperation
    op::Symbol
    args::Vector{<:AbstractFTNode}
end

mutable struct FTKoutofN <: AbstractFTOperation
    op::Symbol
    k::Int
    args::Vector{<:AbstractFTNode}
end

abstract type AbstractFTEvent <: AbstractFTNode end

mutable struct FTRepeatEvent <: AbstractFTEvent
    label::Symbol
end

mutable struct FTBasicEvent <: AbstractFTEvent
    label::Symbol
end

function ftbasic(label::Symbol)
    FTBasicEvent(label)
end

function ftrepeat(label::Symbol)
    FTRepeatEvent(label)
end

function Base.show(io::IO, x::AbstractFTEvent)
    Base.show(io, x.label)
end

###

mutable struct FTree{Tv}
    top::BDD.AbstractNode{AbstractFTEvent}
    bdd::BDD.BDDForest{AbstractFTEvent}
    events::Dict{Symbol,Tv}
end

function Base.show(io::IO, x::FTree{Tv}) where Tv
    Base.show(io, x.top)
end

function ftree(top::AbstractFTNode, events)
    b = BDD.bdd(AbstractFTEvent)
    bddtop = _tobdd!(b, top)
    FTree(bddtop, b, Dict(k=>v for (k,v) = events))
end

"""
macro
"""

macro basic(m, block)
    if Meta.isexpr(block, :block)
        body = [_genbasic(x, m) for x = block.args]
        esc(Expr(:block, body...))
    else
        esc(_genbasic(block, m))
    end
end

function _genbasic(x::Any, m)
    x
end

function _genbasic(x::Expr, m)
    if Meta.isexpr(x, :(=))
        label = x.args[1]
        p = x.args[2]
        Expr(:block,
            Expr(:(=), Expr(:ref, m, Expr(:quote, label)), p),
            Expr(:(=), label, Expr(:call, :ftbasic, Expr(:quote, label)))
        )
    else
        throw(TypeError(x, "Invalid format for basic event"))
    end
end

macro repeat(m, block)
    if Meta.isexpr(block, :block)
        body = [_genrepeat(x, m) for x = block.args]
        esc(Expr(:block, body...))
    else
        esc(_genrepeat(block, m))
    end
end

function _genrepeat(x::Any, m)
    x
end

function _genrepeat(x::Expr, m)
    if Meta.isexpr(x, :(=))
        label = x.args[1]
        p = x.args[2]
        Expr(:block,
            Expr(:(=), Expr(:ref, m, Expr(:quote, label)), p),
            Expr(:(=), label, Expr(:call, :ftrepeat, Expr(:quote, label)))
        )
    else
        throw(TypeError(x, "Invalid format for repeated event"))
    end
end

macro ftree(f, block)
    body = []
    env = gensym()
    top = gensym()
    if Meta.isexpr(block, :block)
        for x = block.args
            push!(body, _replace_macro(x, env))
        end
    end
    expr = Expr(:block,
        Expr(:(=), env, Expr(:call, :Dict)),
        Expr(:(=), top, Expr(:let, Expr(:block), Expr(:block, body...)))
    )
    esc(Expr(:function, f,
        Expr(:block,
            expr,
            Expr(:call, :ftree, top, env)
        )
    ))
end

function _replace_macro(x::Any, env)
    x
end

function _replace_macro(x::Expr, env)
    if Meta.isexpr(x, :macrocall) && (x.args[1] == Symbol("@basic") || x.args[1] == Symbol("@repeat"))
        Expr(:macrocall, x.args[1], x.args[2], env, [_replace_macro(u, env) for u = x.args[3:end]]...)
    else
        Expr(x.head, [_replace_macro(u, env) for u = x.args]...)
    end
end
