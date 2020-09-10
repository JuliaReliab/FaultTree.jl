"""
tobdd

Create BDD
"""

export tobdd!, tobdd
using DD: BDDForest, DDValue, AbstractDDNode, defval!,defvar!, bddvars!, bddand!, bddor!, bddite!, bddnot!, domain, FullyReduced

function tobdd(top::AbstractFaultTreeNode)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    node = tobdd!(forest, top)
    return node, forest
end

function tobdd!(forest::BDDForest{Tv,Ti,Tl}, top::AbstractFaultTreeNode) where {Tv,Ti,Tl}
    defval!(forest, Tv(0))
    defval!(forest, Tv(1))
    vars = Symbol[]
    _getvars!(top, Set{AbstractFaultTreeNode}(), vars)
    for (i,x) = enumerate(sort(vars))
        defvar!(forest, x, Tl(i), domain([Ti(0), Ti(1)]))
    end
    vars = bddvars!(forest, Tv(0), Tv(1))
    _tobdd!(top, Set{AbstractFaultTreeNode}(), forest, vars)
end

function _getvars!(f::FaultTreeEvent, visited::Set{AbstractFaultTreeNode}, vars::Vector{Symbol})
    (f in visited) && return nothing
    push!(visited, f)
    push!(vars, f.var)
    nothing
end

function _getvars!(f::AbstractFaultTreeOperation, visited::Set{AbstractFaultTreeNode}, vars::Vector{Symbol})
    (f in visited) && return nothing
    push!(visited, f)
    for x = f.args
        _getvars!(x, visited, vars)
    end
    nothing
end

function _tobdd!(f::FaultTreeEvent, visited::Set{AbstractFaultTreeNode},
    forest::BDDForest{Tv,Ti,Tl}, vars::Dict{Symbol,AbstractDDNode{Tv,Ti}})::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    vars[f.var]
end

function _tobdd!(f::AbstractFaultTreeOperation, visited::Set{AbstractFaultTreeNode},
    forest::BDDForest{Tv,Ti,Tl}, vars::Dict{Symbol,AbstractDDNode{Tv,Ti}})::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    (f in visited) && return nothing
    _tobdd!(Val(f.op), f, visited, forest, vars)
end

function _tobdd!(::Val{:NOT}, f::AbstractFaultTreeOperation, visited::Set{AbstractFaultTreeNode},
    forest::BDDForest{Tv,Ti,Tl}, vars::Dict{Symbol,AbstractDDNode{Tv,Ti}})::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    bargs = [_tobdd!(x, visited, forest, vars) for x = f.args]
    @assert length(bargs) == 1
    bddnot!(forest, bargs[1])
end

function _tobdd!(::Val{:AND}, f::AbstractFaultTreeOperation, visited::Set{AbstractFaultTreeNode},
    forest::BDDForest{Tv,Ti,Tl}, vars::Dict{Symbol,AbstractDDNode{Tv,Ti}})::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    bargs = [_tobdd!(x, visited, forest, vars) for x = f.args]
    _createAndGate(forest, bargs)
end

function _tobdd!(::Val{:OR}, f::AbstractFaultTreeOperation, visited::Set{AbstractFaultTreeNode},
    forest::BDDForest{Tv,Ti,Tl}, vars::Dict{Symbol,AbstractDDNode{Tv,Ti}})::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    bargs = [_tobdd!(x, visited, forest, vars) for x = f.args]
    _createOrGate(forest, bargs)
end

function _tobdd!(::Val{:KofN}, f::AbstractFaultTreeOperation, visited::Set{AbstractFaultTreeNode},
    forest::BDDForest{Tv,Ti,Tl}, vars::Dict{Symbol,AbstractDDNode{Tv,Ti}})::AbstractDDNode{Tv,Ti} where {Tv,Ti,Tl}
    bargs = [_tobdd!(x, visited, forest, vars) for x = f.args]
    _createKofNGate(forest, f.k, bargs)
end

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
