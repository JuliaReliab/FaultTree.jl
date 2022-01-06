"""
FTProb
"""

struct SymbolicFTProbExpression{Tv} <: SymbolicDiff.AbstractSymbolic{Tv}
    params::Set{Symbol}
    op::Symbol
    events::Dict{Symbol,<:SymbolicDiff.AbstractSymbolic{Tv}}
    top::BDD.AbstractNode{AbstractFTEvent}
    bdd::BDD.BDDForest{AbstractFTEvent}
end

function Base.show(io::IO, x::SymbolicFTProbExpression{Tv}) where Tv
    Base.show(io, x.top)
end

function prob(ft::FTree{<:SymbolicDiff.AbstractSymbolic{Tv}}; type = :F) where Tv <: Number
    s = union([x.params for (k,x) = ft.events]...)
    SymbolicFTProbExpression(s, Symbol(:prob, type), ft.events, ft.top, ft.bdd)
end

function cprob(ft::FTree{<:SymbolicDiff.AbstractSymbolic{Tv}}; type = :F) where Tv <: Number
    s = union([x.params for (k,x) = ft.events]...)
    SymbolicFTProbExpression(s, Symbol(:cprob, type), ft.events, ft.top, ft.bdd)
end

"""
seval(f, env, cache)
Return the value for expr f
"""

function SymbolicDiff._eval(::Val{:probF}, ft::SymbolicFTProbExpression{Tv}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(Val(:CDF), Val(:F), ft, env, cache, ft.top, bddcache)
end

function SymbolicDiff._eval(::Val{:probG}, ft::SymbolicFTProbExpression{Tv}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(Val(:CDF), Val(:G), ft, env, cache, ft.top, bddcache)
end

function SymbolicDiff._eval(::Val{:cprobF}, ft::SymbolicFTProbExpression{Tv}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(Val(:CCDF), Val(:F), ft, env, cache, ft.top, bddcache)
end

function SymbolicDiff._eval(::Val{:cprobG}, ft::SymbolicFTProbExpression{Tv}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(Val(:CCDF), Val(:G), ft, env, cache, ft.top, bddcache)
end

function _fteval(op1, op2::Val{:F}, ft::SymbolicFTProbExpression{Tv}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.AbstractNode{AbstractFTEvent}, bddcache)::Tv where Tv
    get(bddcache, f.id) do
        v = f.header.label.label
        
        p = SymbolicDiff.seval(ft.events[v], env, cache)
        barp = 1 - p

        b0 = _fteval(op1, op2, ft, env, cache, f.low, bddcache)
        b1 = _fteval(op1, op2, ft, env, cache, f.high, bddcache)

        bddcache[f.id] = barp * b0 + p * b1
    end
end

function _fteval(op1::Any, op2::Val{:G}, ft::SymbolicFTProbExpression{Tv}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.AbstractNode{AbstractFTEvent}, bddcache)::Tv where Tv
    get(bddcache, f.id) do
        v = f.header.label.label
        
        p = SymbolicDiff.seval(ft.events[v], env, cache)
        barp = 1 - p

        b0 = _fteval(op1, op2, ft, env, cache, f.low, bddcache)
        b1 = _fteval(op1, op2, ft, env, cache, f.high, bddcache)

        bddcache[f.id] = p * b0 + barp * b1
    end
end

function _fteval(::Val{:CDF}, ::Val{:F}, ft::SymbolicFTProbExpression{Tv}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{AbstractFTEvent}, bddcache)::Tv where Tv
    (f == ft.bdd.zero) ? Tv(0) : Tv(1)
end

function _fteval(::Val{:CDF}, ::Val{:G}, ft::SymbolicFTProbExpression{Tv}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{AbstractFTEvent}, bddcache)::Tv where Tv
    (f == ft.bdd.zero) ? Tv(1) : Tv(0)
end

function _fteval(::Val{:CCDF}, ::Val{:F}, ft::SymbolicFTProbExpression{Tv}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{AbstractFTEvent}, bddcache)::Tv where Tv
    (f == ft.bdd.zero) ? Tv(1) : Tv(0)
end

function _fteval(::Val{:CCDF}, ::Val{:G}, ft::SymbolicFTProbExpression{Tv}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{AbstractFTEvent}, bddcache)::Tv where Tv
    (f == ft.bdd.zero) ? Tv(0) : Tv(1)
end

"""
seval(f, dvar, env, cache)
Return the first derivative of expr f
"""

function SymbolicDiff._eval(::Val{:probF}, f::SymbolicFTProbExpression{Tv}, dvar::Symbol, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(Val(:CDF), Val(:F), f, dvar, env, cache, f.top, bddcache)
end

function SymbolicDiff._eval(::Val{:probG}, f::SymbolicFTProbExpression{Tv}, dvar::Symbol, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(Val(:CDF), Val(:G), f, dvar, env, cache, f.top, bddcache)
end

function SymbolicDiff._eval(::Val{:cprobF}, f::SymbolicFTProbExpression{Tv}, dvar::Symbol, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(Val(:CCDF), Val(:F), f, dvar, env, cache, f.top, bddcache)
end

function SymbolicDiff._eval(::Val{:cprobG}, f::SymbolicFTProbExpression{Tv}, dvar::Symbol, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(Val(:CCDF), Val(:G), f, dvar, env, cache, f.top, bddcache)
end

function _fteval(op1::Any, op2::Val{:F}, ft::SymbolicFTProbExpression{Tv}, dvar::Symbol, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.AbstractNode{AbstractFTEvent}, bddcache)::Tv where Tv
    get(bddcache, (f.id,dvar)) do
        v = f.header.label.label

        p = SymbolicDiff.seval(ft.events[v], env, cache)
        dp = SymbolicDiff.seval(ft.events[v], dvar, env, cache)
        barp = 1 - p
        dbarp = -dp

        b0 = _fteval(op1, op2, ft, env, cache, f.low, bddcache)
        db0 = _fteval(op1, op2, ft, dvar, env, cache, f.low, bddcache)

        b1 = _fteval(op1, op2, ft, env, cache, f.high, bddcache)
        db1 = _fteval(op1, op2, ft, dvar, env, cache, f.high, bddcache)

        bddcache[(f.id,dvar)] = dbarp * b0 + barp * db0 + dp * b1 + p * db1
    end
end

function _fteval(op1::Any, op2::Val{:G}, ft::SymbolicFTProbExpression{Tv}, dvar::Symbol, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.AbstractNode{AbstractFTEvent}, bddcache)::Tv where Tv
    get(bddcache, (f.id,dvar)) do
        v = f.header.label.label

        p = SymbolicDiff.seval(ft.events[v], env, cache)
        dp = SymbolicDiff.seval(ft.events[v], dvar, env, cache)
        barp = 1 - p
        dbarp = -dp

        b0 = _fteval(op1, op2, ft, env, cache, f.low, bddcache)
        db0 = _fteval(op1, op2, ft, dvar, env, cache, f.low, bddcache)

        b1 = _fteval(op1, op2, ft, env, cache, f.high, bddcache)
        db1 = _fteval(op1, op2, ft, dvar, env, cache, f.high, bddcache)

        bddcache[(f.id,dvar)] = dp * b0 + p * db0 + dbarp * b1 + barp * db1
    end
end

function _fteval(::Val{:CDF}, ::Val{:F}, ft::SymbolicFTProbExpression{Tv}, dvar::Symbol, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{AbstractFTEvent}, bddcache)::Tv where Tv
    Tv(0)
end

function _fteval(::Val{:CDF}, ::Val{:G}, ft::SymbolicFTProbExpression{Tv}, dvar::Symbol, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{AbstractFTEvent}, bddcache)::Tv where Tv
    Tv(0)
end

function _fteval(::Val{:CCDF}, ::Val{:F}, ft::SymbolicFTProbExpression{Tv}, dvar::Symbol, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{AbstractFTEvent}, bddcache)::Tv where Tv
    Tv(0)
end

function _fteval(::Val{:CCDF}, ::Val{:G}, ft::SymbolicFTProbExpression{Tv}, dvar::Symbol, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{AbstractFTEvent}, bddcache)::Tv where Tv
    Tv(0)
end

"""
seval(f, dvar, env, cache)
Return the second derivative of expr f
"""

function SymbolicDiff._eval(::Val{:probF}, f::SymbolicFTProbExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(Val(:CDF), Val(:F), f, dvar, env, cache, f.top, bddcache)
end

function SymbolicDiff._eval(::Val{:probG}, f::SymbolicFTProbExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(Val(:CDF), Val(:G), f, dvar, env, cache, f.top, bddcache)
end

function SymbolicDiff._eval(::Val{:cprobF}, f::SymbolicFTProbExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(Val(:CCDF), Val(:F), f, dvar, env, cache, f.top, bddcache)
end

function SymbolicDiff._eval(::Val{:cprobG}, f::SymbolicFTProbExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(Val(:CCDF), Val(:G), f, dvar, env, cache, f.top, bddcache)
end

function _fteval(op1::Any, op2::Val{:F}, ft::SymbolicFTProbExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.AbstractNode{AbstractFTEvent}, bddcache)::Tv where Tv
    get(bddcache, (f.id,dvar)) do
        v = f.header.label.label

        p = SymbolicDiff.seval(ft.events[v], env, cache)
        dp_a = SymbolicDiff.seval(ft.events[v], dvar[1], env, cache)
        dp_b = SymbolicDiff.seval(ft.events[v], dvar[2], env, cache)
        dp_ab = SymbolicDiff.seval(ft.events[v], dvar, env, cache)

        barp = 1 - p
        dbarp_a = -dp_a
        dbarp_b = -dp_b
        dbarp_ab = -dp_ab

        b0 = _fteval(op1, op2, ft, env, cache, f.low, bddcache)
        db0_a = _fteval(op1, op2, ft, dvar[1], env, cache, f.low, bddcache)
        db0_b = _fteval(op1, op2, ft, dvar[2], env, cache, f.low, bddcache)
        db0_ab = _fteval(op1, op2, ft, dvar, env, cache, f.low, bddcache)

        b1 = _fteval(op1, op2, ft, env, cache, f.high, bddcache)
        db1_a = _fteval(op1, op2, ft, dvar[1], env, cache, f.high, bddcache)
        db1_b = _fteval(op1, op2, ft, dvar[2], env, cache, f.high, bddcache)
        db1_ab = _fteval(op1, op2, ft, dvar, env, cache, f.high, bddcache)

        bddcache[(f.id,dvar)] = dbarp_ab * b0 + dbarp_a * db0_b + dbarp_b * db0_a + barp * db0_ab + dp_ab * b1 + dp_a * db1_b + dp_b * db1_a + p * db1_ab
    end
end

function _fteval(op1::Any, op2::Val{:G}, ft::SymbolicFTProbExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.AbstractNode{AbstractFTEvent}, bddcache)::Tv where Tv
    get(bddcache, (f.id,dvar)) do
        v = f.header.label.label

        p = SymbolicDiff.seval(ft.events[v], env, cache)
        dp_a = SymbolicDiff.seval(ft.events[v], dvar[1], env, cache)
        dp_b = SymbolicDiff.seval(ft.events[v], dvar[2], env, cache)
        dp_ab = SymbolicDiff.seval(ft.events[v], dvar, env, cache)

        barp = 1 - p
        dbarp_a = -dp_a
        dbarp_b = -dp_b
        dbarp_ab = -dp_ab

        b0 = _fteval(op1, op2, ft, env, cache, f.low, bddcache)
        db0_a = _fteval(op1, op2, ft, dvar[1], env, cache, f.low, bddcache)
        db0_b = _fteval(op1, op2, ft, dvar[2], env, cache, f.low, bddcache)
        db0_ab = _fteval(op1, op2, ft, dvar, env, cache, f.low, bddcache)

        b1 = _fteval(op1, op2, ft, env, cache, f.high, bddcache)
        db1_a = _fteval(op1, op2, ft, dvar[1], env, cache, f.high, bddcache)
        db1_b = _fteval(op1, op2, ft, dvar[2], env, cache, f.high, bddcache)
        db1_ab = _fteval(op1, op2, ft, dvar, env, cache, f.high, bddcache)

        bddcache[(f.id,dvar)] = dp_ab * b0 + dp_a * db0_b + dp_b * db0_a + p * db0_ab + dbarp_ab * b1 + dbarp_a * db1_b + dbarp_b * db1_a + barp * db1_ab
    end
end

function _fteval(::Val{:CDF}, ::Val{:F}, ft::SymbolicFTProbExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{AbstractFTEvent}, bddcache)::Tv where Tv
    Tv(0)
end

function _fteval(::Val{:CDF}, ::Val{:G}, ft::SymbolicFTProbExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{AbstractFTEvent}, bddcache)::Tv where Tv
    Tv(0)
end

function _fteval(::Val{:CCDF}, ::Val{:F}, ft::SymbolicFTProbExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{AbstractFTEvent}, bddcache)::Tv where Tv
    Tv(0)
end

function _fteval(::Val{:CCDF}, ::Val{:G}, ft::SymbolicFTProbExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{AbstractFTEvent}, bddcache)::Tv where Tv
    Tv(0)
end
