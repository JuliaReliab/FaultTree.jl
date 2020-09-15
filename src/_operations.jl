"""
FaultTree
"""

export ftkofn, ftand, ftor, ftnot

import Base

function Base.:*(x::AbstractFaultTreeNode, y::AbstractFaultTreeNode)
    ftand(x, y)
end

function Base.:&(x::AbstractFaultTreeNode, y::AbstractFaultTreeNode)
    ftand(x, y)
end

function Base.:+(x::AbstractFaultTreeNode, y::AbstractFaultTreeNode)
    ftor(x, y)
end

function Base.:|(x::AbstractFaultTreeNode, y::AbstractFaultTreeNode)
    ftor(x, y)
end

function Base.:!(x::AbstractFaultTreeNode)
    ftnot(x)
end

function Base.:~(x::AbstractFaultTreeNode)
    ftnot(x)
end

function ftand(x::Vararg{AbstractFaultTreeNode})
    s = union([y.params for y = x]...)
    args = [y for y = x]
    FaultTreeOperation(s, :AND, args)
end

function ftor(x::Vararg{AbstractFaultTreeNode})
    s = union([y.params for y = x]...)
    args = [y for y = x]
    FaultTreeOperation(s, :OR, args)
end

function ftnot(x::AbstractFaultTreeNode)
    FaultTreeOperation(x.params, :NOT, [x])
end

function ftkofn(k::Int, x::Vararg{AbstractFaultTreeNode})
    s = union([y.params for y = x]...)
    args = [y for y = x]
    FaultTreeKoutofN(s, :KofN, k, args)
end
