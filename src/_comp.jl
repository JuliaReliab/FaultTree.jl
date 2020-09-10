"""
comp prob
"""

export ftprob!, ftprob
using DD: BDDForest, DDValue, DDVariable, defval!,defvar!, bddvars!, bddand!, bddor!, bddite!, bddnot!, domain


function ftprob(f::AbstractFaultTreeNode, vars::Dict{Symbol,Tx}) where Tx
    bdd, = tobdd(f)
    return ftprob(bdd, vars)
end

function ftprob(f::AbstractDDNode{Tv,Ti}, vars::Dict{Symbol,Tx}) where {Tv,Ti,Tx}
    cache = Dict{AbstractDDNode{Tv,Ti},Tx}()
    return ftprob!(f, vars, cache)
end

function ftprob!(f::DDVariable{Tv,Ti,2}, vars::Dict{Symbol,Tx}, cache::Dict{AbstractDDNode{Tv,Ti},Tx}) where {Tv,Ti,Tx}
    get(cache, f) do
        res = [ftprob!(x, vars, cache) for x = f.nodes]
        p = vars[f.label]
        cache[f] = (1-p) * res[1] + p * res[2]
    end
end

function ftprob!(f::DDValue{Tv,Ti}, vars::Dict{Symbol,Tx}, cache::Dict{AbstractDDNode{Tv,Ti},Tx}) where {Tv,Ti,Tx}
    (f.val == Tv(0)) ? Tx(0) : Tx(1)
end

