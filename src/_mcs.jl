"""
MCS
"""

export ftmcs, ftmcs!
using DD

function ftmcs(f::AbstractFaultTreeNode)
    top, = bdd(f)
    return ftmcs(top)
end

function ftmcs(f::AbstractDDNode{Tv,Ti}) where {Tv,Ti}
    cache = Dict{AbstractDDNode{Tv,Ti},Vector{Vector{Symbol}}}()
    return ftmcs!(f, cache)
end

function ftmcs!(f::DDVariable{Tv,Ti,2}, cache::Dict{AbstractDDNode{Tv,Ti},Vector{Vector{Symbol}}}) where {Tv,Ti}
    _minimalset(_ftmcs!(f, cache))
end

function _ftmcs!(f::DDVariable{Tv,Ti,2}, cache::Dict{AbstractDDNode{Tv,Ti},Vector{Vector{Symbol}}}) where {Tv,Ti}
    get(cache, f) do
        res = [_ftmcs!(x, cache) for x = f.nodes]
        res2 = [push!(copy(x), f.label) for x = res[2]]
        res1 = [x for x = res[1]]
        cache[f] = vcat(res1, res2)
    end
end

function _ftmcs!(f::DDValue{Tv,Ti}, cache::Dict{AbstractDDNode{Tv,Ti},Vector{Vector{Symbol}}}) where {Tv,Ti}
    (f.val == Tv(1)) ? Vector{Symbol}[Symbol[]] : Vector{Symbol}[]
end

function _remove!(x, xs)
    for y = xs
        isempty(setdiff(x, y)) && return false
    end
    return true
end

function _minimalset(args)
    xs = sort(args, by=x->length(x), rev=true)
    result = Vector{Symbol}[]
    while !isempty(xs)
        x = pop!(xs)
        push!(result, sort(x))
        xs = [y for y = xs if !issubset(x, y)]
    end
    sort(result)
end
