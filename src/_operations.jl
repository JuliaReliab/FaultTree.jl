"""
FaultTree
"""

export ftkofn, ftand, ftor, ftnot

import Base

function Base.:&(x::AbstractFaultTreeNode, y::AbstractFaultTreeNode)
    ftand(x, y)
end

function Base.:|(x::AbstractFaultTreeNode, y::AbstractFaultTreeNode)
    ftor(x, y)
end

function Base.:~(x::AbstractFaultTreeNode)
    ftnot(x)
end

function ftand(x::Vararg{AbstractFaultTreeNode})
    args = [y for y = x]
    FaultTreeOperation(:AND, args)
end

function ftor(x::Vararg{AbstractFaultTreeNode})
    args = [y for y = x]
    FaultTreeOperation(:OR, args)
end

function ftnot(x::AbstractFaultTreeNode)
    FaultTreeOperation(:NOT, [x])
end

function ftkofn(k::Int, x::Vararg{AbstractFaultTreeNode})
    args = [y for y = x]
    FaultTreeKoutofN(:KofN, k, args)
end
