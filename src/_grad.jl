import DD.BDD

export grad
export cgrad

"""
    grad(ft::FTree, top::AbstractFTObject, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict())::Tv where Tv <: Number
    grad(ft::FTree, top::BDD.AbstractNode, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict())::Tv where Tv <: Number

Compute the gradient of probability of topevent

## Arguments
- `ft`: Context of fault tree
- `top`: Top event node (AbstractFTObject or BDD node)
- `env`: The dictionary to provide the probability of events
- `type`: The symbol to determine whether the top event indicates failure or working. If type is :F, the top event is
   the failure. Otherwise, if type is :G, the top event is working.
- `bddcache`: The dictionary to store the intermediate computation results
"""
function grad(ft::FTree, top::AbstractFTObject, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict()) where Tv <: Number
    grad(ft, ftbdd!(ft, top), env, type = type, bddcache = bddcache)
end

function grad(ft::FTree, f::BDD.AbstractNode, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict()) where Tv <: Number
    _prob(Val(:CDF), Val(type), ft, f, env, bddcache)
    gradcache = Dict{BDD.NodeID,Tv}()
    gradevent = Dict{Symbol,Tv}()
    gradcache[BDD.id(f)] = one(Tv)
    for x = _tsort(f)
        _grad(Val(:CDF), Val(type), ft, x, env, bddcache, gradcache, gradevent)
    end
    gradevent
end

"""
    cgrad(ft::FTree, top::AbstractFTObject, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict())::Tv where Tv <: Number
    cgrad(ft::FTree, top::BDD.AbstractNode, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict())::Tv where Tv <: Number

Compute the gradient of complementary probability of topevent

## Arguments
- `ft`: Context of fault tree
- `top`: Top event node (AbstractFTObject or BDD node)
- `env`: The dictionary to provide the probability of events
- `type`: The symbol to determine whether the top event indicates failure or working. If type is :F, the top event is
   the failure. Otherwise, if type is :G, the top event is working.
- `bddcache`: The dictionary to store the intermediate computation results
"""
function cgrad(ft::FTree, top::AbstractFTObject, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict()) where Tv <: Number
    cgrad(ft, ftbdd!(ft, top), env, type = type, bddcache = bddcache)
end

function cgrad(ft::FTree, f::BDD.AbstractNode, env::Dict{Symbol,Tv}; type = :F, bddcache = Dict()) where Tv <: Number
    _prob(Val(:CCDF), Val(type), ft, f, env, bddcache)
    gradcache = Dict{BDD.NodeID,Tv}()
    gradevent = Dict{Symbol,Tv}()
    gradcache[BDD.id(f)] = one(Tv)
    for x = _tsort(f)
        _grad(Val(:CCDF), Val(type), ft, x, env, bddcache, gradcache, gradevent)
    end
    gradevent
end

function _grad(op1::Tc, op2::Val{:F}, ft::FTree,
    f::BDD.AbstractNonTerminalNode, env::Dict{Symbol,Tv},
    bddcache, gradcache, gradevent) where {Tc, Tv <: Number}
    w = gradcache[BDD.id(f)]
    v = geteventsymbol(ft, f)
    p = env[v]
    barp = 1-p

    b0 = BDD.get_zero(f)
    tmp = get!(gradcache, BDD.id(b0), zero(Tv))
    gradcache[BDD.id(b0)] = tmp + w * barp

    b1 = BDD.get_one(f)
    tmp = get!(gradcache, BDD.id(b1), zero(Tv))
    gradcache[BDD.id(b1)] = tmp + w * p

    tmp = get!(gradevent, v, zero(Tv))
    gradevent[v] = tmp + w * (bddcache[BDD.id(b1)] - bddcache[BDD.id(b0)])
    nothing
end

function _grad(::Val{:CDF}, ::Val{:F}, ft::FTree,
    f::BDD.AbstractTerminalNode, env::Dict{Symbol,Tv},
    bddcache, gradcache, gradevent) where {Tc, Tv <: Number}
    nothing
end

function _grad(::Val{:CCDF}, ::Val{:F}, ft::FTree,
    f::BDD.AbstractTerminalNode, env::Dict{Symbol,Tv},
    bddcache, gradcache, gradevent) where {Tc, Tv <: Number}
    nothing
end

function _grad(op1::Tc, op2::Val{:G}, ft::FTree,
    f::BDD.AbstractNonTerminalNode, env::Dict{Symbol,Tv},
    bddcache, gradcache, gradevent) where {Tc, Tv <: Number}
    w = gradcache[BDD.id(f)]
    v = geteventsymbol(ft, f)
    p = env[v]
    barp = 1-p

    b0 = BDD.get_zero(f)
    tmp = get!(gradcache, BDD.id(b0), zero(Tv))
    gradcache[BDD.id(b0)] = tmp + w * p

    b1 = BDD.get_one(f)
    tmp = get!(gradcache, BDD.id(b1), zero(Tv))
    gradcache[BDD.id(b1)] = tmp + w * barp

    tmp = get!(gradevent, v, zero(Tv))
    gradevent[v] = tmp + w * (bddcache[BDD.id(b0)] - bddcache[BDD.id(b1)])
    nothing
end

function _grad(::Val{:CDF}, ::Val{:G}, ft::FTree,
    f::BDD.AbstractTerminalNode, env::Dict{Symbol,Tv},
    bddcache, gradcache, gradevent) where {Tc, Tv <: Number}
    nothing
end

function _grad(::Val{:CCDF}, ::Val{:G}, ft::FTree,
    f::BDD.AbstractTerminalNode, env::Dict{Symbol,Tv},
    bddcache, gradcache, gradevent) where {Tc, Tv <: Number}
    nothing
end

