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

function _tobdd!(b::BDD.BDDForest{AbstractFTEvent}, f::FTBasicEvent)
    BDD.var!(b, ftbasic(f.label))
end

function _tobdd!(b::BDD.BDDForest{AbstractFTEvent}, f::FTRepeatEvent)
    BDD.var!(b, f)
end

# function _tobdd!(b::BDD.BDDForest{AbstractFTEvent}, f::AbstractFTEvent)
#     e = env[f.label]
#     if e[2] == :basic
#         BDD.var!(b, ftevent(f.label))
#     else
#         BDD.var!(b, f)
#     end
# end

function _tobdd!(b::BDD.BDDForest{AbstractFTEvent}, f)
    _tobdd!(b, Val(f.op), f)
end

function _tobdd!(b::BDD.BDDForest{AbstractFTEvent}, ::Val{:AND}, f::FTOperation)
    bargs = [_tobdd!(b, x) for x = f.args]
    BDD.and(b, bargs...)
end

function _tobdd!(b::BDD.BDDForest{AbstractFTEvent}, ::Val{:OR}, f::FTOperation)
    bargs = [_tobdd!(b, x) for x = f.args]
    BDD.or(b, bargs...)
end

function _tobdd!(b::BDD.BDDForest{AbstractFTEvent}, ::Val{:NOT}, f::FTOperation)
    @assert length(f.args) == 1
    BDD.not(b, _tobdd!(b, f.args[1]))
end

function _tobdd!(b::BDD.BDDForest{AbstractFTEvent}, ::Val{:KofN}, f::FTKoutofN)
    bargs = [_tobdd!(b, x) for x = f.args]
    _createKofNGate(b, f.k, bargs)
end

function _createKofNGate(b::BDD.BDDForest{AbstractFTEvent}, k, args)
    n = length(args)
    (k == 1) && return BDD.or(b, args...)
    (k == n) && return BDD.and(b, args...)
    x = args[1]
    xs = args[2:end]
    BDD.ite(b, x, _createKofNGate(b, k-1, xs), _createKofNGate(b, k, xs))
end
