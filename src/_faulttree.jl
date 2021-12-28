
abstract type AbstractFTNode end
abstract type AbstractFTOperation <: AbstractFTNode end

struct FTOperation <: AbstractFTOperation
    op::Symbol
    args::Vector{<:AbstractFTNode}
end

struct FTKoutofN <: AbstractFTOperation
    op::Symbol
    k::Int
    args::Vector{<:AbstractFTNode}
end

struct FTEvent <: AbstractFTNode
    label::Symbol
end

function ftevent(label::Symbol)
    FTEvent(label)
end

###

struct SymbolicFTExpression{Tv} <: SymbolicDiff.AbstractSymbolic{Tv}
    params::Set{Symbol}
    op::Symbol
    events::Dict{Symbol,<:SymbolicDiff.AbstractSymbolic{Tv}}
    top::BDD.AbstractNode{Symbol}
    bdd::BDD.BDDForest{Symbol}
end

function Base.show(io::IO, x::SymbolicFTExpression{Tv}) where Tv
    Base.show(io, x.top)
end

function faulttree(events::Dict{Symbol,<:SymbolicDiff.AbstractSymbolic{Tv}}, top::AbstractFTNode) where Tv
    s = union([x.params for (k,x) = events]...)
    b = BDD.bdd(Symbol)
    for (k,x) = events
        BDD.header!(b, k)
    end
    bddtop = _tobdd!(b, top)
    SymbolicFTExpression(s, :ft, events, bddtop, b)
end

"""
macro
"""

macro faulttree(f, block)
    if Meta.isexpr(f, :call)
        events = []
        dict = []
        e = f.args[2:end]
        for v = e
            push!(events, Expr(:(=), v, :(ftevent($(Expr(:quote, v))))))
            push!(dict, Expr(:call, :(=>), Expr(:quote, v), v))
        end
        body = []
        push!(body, Expr(:(=), :events, Expr(:call, :Dict, dict...)))
        push!(body, Expr(:(=), :top, Expr(:let, Expr(:block, events...), block)))
        push!(body, :(faulttree(events, top)))
        esc(Expr(:function, f, Expr(:block, body...)))
    else
        println("error")
    end
end
