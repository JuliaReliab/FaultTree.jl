"""
MCS
"""

##

mutable struct MinPath
    len::Int
    set::Vector{Vector{Bool}}
end

function mcs(ft::FTree{Tv}) where Tv
    mcs(ft.bdd, ft.top)
end

function mcs(b::BDD.BDDForest{AbstractFTEvent}, f::BDD.AbstractNode{AbstractFTEvent})
    result = Vector{AbstractFTEvent}[]
    r = f
    while r != b.zero
        f, s = _mcs(b, r)
        append!(result, s)
        r = BDD.not(b, BDD.imp(b, r, f))
    end
    result
end

function _mcs(b::BDD.BDDForest{AbstractFTEvent}, f::BDD.AbstractNode{AbstractFTEvent})
    path = [false for i = b.vars]
    s = MinPath(length(b.vars), Vector{Bool}[])
    _findminpath(b, f, path, s)

    vars = Dict([x.level+1 => BDD.var!(b, x.label) for (k,x) = b.headers])
    result = b.zero
    result2 = Vector{AbstractFTEvent}[]
    for x = s.set
        tmp = b.one
        tmp2 = AbstractFTEvent[]
        for i = 1:length(x)
            if x[i] == true
                tmp = BDD.and(b, tmp, vars[i])
                push!(tmp2, vars[i].header.label)
            end
        end
        result = BDD.or(b, result, tmp)
        push!(result2, tmp2)
    end
    return result, result2
end

@origin (path => 0) function _findminpath(b::BDD.BDDForest{AbstractFTEvent}, f::BDD.AbstractNode{AbstractFTEvent}, path::Vector{Bool}, s::MinPath)
    if s.len < sum(path)
        return
    end
    path[f.header.level] = false
    _findminpath(b, f.low, path, s)
    path[f.header.level] = true
    _findminpath(b, f.high, path, s)
    path[f.header.level] = false
    nothing
end

function _findminpath(b::BDD.BDDForest{AbstractFTEvent}, f::BDD.Terminal{AbstractFTEvent}, path::Vector{Bool}, s::MinPath)
    if f == b.one
        if s.len > sum(path)
            s.len = sum(path)
            s.set = [copy(path)]
        elseif s.len == sum(path)
            push!(s.set, copy(path))
        end
    end
    nothing
end
