"""
comp prob
"""

export fteval!, fteval, ftevalgen!

using DD

"""
eval
"""

function fteval(f::AbstractFaultTreeNode, env::Dict{Symbol,Tx}) where Tx
    top, = bdd(f)
    return fteval(top, env)
end

function fteval(f::AbstractDDNode{Tv,Ti}, env::Dict{Symbol,Tx}) where {Tv,Ti,Tx}
    cache = Dict{AbstractDDNode{Tv,Ti},Tx}()
    return fteval!(f, env, cache)
end

function fteval!(f::DDVariable{Tv,Ti,2}, env::Dict{Symbol,Tx}, cache::Dict{AbstractDDNode{Tv,Ti},Tx}) where {Tv,Ti,Tx}
    get(cache, f) do
        prob = [1-env[f.label], env[f.label]]
        cache[f] = sum([x[1]*fteval!(x[2], env, cache) for x = zip(prob, f.nodes) if !iszero(x[1])])
    end
end

function fteval!(f::DDValue{Tv,Ti}, env::Dict{Symbol,Tx}, cache::Dict{AbstractDDNode{Tv,Ti},Tx}) where {Tv,Ti,Tx}
    (f.val == Tv(0)) ? Tx(0) : Tx(1)
end

"""
deriv1
"""

function fteval(f::AbstractFaultTreeNode, env::Dict{Symbol,Tx}, denv::Dict{Symbol,Tx}) where Tx
    bdd, = bdd(f)
    return fteval(bdd, env, denv)
end

function fteval(f::AbstractDDNode{Tv,Ti}, env::Dict{Symbol,Tx}, denv::Dict{Symbol,Tx}) where {Tv,Ti,Tx}
    cache = Dict{AbstractDDNode{Tv,Ti},Tx}()
    dcache = Dict{AbstractDDNode{Tv,Ti},Tx}()
    return fteval!(f, env, denv, cache, dcache)
end

function fteval!(f::DDVariable{Tv,Ti,2}, env::Dict{Symbol,Tx}, denv::Dict{Symbol,Tx},
    cache::Dict{AbstractDDNode{Tv,Ti},Tx}, dcache::Dict{AbstractDDNode{Tv,Ti},Tx}) where {Tv,Ti,Tx}
    get(dcache, f) do
        prob = [1-env[f.label], env[f.label]]
        dprob = [-denv[f.label], denv[f.label]]
        v = [x[1] * fteval!(x[2], env, cache) for x = zip(dprob, f.nodes) if !iszero(x[1])]
        res1 = iszero(v) ? Tx(0) : sum(v)
        res2 = sum([x[1] * fteval!(x[2], env, denv, cache, dcache) for x = zip(prob, f.nodes) if !iszero(x[1])])
        dcache[f] = res1 + res2
    end
end

function fteval!(f::DDValue{Tv,Ti}, env::Dict{Symbol,Tx}, denv::Dict{Symbol,Tx},
    cache::Dict{AbstractDDNode{Tv,Ti},Tx}, dcache::Dict{AbstractDDNode{Tv,Ti},Tx}) where {Tv,Ti,Tx}
    Tx(0)
end

"""
ftevalgen
"""

function ftevalgen!(f::DDVariable{Tv,Ti,2}, env0::Dict{Symbol,Array{Tx,N1}}, env1::Dict{Symbol,Array{Tx,N1}},
    cache::Dict{AbstractDDNode{Tv,Ti},Array{Tx,N2}}) where {Tv,Ti,Tx,N1,N2}
    get(cache, f) do
        v1 = env0[f.label] * ftevalgen!(f.nodes[1], env0, env1, cache)
        v2 = env1[f.label] * ftevalgen!(f.nodes[2], env0, env1, cache)
        cache[f] = v1 + v2
    end
end

function ftevalgen!(f::DDValue{Tv,Ti}, env0::Dict{Symbol,Array{Tx,N1}}, env1::Dict{Symbol,Array{Tx,N1}},
    cache::Dict{AbstractDDNode{Tv,Ti},Array{Tx,N2}}) where {Tv,Ti,Tx,N1,N2}
    cache[f]
end

