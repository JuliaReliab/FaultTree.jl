import DD.BDD

export mcs
export extractpath

"""
    mcs(ft::FTree, top::AbstractFTObject)
    mcs(ft::FTree, top::BDD.AbstractNode)

Get MCS (minimal cut set) of FaultTree. The result is a set of vectors of event symbols.
"""
function mcs(ft::FTree, top::AbstractFTObject)
    mcs(ft, ftbdd!(ft, top))
end

function mcs(ft::FTree, top::BDD.AbstractNode)
    _mcs(getbdd(ft), top)
end

function _mcs(::BDD.Forest, f::BDD.AbstractNode)
    minsol(f)
end

function extractpath(f::BDD.AbstractNode)
    pathset = Vector{Symbol}[]
    _extract(f, Symbol[], pathset)
    return pathset
end

function _extract(f::BDD.AbstractNonTerminalNode, path::Vector{Symbol}, pathset::Vector{Vector{Symbol}})
    _extract(BDD.get_one(f), Symbol[path..., BDD.label(f)], pathset)
    _extract(BDD.get_zero(f), Symbol[path...], pathset)
    nothing
end

function _extract(f::BDD.AbstractTerminalNode, path::Vector{Symbol}, pathset::Vector{Vector{Symbol}})
    if BDD.isone(f)
        push!(pathset, path)
    end
    nothing
end

# function _mcs(b::BDD.Forest, f::BDD.AbstractNode)
#     vars = Dict([BDD.level(x) => BDD.var!(b, k) for (k,x) = BDD.vars(b)])
#     labels = Dict([BDD.level(x) => k for (k,x) = BDD.vars(b)])

#     result = Vector{Symbol}[]
#     while !BDD.iszero(f)
#         tmp, f = _mcs(b, f, vars, labels)
#         push!(result, tmp...)
#     end
#     result
# end

# function _mcs(b::BDD.Forest, f::BDD.AbstractNode, vars, labels)
#     path = [false for _ = vars]
#     s = MinPath(length(vars), Vector{Bool}[])
#     _findminpath(f, path, s)

#     mp = b.zero
#     result = Vector{Symbol}[]
#     for x = s.set
#         tmp = b.one
#         tmp2 = Symbol[]
#         for (i,v) = enumerate(x)
#             if v == true
#                 tmp = BDD.and(tmp, vars[i])
#                 push!(tmp2, labels[i])
#             end
#         end
#         mp = BDD.or(mp, tmp)
#         push!(result, tmp2)
#     end
#     result, BDD.not(BDD.imp(f, mp))
# end

# mutable struct MinPath
#     len::Int
#     set::Vector{Vector{Bool}}
# end

# function _findminpath(f::BDD.AbstractNonTerminalNode, path::Vector{Bool}, s::MinPath)
#     if s.len < sum(path)
#         return
#     end
#     path[BDD.level(f)] = false
#     _findminpath(BDD.get_zero(f), path, s)
#     path[BDD.level(f)] = true
#     _findminpath(BDD.get_one(f), path, s)
#     path[BDD.level(f)] = false
#     nothing
# end

# function _findminpath(f::BDD.AbstractTerminalNode, path::Vector{Bool}, s::MinPath)
#     if BDD.isone(f)
#         if s.len > sum(path)
#             s.len = sum(path)
#             s.set = [copy(path)]
#         elseif s.len == sum(path)
#             push!(s.set, copy(path))
#         end
#     end
#     nothing
# end
