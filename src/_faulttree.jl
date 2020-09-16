"""
FaultTree
"""

export AbstractFaultTreeNode, AbstractFaultTreeOperation, FaultTreeOperation, FaultTreeEvent, FaultTreeKoutofN
export ftevent

abstract type AbstractFaultTreeNode end
abstract type AbstractFaultTreeOperation <: AbstractFaultTreeNode end

struct FaultTreeOperation <: AbstractFaultTreeOperation
    params::Set{Symbol}
    op::Symbol
    args::Vector{AbstractFaultTreeNode}
end

struct FaultTreeKoutofN <: AbstractFaultTreeOperation
    params::Set{Symbol}
    op::Symbol
    k::Int
    args::Vector{AbstractFaultTreeNode}
end

struct FaultTreeEvent <: AbstractFaultTreeNode
    params::Set{Symbol}
    var::Symbol
end

"""
ftree
"""

function ftevent(var::Symbol)
    FaultTreeEvent(Set([var]), var)
end

function ftevent(var::Vararg)
    s = Symbol(var...)
    FaultTreeEvent(Set([s]), s)
end