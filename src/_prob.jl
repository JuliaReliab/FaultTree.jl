import DD.BDD

export prob
export cprob

"""
    prob(ft::FTree, top::AbstractFTObject, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict())::Tv where Tv <: Number
    prob(ft::FTree, top::BDD.AbstractNode, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict())::Tv where Tv <: Number

Compute the probability of topevent

## Arguments
- `ft`: Context of fault tree
- `top`: Top event node (AbstractFTObject or BDD node)
- `env`: The dictionary to provide the probability of events
- `type`: The symbol to determine whether the top event indicates failure or working. If type is :F, the top event is
   the failure. Otherwise, if type is :G, the top event is working.
- `bddcache`: The dictionary to store the intermediate computation results
"""
function prob(ft::FTree, top::AbstractFTObject, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict())::Tv where Tv <: Number
    prob(ft, ftbdd!(ft, top), env, type = type, bddcache = bddcache)
end

function prob(ft::FTree, f::BDD.AbstractNode, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict())::Tv where Tv <: Number
    _prob(Val(:CDF), Val(type), ft, f, env, bddcache)
end

"""
    cprob(ft::FTree, top::AbstractFTObject, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict())::Tv where Tv <: Number
    cprob(ft::FTree, top::BDD.AbstractNode, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict())::Tv where Tv <: Number

Compute the complementary probability of topevent

## Arguments
- `ft`: Context of fault tree
- `top`: Top event node (AbstractFTObject or BDD node)
- `env`: The dictionary to provide the probability of events
- `type`: The symbol to determine whether the top event indicates failure or working. If type is :F, the top event is
   the failure. Otherwise, if type is :G, the top event is working.
- `bddcache`: The dictionary to store the intermediate computation results
"""
function cprob(ft::FTree, top::AbstractFTObject, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict())::Tv where Tv <: Number
    cprob(ft, ftbdd!(ft, top), env, type = type, bddcache = bddcache)
end

function cprob(ft::FTree, f::BDD.AbstractNode, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict())::Tv where Tv <: Number
    _prob(Val(:CCDF), Val(type), ft, f, env, bddcache)
end

function _prob(op1::Tc, op2::Val{:F}, ft::FTree, f::BDD.AbstractNonTerminalNode, env::Dict{Symbol,Tv}, bddcache)::Tv where {Tc, Tv <: Number}
    get!(bddcache, BDD.id(f)) do
        v = geteventsymbol(ft, f)
        
        p = env[v]
        barp = 1-p

        b0 = _prob(op1, op2, ft, BDD.get_zero(f), env, bddcache)
        b1 = _prob(op1, op2, ft, BDD.get_one(f), env, bddcache)

        barp * b0 + p * b1
    end
end

function _prob(::Val{:CDF}, ::Val{:F}, ft::FTree, f::BDD.AbstractTerminalNode, env::Dict{Symbol,Tv}, bddcache)::Tv where Tv <: Number
    BDD.iszero(f) ? Tv(0) : Tv(1)
end

function _prob(::Val{:CCDF}, ::Val{:F}, ft::FTree, f::BDD.AbstractTerminalNode, env::Dict{Symbol,Tv}, bddcache)::Tv where Tv <: Number
    BDD.iszero(f) ? Tv(1) : Tv(0)
end

function _prob(op1::Tc, op2::Val{:G}, ft::FTree, f::BDD.AbstractNonTerminalNode, env::Dict{Symbol,Tv}, bddcache)::Tv where {Tc, Tv <: Number}
    get!(bddcache, BDD.id(f)) do
        v = geteventsymbol(ft, f)
        
        p = env[v]
        barp = 1-p

        b0 = _prob(op1, op2, ft, BDD.get_zero(f), env, bddcache)
        b1 = _prob(op1, op2, ft, BDD.get_one(f), env, bddcache)

        p * b0 + barp * b1
    end
end

function _prob(::Val{:CDF}, ::Val{:G}, ft::FTree, f::BDD.AbstractTerminalNode, env::Dict{Symbol,Tv}, bddcache)::Tv where Tv <: Number
    BDD.iszero(f) ? Tv(1) : Tv(0)
end

function _prob(::Val{:CCDF}, ::Val{:G}, ft::FTree, f::BDD.AbstractTerminalNode, env::Dict{Symbol,Tv}, bddcache)::Tv where Tv <: Number
    BDD.iszero(f) ? Tv(0) : Tv(1)
end


