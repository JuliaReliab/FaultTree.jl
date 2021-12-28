"""
seval(f, env, cache)
Return the value for expr f
"""

function SymbolicDiff._eval(::Val{:ft}, f::SymbolicFTExpression{Tv}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(f, env, cache, f.top, bddcache)
end

function _fteval(ft::SymbolicFTExpression{Tv}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.AbstractNode{Symbol}, bddcache)::Tv where Tv
    get(bddcache, f.id) do
        v = f.header.label
        
        p = SymbolicDiff.seval(ft.events[v], env, cache)

        b0 = _fteval(ft, env, cache, f.low, bddcache)
        b1 = _fteval(ft, env, cache, f.high, bddcache)

        bddcache[f.id] = @. (1-p) * b0 + p * b1
    end
end

function _fteval(ft::SymbolicFTExpression{Tv}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{Symbol}, bddcache)::Tv where Tv
    (f == ft.bdd.zero) ? Tv(0) : Tv(1)
end

"""
seval(f, dvar, env, cache)
Return the first derivative of expr f
"""

function SymbolicDiff._eval(::Val{:ft}, f::SymbolicFTExpression{Tv}, dvar::Symbol, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(f, dvar, env, cache, f.top, bddcache)
end

function _fteval(ft::SymbolicFTExpression{Tv}, dvar::Symbol, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.AbstractNode{Symbol}, bddcache)::Tv where Tv
    get(bddcache, (f.id,dvar)) do
        v = f.header.label

        p = SymbolicDiff.seval(ft.events[v], env, cache)
        dp = SymbolicDiff.seval(ft.events[v], dvar, env, cache)

        b0 = _fteval(ft, env, cache, f.low, bddcache)
        db0 = _fteval(ft, dvar, env, cache, f.low, bddcache)

        b1 = _fteval(ft, env, cache, f.high, bddcache)
        db1 = _fteval(ft, dvar, env, cache, f.high, bddcache)

        bddcache[(f.id,dvar)] = @. -dp * b0 + (1-p) * db0 + dp * b1 + p * db1
    end
end

function _fteval(ft::SymbolicFTExpression{Tv}, dvar::Symbol, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{Symbol}, bddcache)::Tv where Tv
    Tv(0)
end

"""
seval(f, dvar, env, cache)
Return the second derivative of expr f
"""

function SymbolicDiff._eval(::Val{:ft}, f::SymbolicFTExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache)::Tv where Tv
    bddcache = Dict()
    _fteval(f, dvar, env, cache, f.top, bddcache)
end

function _fteval(ft::SymbolicFTExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.AbstractNode{Symbol}, bddcache)::Tv where Tv
    get(bddcache, (f.id,dvar)) do
        v = f.header.label

        p = SymbolicDiff.seval(ft.events[v], env, cache)
        dp_a = SymbolicDiff.seval(ft.events[v], dvar[1], env, cache)
        dp_b = SymbolicDiff.seval(ft.events[v], dvar[2], env, cache)
        dp_ab = SymbolicDiff.seval(ft.events[v], dvar, env, cache)

        b0 = _fteval(ft, env, cache, f.low, bddcache)
        db0_a = _fteval(ft, dvar[1], env, cache, f.low, bddcache)
        db0_b = _fteval(ft, dvar[2], env, cache, f.low, bddcache)
        db0_ab = _fteval(ft, dvar, env, cache, f.low, bddcache)

        b1 = _fteval(ft, env, cache, f.high, bddcache)
        db1_a = _fteval(ft, dvar[1], env, cache, f.high, bddcache)
        db1_b = _fteval(ft, dvar[2], env, cache, f.high, bddcache)
        db1_ab = _fteval(ft, dvar, env, cache, f.high, bddcache)

        bddcache[(f.id,dvar)] = @. -dp_ab * b0 - dp_a * db0_b - dp_b * db0_a + (1-p) * db0_ab + dp_ab * b1 + dp_a * db1_b + dp_b * db1_a + p * db1_ab
    end
end

function _fteval(ft::SymbolicFTExpression{Tv}, dvar::Tuple{Symbol,Symbol}, env::SymbolicDiff.SymbolicEnv, cache::SymbolicDiff.SymbolicCache, f::BDD.Terminal{Symbol}, bddcache)::Tv where Tv
    Tv(0)
end
