export smeas
export bmeas
export c1meas
export c0meas

"""
    smeas(ft, top)

Compute the structure importance (S-measure) of FT. The result is represented by rational values.
S-measure is defined as the fraction of the number of critical cases over the total number of cases.
The critical case is the case where the system status changes when the status of target component changes.
"""
function smeas(ft::FTree, top::AbstractFTObject)
    f = ftbdd!(ft, top)
    env = Dict{Symbol,Rational}([k => 1//2 for (k,_) = ft.basic]...,
    [k => 1//2 for (k,_) = ft.repeated]...)
    grad(ft, f, env=env)
end

"""
    bmeas(ft, top, env)

Compute the Birnbaum importance (B-measure) of FT.
B-measure is defined as the probability that the system takes critical cases on the target component.
"""
function bmeas(ft::FTree, top::AbstractFTObject; env::Dict{Symbol,Tv} = getenv(ft)) where Tv <: Number
    f = ftbdd!(ft, top)
    grad(ft, f, env=env)
end

"""
    c1meas(ft, top, env)

Compute the criticality importance on 1 (C1-measure) of FT.
C1-measure is defined as the conditional probability that the system takes critical cases in which the target component takes 1
provided that the system takes a status 1. This implies that the contribution of target component to keep the system 1.

## Note
When the top event means the system failure, C1-measure represents the contribution to the system failure of each component.
"""
function c1meas(ft::FTree, top::AbstractFTObject; env::Dict{Symbol,Tv} = getenv(ft)) where Tv <: Number
    f = ftbdd!(ft, top)
    bddcache = Dict()
    p = prob(ft, f, env=env, bddcache=bddcache)
    b = grad(ft, f, env=env, bddcache=bddcache)
    Dict([k => v * env[k]/p for (k,v) = b])
end

"""
    c0meas(ft, top, env)

Compute the criticality importance on 0 (C0-measure) of FT.
C0-measure is defined as the conditional probability that the system takes critical cases in which the target component takes 0
provided that the system takes a status 0. This implies that the contribution of target component to keep the system 0.
"""
function c0meas(ft::FTree, top::AbstractFTObject; env::Dict{Symbol,Tv} = getenv(ft)) where Tv <: Number
    f = ftbdd!(ft, top)
    bddcache = Dict()
    p = prob(ft, f, env=env, bddcache=bddcache)
    b = grad(ft, f, env=env, bddcache=bddcache)
    Dict([k => v * (Tv(1) - env[k])/(Tv(1) - p) for (k,v) = b])
end
