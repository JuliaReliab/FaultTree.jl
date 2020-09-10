"""
FaultTree
"""

export AbstractFaultTreeNode, AbstractFaultTreeOperation, FaultTreeOperation, FaultTreeEvent, FaultTreeKoutofN, ftree

abstract type AbstractFaultTreeNode end
abstract type AbstractFaultTreeOperation <: AbstractFaultTreeNode end

struct FaultTreeOperation <: AbstractFaultTreeOperation
    op::Symbol
    args::Vector{AbstractFaultTreeNode}
end

struct FaultTreeKoutofN <: AbstractFaultTreeOperation
    op::Symbol
    k::Int
    args::Vector{AbstractFaultTreeNode}
end

struct FaultTreeEvent <: AbstractFaultTreeNode
    var::Symbol
end

"""
ftree
"""

function ftree(x::Any)
    nothing
end

function ftree(var::Symbol)
    FaultTreeEvent(var)
end

function ftree(x::Bool)
    FaultTreeEvent(Symbol(x))
end

const operations = [:&, :|, :~, :ftand, :ftor, :ftnot]

function ftree(expr::Expr)
    if Meta.isexpr(expr, :call) && expr.args[1] in operations
        args = [ftree(x) for x = expr.args[2:end]]
        eval(Expr(:call, expr.args[1], args...))
    elseif Meta.isexpr(expr, :call) && expr.args[1] == :ftkofn
        args = [ftree(x) for x = expr.args[3:end]]
        eval(Expr(:call, expr.args[1], expr.args[2], args...))
    else
        nothing
    end
end

