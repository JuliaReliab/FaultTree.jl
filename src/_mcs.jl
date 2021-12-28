"""
MCS
"""

# ##

# mutable struct MinPath
#     len::Int
#     set::Vector{Vector{Bool}}
# end

# function ftmcs(b::BDD, f::AbstractNode{Ts}) where Ts
#     result = Vector{Ts}[]
#     r = f
#     while r != b.zero
#         f, s = _ftmcs(b, r)
#         append!(result, s)
#         r = bddnot(b, bddimp(b, r, f))
#     end
#     result
# end

# function _ftmcs(b::BDD, f::AbstractNode{Ts}) where Ts
#     vars = Dict([x.level => var!(b, x.label) for (k,x) = b.headers])
#     path = [false for i = 1:Int(b.totalvarid)]
#     s = MinPath(Int(b.totalvarid), Vector{Bool}[])
#     _ftmcs(b, f, path, s)
#     result = b.zero
#     result2 = Vector{Ts}[]
#     for x = s.set
#         tmp = b.one
#         tmp2 = Ts[]
#         for i = 1:length(x)
#             if x[i] == true
#                 tmp = bddand(b, tmp, vars[i])
#                 push!(tmp2, vars[i].header.label)
#             end
#         end
#         result = bddor(b, result, tmp)
#         push!(result2, tmp2)
#     end
#     return result, result2
# end

# function _ftmcs(b::BDD, f::Node{Ts}, path::Vector{Bool}, s::MinPath) where Ts
#     if s.len < sum(path)
#         return
#     end
#     path[f.header.level] = false
#     _ftmcs(b, f.low, path, s)
#     path[f.header.level] = true
#     _ftmcs(b, f.high, path, s)
#     path[f.header.level] = false
#     nothing
# end

# function _ftmcs(b::BDD, f::Terminal{Ts}, path::Vector{Bool}, s::MinPath) where Ts
#     if f == b.one
#         if s.len > sum(path)
#             s.len = sum(path)
#             s.set = [copy(path)]
#         elseif s.len == sum(path)
#             push!(s.set, copy(path))
#         end
#     end
#     nothing
# end

# old?

# export ftmcs, ftmcs!
# using DD

# function ftmcs(f::AbstractFaultTreeNode)
#     top, = bdd(f)
#     return ftmcs(top)
# end

# function ftmcs(f::AbstractDDNode{Tv,Ti}) where {Tv,Ti}
#     cache = Dict{AbstractDDNode{Tv,Ti},Vector{Vector{Symbol}}}()
#     return ftmcs!(f, cache)
# end

# function ftmcs!(f::DDVariable{Tv,Ti,2}, cache::Dict{AbstractDDNode{Tv,Ti},Vector{Vector{Symbol}}}) where {Tv,Ti}
#     _minimalset(_ftmcs!(f, cache))
# end

# function _ftmcs!(f::DDVariable{Tv,Ti,2}, cache::Dict{AbstractDDNode{Tv,Ti},Vector{Vector{Symbol}}}) where {Tv,Ti}
#     get(cache, f) do
#         res = [_ftmcs!(x, cache) for x = f.nodes]
#         res2 = [push!(copy(x), f.label) for x = res[2]]
#         res1 = [x for x = res[1]]
#         cache[f] = vcat(res1, res2)
#     end
# end

# function _ftmcs!(f::DDValue{Tv,Ti}, cache::Dict{AbstractDDNode{Tv,Ti},Vector{Vector{Symbol}}}) where {Tv,Ti}
#     (f.val == Tv(1)) ? Vector{Symbol}[Symbol[]] : Vector{Symbol}[]
# end

# function _remove!(x, xs)
#     for y = xs
#         isempty(setdiff(x, y)) && return false
#     end
#     return true
# end

# function _minimalset(args)
#     xs = sort(args, by=x->length(x), rev=true)
#     result = Vector{Symbol}[]
#     while !isempty(xs)
#         x = pop!(xs)
#         push!(result, sort(x))
#         xs = [y for y = xs if !issubset(x, y)]
#     end
#     sort(result)
# end
