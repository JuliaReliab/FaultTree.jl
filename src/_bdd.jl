"""
BDD

BDD used in FT. Use the 'NOT' edge
"""

export todot, BDD, bddand, bddor, bddnot, bddxor, bddimp, bddvar, bddite
export fteval, ftmcs
export AbstractBDDNode

import Base

abstract type AbstractBDDNode{Ts} end

struct BDDNodeHeader{Ts}
    id::UInt
    level::Int
    label::Ts
end

struct BDDNode{Ts} <: AbstractBDDNode{Ts}
    id::UInt
    header::BDDNodeHeader{Ts}
    low::AbstractBDDNode{Ts}
    high::AbstractBDDNode{Ts}
    neg::Bool
end

struct BDDTerminal{Ts} <: AbstractBDDNode{Ts}
    id::UInt
end

abstract type AbstractBDDOperator end
struct BDDAnd <: AbstractBDDOperator end
struct BDDOr <: AbstractBDDOperator end
struct BDDXor <: AbstractBDDOperator end

struct BinBDDOperator{Ts}
    op::AbstractBDDOperator
    cache::Dict{Tuple{UInt,Bool,UInt,Bool},Tuple{AbstractBDDNode{Ts},Bool}}
end

mutable struct BDD{Ts}
    totalnodeid::UInt
    totalvarid::UInt
    maxlevel::Int
    headers::Dict{Ts,BDDNodeHeader{Ts}}
    utable::Dict{Tuple{UInt,UInt,UInt,Bool},AbstractBDDNode{Ts}}
    zero::BDDTerminal{Ts}
    andop::BinBDDOperator{Ts}
    orop::BinBDDOperator{Ts}
    xorop::BinBDDOperator{Ts}
end

function Base.show(io::IO, n::AbstractBDDNode{Ts}) where Ts
    Base.show(io, "node$(n.id)")
end

function BDD(::Type{Ts} = Symbol) where Ts
    zero = BDDTerminal{Ts}(0)
    start_node_id::UInt = 2
    start_var_id::UInt = 0
    start_level::UInt = 0
    h = Dict{Ts,BDDNodeHeader{Ts}}()
    ut = Dict{Tuple{UInt,UInt,UInt,Bool},AbstractBDDNode{Ts}}()
    andop = BinBDDOperator{Ts}(BDDAnd(), Dict{Tuple{UInt,Bool,UInt,Bool},Tuple{AbstractBDDNode{Ts},Bool}}())
    orop = BinBDDOperator{Ts}(BDDOr(), Dict{Tuple{UInt,Bool,UInt,Bool},Tuple{AbstractBDDNode{Ts},Bool}}())
    xorop = BinBDDOperator{Ts}(BDDXor(), Dict{Tuple{UInt,Bool,UInt,Bool},Tuple{AbstractBDDNode{Ts},Bool}}())
    b = BDD{Ts}(2, 0, 0, h, ut, zero, andop, orop, xorop)
end

function get_next_headerid!(b::BDD{Ts}) where Ts
    id = b.totalvarid
    b.totalvarid += 1
    id
end

function get_next_level!(b::BDD{Ts}) where Ts
    b.maxlevel += 1
end

function get_next_nodeid!(b::BDD{Ts}) where Ts
    id = b.totalnodeid
    b.totalnodeid += 1
    id
end

function bddvar(b::BDD{Ts}, label::Ts)::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    h = get(b.headers, label) do
        h = BDDNodeHeader(get_next_headerid!(b), get_next_level!(b), label)
        b.headers[label] = h
    end
    node!(b, h, (b.zero, false), (b.zero, true))
end

function node!(b::BDD{Ts}, h::BDDNodeHeader{Ts}, low::Tuple{AbstractBDDNode{Ts},Bool},
        high::Tuple{AbstractBDDNode{Ts},Bool})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    if low[2] == high[2] && low[1].id == high[1].id
        return low
    end
    flag = low[2] != high[2]
    key = (h.id, low[1].id, high[1].id, flag)
    node = get(b.utable, key) do
        b.utable[key] = BDDNode(get_next_nodeid!(b), h, low[1], high[1], flag)
    end
    return node, low[2]
end

# function node!(b::BDD{Ts}, h::BDDNodeHeader{Ts}, low::AbstractBDDNode{Ts}, ::Val{false},
#         high::AbstractBDDNode{Ts}, ::Val{false})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
#     if low.id == high.id
#         return low, false
#     end
#     key = (h.id, low.id, high.id, false)
#     node = get(b.utable, key) do
#         b.utable[key] = BDDNode(get_next_nodeid!(b), h, low, high, false)
#     end
#     return node, false
# end

# function node!(b::BDD{Ts}, h::BDDNodeHeader{Ts}, low::AbstractBDDNode{Ts}, ::Val{false},
#         high::AbstractBDDNode{Ts}, ::Val{true})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
#     key = (h.id, low.id, high.id, true)
#     node = get(b.utable, key) do
#         b.utable[key] = BDDNode(get_next_nodeid!(b), h, low, high, true)
#     end
#     return node, false
# end

# function node!(b::BDD{Ts}, h::BDDNodeHeader{Ts}, low::AbstractBDDNode{Ts}, ::Val{true},
#         high::AbstractBDDNode{Ts}, ::Val{false})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
#     key = (h.id, low.id, high.id, true)
#     node = get(b.utable, key) do
#         b.utable[key] = BDDNode(get_next_nodeid!(b), h, low, high, true)
#     end
#     return node, true
# end

# function node!(b::BDD{Ts}, h::BDDNodeHeader{Ts}, low::AbstractBDDNode{Ts}, ::Val{true},
#         high::AbstractBDDNode{Ts}, ::Val{true})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
#     if low.id == high.id
#         return low, true
#     end
#     key = (h.id, low.id, high.id, false)
#     node = get(b.utable, key) do
#         b.utable[key] = BDDNode(get_next_nodeid!(b), h, low, high, false)
#     end
#     return node, true
# end

### binoperator

function bddnot(b::BDD{Ts}, f::Tuple{AbstractBDDNode{Ts},Bool}) where Ts
    (f[1], !f[2])
end

function bddand(b::BDD{Ts}, f::Vararg{Tuple{AbstractBDDNode{Ts},Bool}}) where Ts
    ans = (b.zero, true)
    for x = f
        ans = binapply!(b.andop, b, ans, x)
    end
    ans
end

function bddor(b::BDD{Ts}, f::Vararg{Tuple{AbstractBDDNode{Ts},Bool}}) where Ts
    ans = (b.zero, false)
    for x = f
        ans = binapply!(b.orop, b, ans, x)
    end
    ans
end

function bddxor(b::BDD{Ts}, f::Tuple{AbstractBDDNode{Ts},Bool}, g::Tuple{AbstractBDDNode{Ts},Bool}) where Ts
    binapply!(b.xorop, b, f, g)
end

function bddimp(b::BDD{Ts}, f::Tuple{AbstractBDDNode{Ts},Bool}, g::Tuple{AbstractBDDNode{Ts},Bool}) where Ts
    bddor(b, bddnot(b, f), g)
end

function bddite(b::BDD{Ts}, f::Tuple{AbstractBDDNode{Ts},Bool}, g::Tuple{AbstractBDDNode{Ts},Bool}, h::Tuple{AbstractBDDNode{Ts},Bool}) where Ts
    bddor(b, bddand(b, f, g), bddand(b, bddnot(b, f), h))
end

### primitive

function binapply!(op::BinBDDOperator{Ts}, b::BDD{Ts},
        f::Tuple{AbstractBDDNode{Ts},Bool}, g::Tuple{AbstractBDDNode{Ts},Bool})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    return _binapply!(op.op, op, b, f, g)
end

function getzero(f::Tuple{BDDNode{Ts},Bool}) where Ts
    if f[2] == true
        (f[1].low, true)
    else
        (f[1].low, false)
    end
end

function getone(f::Tuple{BDDNode{Ts},Bool}) where Ts
    if f[2] == true 
        (f[1].high, !f[1].neg)
    else
        (f[1].high, f[1].neg)
    end
end

function _binapply!(::AbstractBDDOperator, op::BinBDDOperator{Ts}, b::BDD{Ts},
        f::Tuple{BDDNode{Ts},Bool}, g::Tuple{BDDNode{Ts},Bool})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    key = (f[1].id, f[2], g[1].id, g[2])
    get(op.cache, key) do
        if f[1].header.level > g[1].header.level
            n0 = _binapply!(op.op, op, b, getzero(f), g)
            n1 = _binapply!(op.op, op, b, getone(f), g)
            ans = node!(b, f[1].header, n0, n1)
        elseif f[1].header.level < g[1].header.level
            n0 = _binapply!(op.op, op, b, f, getzero(g))
            n1 = _binapply!(op.op, op, b, f, getone(g))
            ans = node!(b, g[1].header, n0, n1)
        else
            n0 = _binapply!(op.op, op, b, getzero(f), getzero(g))
            n1 = _binapply!(op.op, op, b, getone(f), getone(g))
            ans = node!(b, f[1].header, n0, n1)
        end
        op.cache[key] = ans
    end
end

## and

function _binapply!(::BDDAnd, op::BinBDDOperator{Ts}, b::BDD{Ts},
        f::Tuple{BDDTerminal{Ts},Bool}, g::Tuple{BDDNode{Ts},Bool})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    if f[2] == true
        return g
    else
        return b.zero, false
    end
end

function _binapply!(::BDDAnd, op::BinBDDOperator{Ts}, b::BDD{Ts},
        f::Tuple{BDDNode{Ts},Bool}, g::Tuple{BDDTerminal{Ts},Bool})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    if g[2] == true
        return f
    else
        return b.zero, false
    end
end

function _binapply!(::BDDAnd, op::BinBDDOperator{Ts}, b::BDD{Ts},
        f::Tuple{BDDTerminal{Ts},Bool}, g::Tuple{BDDTerminal{Ts},Bool})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    if f[2] == true && g[2] == true
        return b.zero, true
    else
        return b.zero, false
    end
end

## or

function _binapply!(::BDDOr, op::BinBDDOperator{Ts}, b::BDD{Ts},
        f::Tuple{BDDTerminal{Ts},Bool}, g::Tuple{BDDNode{Ts},Bool})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    if f[2] == true
        return b.zero, true
    else
        return g
    end
end

function _binapply!(::BDDOr, op::BinBDDOperator{Ts}, b::BDD{Ts},
        f::Tuple{BDDNode{Ts},Bool}, g::Tuple{BDDTerminal{Ts},Bool})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    if g[2] == true
        return b.zero, true
    else
        return f
    end
end

function _binapply!(::BDDOr, op::BinBDDOperator{Ts}, b::BDD{Ts},
        f::Tuple{BDDTerminal{Ts},Bool}, g::Tuple{BDDTerminal{Ts},Bool})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    if f[2] == false && g[2] == false
        return b.zero, false
    else
        return b.zero, true
    end
end

## xor

function _binapply!(::BDDXor, op::BinBDDOperator{Ts}, b::BDD{Ts},
        f::Tuple{BDDTerminal{Ts},Bool}, g::Tuple{BDDNode{Ts},Bool})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    if f[2] == true
        return (g[1], !g[2])
    else
        return g
    end
end

function _binapply!(::BDDXor, op::BinBDDOperator{Ts}, b::BDD{Ts},
        f::Tuple{BDDNode{Ts},Bool}, g::Tuple{BDDTerminal{Ts},Bool})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    if g[2] == true
        return (f[1], !f[2])
    else
        return f
    end
end

function _binapply!(::BDDXor, op::BinBDDOperator{Ts}, b::BDD{Ts},
        f::Tuple{BDDTerminal{Ts},Bool}, g::Tuple{BDDTerminal{Ts},Bool})::Tuple{AbstractBDDNode{Ts},Bool} where Ts
    if f[2] == g[2]
        return b.zero, false
    else
        return b.zero, true
    end
end

"""
fteval

compute failure (survival) probability
"""

function fteval(b::BDD{Ts}, f::Tuple{AbstractBDDNode{Ts},Bool}, env::Dict{Ts,Tx})::Tx where {Ts,Tx}
    cache = Dict{Tuple{UInt,Bool},Tx}()
    _fteval(b, f, env, cache)
end

function _fteval(b::BDD{Ts}, f::Tuple{BDDNode{Ts},Bool}, env::Dict{Ts,Tx}, cache::Dict{Tuple{UInt,Bool},Tx})::Tx where {Ts,Tx}
    get(cache, (f[1].id, f[2])) do
        p = env[f[1].header.label]
        fprob = (1-p) * _fteval(b, getzero(f), env, cache) + p * _fteval(b, getone(f), env, cache)
        cache[(f[1].id,!f[2])] = 1 - fprob
        cache[(f[1].id,f[2])] = fprob
    end
end

function _fteval(b::BDD{Ts}, f::Tuple{BDDTerminal{Ts},Bool}, env::Dict{Ts,Tx}, cache::Dict{Tuple{UInt,Bool},Tx})::Tx where {Ts,Tx}
    (f[2] == false) ? Tx(0) : Tx(1)
end

"""
fteval

compute deriv1 for failure or survival probability
"""

function fteval(b::BDD{Ts}, f::Tuple{AbstractBDDNode{Ts},Bool}, env::Dict{Ts,Tx}, denv::Dict{Ts,Tx}) where {Ts,Tx}
    cache = Dict{Tuple{UInt,Bool},Tx}()
    dcache = Dict{Tuple{UInt,Bool},Tx}()
    return _fteval(b, f, env, denv, cache, dcache)
end

function _fteval(b::BDD{Ts}, f::Tuple{BDDNode{Ts},Bool}, env::Dict{Ts,Tx}, denv::Dict{Ts,Tx},
    cache::Dict{Tuple{UInt,Bool},Tx}, dcache::Dict{Tuple{UInt,Bool},Tx})::Tx where {Ts,Tx}
    get(dcache, (f[1].id, f[2])) do
        p = env[f[1].header.label]
        dp = denv[f[1].header.label]
        fdprob = -dp * _fteval(b, getzero(f), env, cache) + dp * _fteval(b, getone(f), env, cache)
        fdprob += (1-p) * _fteval(b, getzero(f), env, denv, cache, dcache) + p * _fteval(b, getone(f), env, denv, cache, dcache)
        dcache[(f[1].id,!f[2])] = - fdprob
        dcache[(f[1].id,f[2])] = fdprob
    end
end

function _fteval(b::BDD{Ts}, f::Tuple{BDDTerminal{Ts},Bool}, env::Dict{Ts,Tx}, denv::Dict{Ts,Tx},
    cache::Dict{Tuple{UInt,Bool},Tx}, dcache::Dict{Tuple{UInt,Bool},Tx})::Tx where {Ts,Tx}
    Tx(0)
end

# TODO: implement for ftevalgen
# """
# ftevalgen
# """

# function ftevalgen!(f::DDVariable{Tv,Ti,2}, env0::Dict{Symbol,Array{Tx,N1}}, env1::Dict{Symbol,Array{Tx,N1}},
#     cache::Dict{AbstractDDNode{Tv,Ti},Array{Tx,N2}}) where {Tv,Ti,Tx,N1,N2}
#     get(cache, f) do
#         v1 = env0[f.label] * ftevalgen!(f.nodes[1], env0, env1, cache)
#         v2 = env1[f.label] * ftevalgen!(f.nodes[2], env0, env1, cache)
#         cache[f] = v1 + v2
#     end
# end

# function ftevalgen!(f::DDValue{Tv,Ti}, env0::Dict{Symbol,Array{Tx,N1}}, env1::Dict{Symbol,Array{Tx,N1}},
#     cache::Dict{AbstractDDNode{Tv,Ti},Array{Tx,N2}}) where {Tv,Ti,Tx,N1,N2}
#     cache[f]
# end


"""
ftmcs

Get minimal cutset
"""

mutable struct MinPath
    len::Int
    set::Vector{Vector{Bool}}
end

function ftmcs(b::BDD{Ts}, f::Tuple{AbstractBDDNode{Ts},Bool}) where Ts
    result = Vector{Ts}[]
    r = f
    while r != (b.zero, false)
        f, s = _ftmcs(b, r)
        append!(result, s)
        r = bddnot(b, bddimp(b, r, f))
    end
    result
end

function _ftmcs(b::BDD{Ts}, f::Tuple{AbstractBDDNode{Ts},Bool}) where Ts
    vars = Dict([x.level => bddvar(b, x.label) for (k,x) = b.headers])
    path = [false for i = 1:Int(b.totalvarid)]
    s = MinPath(Int(b.totalvarid), Vector{Bool}[])
    _ftmcs(b, f, path, s)
    result = (b.zero, false)
    result2 = Vector{Ts}[]
    for x = s.set
        tmp = (b.zero, true)
        tmp2 = Ts[]
        for i = 1:length(x)
            if x[i] == true
                tmp = bddand(b, tmp, vars[i])
                push!(tmp2, vars[i][1].header.label)
            end
        end
        result = bddor(b, result, tmp)
        push!(result2, tmp2)
    end
    return result, result2
end

function _ftmcs(b::BDD{Ts}, f::Tuple{BDDNode{Ts},Bool}, path::Vector{Bool}, s::MinPath) where Ts
    if s.len < sum(path)
        return
    end
    path[f[1].header.level] = false
    _ftmcs(b, getzero(f), path, s)
    path[f[1].header.level] = true
    _ftmcs(b, getone(f), path, s)
    path[f[1].header.level] = false
    nothing
end

function _ftmcs(b::BDD{Ts}, f::Tuple{BDDTerminal{Ts},Bool}, path::Vector{Bool}, s::MinPath) where Ts
    if f[2] == true
        if s.len > sum(path)
            s.len = sum(path)
            s.set = [copy(path)]
        elseif s.len == sum(path)
            push!(s.set, copy(path))
        end
    end
    nothing
end

##

function todot(b::BDD{Ts}, f::Tuple{AbstractBDDNode{Ts},Bool}) where Ts
    io = IOBuffer()
    visited = Set{AbstractBDDNode{Ts}}()
    println(io, "digraph { layout=dot; overlap=false; splines=true; node [fontsize=10];")
    _todot!(b, f[1], visited, io)
    println(io, "}")
    return String(take!(io))
end

function _todot!(b::BDD{Ts}, f::BDDTerminal{Ts}, visited::Set{AbstractBDDNode{Ts}}, io::IO)::Nothing where Ts
    if in(f, visited)
        return
    end
    if f == b.zero
        println(io, "\"obj$(objectid(f))\" [shape = square, label = \"0\"];")
    else
        println(io, "\"obj$(objectid(f))\" [shape = square, label = \"1\"];")
    end
    push!(visited, f)
    nothing
end

function _todot!(b::BDD{Ts}, f::BDDNode{Ts}, visited::Set{AbstractBDDNode{Ts}}, io::IO)::Nothing where Ts
    if in(f, visited)
        return
    end
    
    println(io, "\"obj$(objectid(f))\" [shape = circle, label = \"$(f.header.label)\"];")
    _todot!(b, f.low, visited, io)
    println(io, "\"obj$(objectid(f))\" -> \"obj$(objectid(f.low))\" [label = \"0\"];")
    _todot!(b, f.high, visited, io)
    if f.neg == false
        println(io, "\"obj$(objectid(f))\" -> \"obj$(objectid(f.high))\" [label = \"1\"];")
    else
        println(io, "\"obj$(objectid(f))\" -> \"obj$(objectid(f.high))\" [label = \"1\", arrowhead = odot];")
    end
    push!(visited, f)
    nothing
end
