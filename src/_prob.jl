"""
prob(ft)
Return the value for expr f
"""

function prob(ft::FTree{Tv}; type = :F, bddcache = Dict())::Tv where Tv <: Number
    _prob(Val(:CDF), Val(type), ft, ft.top, bddcache)
end

function cprob(ft::FTree{Tv}; type = :F, bddcache = Dict())::Tv where Tv <: Number
    _prob(Val(:CCDF), Val(type), ft, ft.top, bddcache)
end

function _prob(op1::Tc, op2::Val{:F}, ft::FTree{Tv}, f::BDD.AbstractNode{FTEvent}, bddcache)::Tv where {Tc, Tv <: Number}
    get(bddcache, f.id) do
        v = f.header.label.label
        
        p = ft.events[v]
        barp = 1-p

        b0 = _prob(op1, op2, ft, f.low, bddcache)
        b1 = _prob(op1, op2, ft, f.high, bddcache)

        bddcache[f.id] = barp * b0 + p * b1
    end
end

function _prob(::Val{:CDF}, ::Val{:F}, ft::FTree{Tv}, f::BDD.Terminal{FTEvent}, bddcache)::Tv where Tv <: Number
    (f == ft.bdd.zero) ? Tv(0) : Tv(1)
end

function _prob(::Val{:CCDF}, ::Val{:F}, ft::FTree{Tv}, f::BDD.Terminal{FTEvent}, bddcache)::Tv where Tv <: Number
    (f == ft.bdd.zero) ? Tv(1) : Tv(0)
end

## TODO: check the computation for G

function _prob(op1::Tc, op2::Val{:G}, ft::FTree{Tv}, f::BDD.AbstractNode{FTEvent}, bddcache)::Tv where {Tc, Tv <: Number}
    get(bddcache, f.id) do
        v = f.header.label.label
        
        p = ft.events[v]
        barp = 1-p

        b0 = _prob(op1, op2, ft, f.low, bddcache)
        b1 = _prob(op1, op2, ft, f.high, bddcache)

        bddcache[f.id] = p * b0 + barp * b1
    end
end

function _prob(::Val{:CDF}, ::Val{:G}, ft::FTree{Tv}, f::BDD.Terminal{FTEvent}, bddcache)::Tv where Tv <: Number
    (f == ft.bdd.zero) ? Tv(1) : Tv(0)
end

function _prob(::Val{:CCDF}, ::Val{:G}, ft::FTree{Tv}, f::BDD.Terminal{FTEvent}, bddcache)::Tv where Tv <: Number
    (f == ft.bdd.zero) ? Tv(0) : Tv(1)
end

