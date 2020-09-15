"""
tobdd

Create BDD
"""

export bdd!, bdd

using DD

function bdd(top::AbstractFaultTreeNode)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    node = bdd!(forest, top)
    return node, forest
end

function bdd!(forest::BDDForest{Tv,Ti,Tl}, top::AbstractFaultTreeNode) where {Tv,Ti,Tl}
    defval!(forest, Tv(0))
    defval!(forest, Tv(1))
    for (i,x) = enumerate(sort(collect(top.params)))
        defvar!(forest, x, Tl(i), domain([Ti(0), Ti(1)]))
    end
    nodes = Dict{AbstractFaultTreeNode,AbstractDDNode{Tv,Ti}}()
    _tobdd!(top, nodes, forest)
end

function _tobdd!(f::FaultTreeEvent, nodes::Dict{AbstractFaultTreeNode,AbstractDDNode{Tv,Ti}},
    forest::BDDForest{Tv,Ti,Tl})::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    get(nodes, f) do
        v0 = ddval!(forest, Tv(0))
        v1 = ddval!(forest, Tv(1))
        nodes[f] = ddvar!(forest, f.var, v0, v1)
    end
end

function _tobdd!(f::AbstractFaultTreeOperation, nodes::Dict{AbstractFaultTreeNode,AbstractDDNode{Tv,Ti}},
    forest::BDDForest{Tv,Ti,Tl})::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    get(nodes, f) do
        _tobdd!(Val(f.op), f, nodes, forest)
    end
end

function _tobdd!(::Val{:NOT}, f::AbstractFaultTreeOperation, nodes::Dict{AbstractFaultTreeNode,AbstractDDNode{Tv,Ti}},
    forest::BDDForest{Tv,Ti,Tl})::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    bargs = [_tobdd!(x, nodes, forest) for x = f.args]
    @assert length(bargs) == 1
    bddnot!(forest, bargs[1])
end

function _tobdd!(::Val{:AND}, f::AbstractFaultTreeOperation, nodes::Dict{AbstractFaultTreeNode,AbstractDDNode{Tv,Ti}},
    forest::BDDForest{Tv,Ti,Tl})::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    bargs = [_tobdd!(x, nodes, forest) for x = f.args]
    _createAndGate(forest, bargs)
end

function _tobdd!(::Val{:OR}, f::AbstractFaultTreeOperation, nodes::Dict{AbstractFaultTreeNode,AbstractDDNode{Tv,Ti}},
    forest::BDDForest{Tv,Ti,Tl})::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    bargs = [_tobdd!(x, nodes, forest) for x = f.args]
    _createOrGate(forest, bargs)
end

function _tobdd!(::Val{:KofN}, f::AbstractFaultTreeOperation, nodes::Dict{AbstractFaultTreeNode,AbstractDDNode{Tv,Ti}},
    forest::BDDForest{Tv,Ti,Tl})::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    bargs = [_tobdd!(x, nodes, forest) for x = f.args]
    _createKofNGate(forest, f.k, bargs)
end

"""
"""

function _createOrGate(forest::BDDForest{Tv,Ti,Tl}, args)::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    x = args[1]
    for y = args[2:end]
        x = bddor!(forest, x, y)
    end
    x
end

function _createAndGate(forest::BDDForest{Tv,Ti,Tl}, args)::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    x = args[1]
    for y = args[2:end]
        x = bddand!(forest, x, y)
    end
    x
end

function _createKofNGate(forest::BDDForest{Tv,Ti,Tl}, k, args)::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    n = length(args)
    (k == 1) && return _createOrGate(forest, args)
    (k == n) && return _createAndGate(forest, args)
    x = args[1]
    xs = args[2:end]
    bddite!(forest, x, _createKofNGate(forest, k-1, xs), _createKofNGate(forest, k, xs))
end
