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

function _tobdd!(b::BDD.BDDForest{Symbol}, f::FTEvent)
    BDD.var!(b, f.label)
end

function _tobdd!(b::BDD.BDDForest{Symbol}, f)
    _tobdd!(b, Val(f.op), f)
end

function _tobdd!(b::BDD.BDDForest{Symbol}, ::Val{:AND}, f::FTOperation)
    bargs = [_tobdd!(b, x) for x = f.args]
    BDD.and(b, bargs...)
end

function _tobdd!(b::BDD.BDDForest{Symbol}, ::Val{:OR}, f::FTOperation)
    bargs = [_tobdd!(b, x) for x = f.args]
    BDD.or(b, bargs...)
end

function _tobdd!(b::BDD.BDDForest{Symbol}, ::Val{:NOT}, f::FTOperation)
    @assert length(f.args) == 1
    BDD.not(b, _tobdd!(b, f.args[1]))
end

function _tobdd!(b::BDD.BDDForest{Symbol}, ::Val{:KofN}, f::FTKoutofN)
    bargs = [_tobdd!(b, x) for x = f.args]
    _createKofNGate(b, f.k, bargs)
end

function _createKofNGate(b::BDD.BDDForest{Symbol}, k, args)
    n = length(args)
    (k == 1) && return BDD.or(b, args...)
    (k == n) && return BDD.and(b, args...)
    x = args[1]
    xs = args[2:end]
    BDD.ite(b, x, _createKofNGate(b, k-1, xs), _createKofNGate(b, k, xs))
end
