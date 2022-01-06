
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

mutable struct FTEvent <: AbstractFTNode
    label::Symbol
end

function ftevent(label::Symbol)
    FTEvent(label)
end

function Base.show(io::IO, x::FTEvent)
    Base.show(io, x.label)
end

###

struct FTree{Tv}
    top::BDD.AbstractNode{FTEvent}
    bdd::BDD.BDDForest{FTEvent}
    events::Dict{Symbol,Tv}
end

function Base.show(io::IO, x::FTree{Tv}) where Tv
    Base.show(io, x.top)
end

function ftree(top::AbstractFTNode, events)
    b = BDD.bdd(FTEvent)
    bddtop = _tobdd!(b, top, events)
    FTree(bddtop, b, Dict(k=>v[1] for (k,v) = events))
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
            Expr(:(=), Expr(:ref, m, Expr(:quote, label)), Expr(:tuple, p, Expr(:quote, :basic))),
            Expr(:(=), label, Expr(:call, :ftevent, Expr(:quote, label)))
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
        Expr(:(=), Expr(:ref, m, Expr(:quote, label)), Expr(:tuple, p, Expr(:quote, :repeat))),
        Expr(:(=), label, Expr(:call, :ftevent, Expr(:quote, label)))
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

# macro ftree(f, block)
#     if Meta.isexpr(f, :call)
#         events = []
#         dict = []
#         e = f.args[2:end]
#         for v = e
#             push!(events, Expr(:(=), v, :(ftevent($(Expr(:quote, v))))))
#             push!(dict, Expr(:call, :(=>), Expr(:quote, v), v))
#         end
#         body = []
#         push!(body, Expr(:(=), :events, Expr(:call, :Dict, dict...)))
#         push!(body, Expr(:(=), :top, Expr(:let, Expr(:block, events...), block)))
#         push!(body, :(faulttree(events, top)))
#         esc(Expr(:function, f, Expr(:block, body...)))
#     else
#         println("error")
#     end
# end

# struct SymbolicFTExpression{Tv} <: SymbolicDiff.AbstractSymbolic{Tv}
#     params::Set{Symbol}
#     op::Symbol
#     events::Dict{Symbol,<:SymbolicDiff.AbstractSymbolic{Tv}}
#     top::BDD.AbstractNode{FTEvent}
#     bdd::BDD.BDDForest{FTEvent}
# end

# function Base.show(io::IO, x::SymbolicFTExpression{Tv}) where Tv
#     Base.show(io, x.top)
# end

# function faulttree(events::Dict{Symbol,<:SymbolicDiff.AbstractSymbolic{Tv}}, top::AbstractFTNode) where Tv
#     s = union([x.params for (k,x) = events]...)
#     b = BDD.bdd(FTEvent)
#     # for (k,x) = events
#     #     BDD.header!(b, ftevent(k))
#     # end
#     bddtop = _tobdd!(b, top)
#     SymbolicFTExpression(s, :ft, events, bddtop, b)
# end

"""
macro
"""

# function _basic(expr, env)
#     if Meta.isexpr(expr, :(=))
#         Expr(:(=), Expr(:ref, env, Expr(:quote, expr.args[1])), expr.args[2])
#     else
#         expr
#     end
# end

# macro basic(expr, env)
#     body = []
#     if Meta.isexpr(expr, :block)
#         for x = expr.args
#             push!(body, _basic(x, env))
#         end
#     else
#         push!(body, _basic(expr, env))
#     end
#     e = Expr(:block, body...)
#     esc(e)
# end

# macro faulttree(f, block)
#     if Meta.isexpr(f, :call)
#         events = []
#         dict = []
#         e = f.args[2:end]
#         for v = e
#             push!(events, Expr(:(=), v, :(ftevent($(Expr(:quote, v))))))
#             push!(dict, Expr(:call, :(=>), Expr(:quote, v), v))
#         end
#         body = []
#         push!(body, Expr(:(=), :events, Expr(:call, :Dict, dict...)))
#         push!(body, Expr(:(=), :top, Expr(:let, Expr(:block, events...), block)))
#         push!(body, :(faulttree(events, top)))
#         esc(Expr(:function, f, Expr(:block, body...)))
#     else
#         println("error")
#     end
# end

# macro faulttree(f, block)
#     if Meta.isexpr(f, :call)
#         events = []
#         dict = []
#         e = f.args[2:end]
#         for v = e
#             push!(events, Expr(:(=), v, :(ftevent($(Expr(:quote, v))))))
#             push!(dict, Expr(:call, :(=>), Expr(:quote, v), v))
#         end
#         body = []
#         push!(body, Expr(:(=), :events, Expr(:call, :Dict, dict...)))
#         push!(body, Expr(:(=), :top, Expr(:let, Expr(:block, events...), block)))
#         push!(body, :(faulttree(events, top)))
#         esc(Expr(:function, f, Expr(:block, body...)))
#     else
#         println("error")
#     end
# end
