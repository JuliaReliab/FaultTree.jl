"""
tobdd

Create BDD
"""

export tobdd!, tobdd
using DD

function tobdd(top::AbstractFaultTreeNode)
    b = BDD()
    node = tobdd!(b, top)
    return node, b
end

function tobdd!(b::BDD{Ts}, top::AbstractFaultTreeNode) where Ts
    nodes = Dict()
    for x = sort(collect(top.params))
        nodes[x] = var(b, x)
    end
    _tobdd!(top, nodes, b)
end

function _tobdd!(f::FaultTreeEvent, nodes, b)
    b.var(f.var)
end

function _tobdd!(f::AbstractFaultTreeOperation, nodes, b)
    _tobdd!(Val(f.op), f, nodes, b)
end

function _tobdd!(::Val{:NOT}, f::AbstractFaultTreeOperation, nodes::Dict{Symbol,Tuple{AbstractBDDNode{Ts},Bool}}, b::BDD{Ts})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    bargs = [_tobdd!(x, nodes, b) for x = f.args]
    @assert length(bargs) == 1
    bddnot(b, bargs[1])
end

function _tobdd!(::Val{:AND}, f::AbstractFaultTreeOperation, nodes::Dict{Symbol,Tuple{AbstractBDDNode{Ts},Bool}}, b::BDD{Ts})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    bargs = [_tobdd!(x, nodes, b) for x = f.args]
    bddand(b, bargs...)
end

function _tobdd!(::Val{:OR}, f::AbstractFaultTreeOperation, nodes::Dict{Symbol,Tuple{AbstractBDDNode{Ts},Bool}}, b::BDD{Ts})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    bargs = [_tobdd!(x, nodes, b) for x = f.args]
    bddor(b, bargs...)
end

function _tobdd!(::Val{:KofN}, f::AbstractFaultTreeOperation, nodes::Dict{Symbol,Tuple{AbstractBDDNode{Ts},Bool}}, b::BDD{Ts})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    bargs = [_tobdd!(x, nodes, b) for x = f.args]
    _createKofNGate(b, f.k, bargs)
end

"""
"""

function _createKofNGate(b::BDD{Ts}, k, args) where Ts
    n = length(args)
    (k == 1) && return bddor(b, args...)
    (k == n) && return bddand(b, args...)
    x = args[1]
    xs = args[2:end]
    bddite(b, x, _createKofNGate(b, k-1, xs), _createKofNGate(b, k, xs))
end
