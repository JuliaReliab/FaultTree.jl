### create BDD

# function bdd(top::AbstractFTNode)
#     b = BDD.BDD(Symbol)
#     b, bdd!(b, top)
# end

# function bdd!(b::BDD.BDDForest{Symbol}, top::AbstractFTNode)
#     for (i,x) = enumerate(sort(collect(top.labels)))
#         BDD.header!(b, x)
#     end
#     _tobdd!(b, top)
# end

function _tobdd!(b::BDD.BDDForest{FTEvent}, f::FTEvent, env)
    e = env[f.label]
    if e[2] == :basic
        BDD.var!(b, ftevent(f.label))
    else
        BDD.var!(b, f)
    end
end

function _tobdd!(b::BDD.BDDForest{FTEvent}, f, env)
    _tobdd!(b, Val(f.op), f, env)
end

function _tobdd!(b::BDD.BDDForest{FTEvent}, ::Val{:AND}, f::FTOperation, env)
    bargs = [_tobdd!(b, x, env) for x = f.args]
    BDD.and(b, bargs...)
end

function _tobdd!(b::BDD.BDDForest{FTEvent}, ::Val{:OR}, f::FTOperation, env)
    bargs = [_tobdd!(b, x, env) for x = f.args]
    BDD.or(b, bargs...)
end

function _tobdd!(b::BDD.BDDForest{FTEvent}, ::Val{:NOT}, f::FTOperation, env)
    @assert length(f.args) == 1
    BDD.not(b, _tobdd!(b, f.args[1], env))
end

function _tobdd!(b::BDD.BDDForest{FTEvent}, ::Val{:KofN}, f::FTKoutofN, env)
    bargs = [_tobdd!(b, x, env) for x = f.args]
    _createKofNGate(b, f.k, bargs)
end

function _createKofNGate(b::BDD.BDDForest{FTEvent}, k, args)
    n = length(args)
    (k == 1) && return BDD.or(b, args...)
    (k == n) && return BDD.and(b, args...)
    x = args[1]
    xs = args[2:end]
    BDD.ite(b, x, _createKofNGate(b, k-1, xs), _createKofNGate(b, k, xs))
end
