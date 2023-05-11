export smeas
export bmeas
export cmeas
export ccmeas

function smeas(ft::FTree, top::AbstractFTObject)
    f = ftbdd!(ft, top)
    env = Dict{Symbol,Rational}([k => 1//2 for (k,_) = ft.basic]...,
    [k => 1//2 for (k,_) = ft.repeated]...)
    grad(ft, f, env)
end

function bmeas(ft::FTree, top::AbstractFTObject, env::Dict{Symbol,Tv}) where Tv <: Number
    f = ftbdd!(ft, top)
    grad(ft, f, env)
end

function cmeas(ft::FTree, top::AbstractFTObject, env::Dict{Symbol,Tv}) where Tv <: Number
    f = ftbdd!(ft, top)
    bddcache = Dict()
    p = prob(ft, f, env, bddcache=bddcache)
    b = grad(ft, f, env, bddcache=bddcache)
    Dict([k => v * env[k]/p for (k,v) = b])
end

function ccmeas(ft::FTree, top::AbstractFTObject, env::Dict{Symbol,Tv}) where Tv <: Number
    f = ftbdd!(ft, top)
    bddcache = Dict()
    p = prob(ft, f, env, bddcache=bddcache)
    b = grad(ft, f, env, bddcache=bddcache)
    Dict([k => v * (Tv(1) - env[k])/(Tv(1) - p) for (k,v) = b])
end
