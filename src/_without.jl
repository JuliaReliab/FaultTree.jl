import DD.BDD

export minsol

function _without(b::BDD.Forest, f::BDD.AbstractNonTerminalNode, g::BDD.AbstractNonTerminalNode, cache::Dict{Tuple{BDD.NodeID,BDD.NodeID},BDD.AbstractNode})
    key = (BDD.id(f), BDD.id(g))
    get!(cache, key) do
        if BDD.level(f) > BDD.level(g)
            n0 = _without(b, BDD.get_zero(f), g, cache)
            n1 = _without(b, BDD.get_one(f), g, cache)
            BDD.node!(b, f.header, n0, n1)
        elseif BDD.level(f) < BDD.level(g)
            _without(b, f, BDD.get_zero(g), cache)
        else
            n0 = _without(b, BDD.get_zero(f), BDD.get_zero(g), cache)
            n1 = _without(b, BDD.get_one(f), BDD.get_one(g), cache)
            BDD.node!(b, f.header, n0, n1)
        end
    end
end

function _without(::BDD.Forest, f::BDD.AbstractTerminalNode, ::BDD.AbstractNonTerminalNode, ::Dict{Tuple{BDD.NodeID,BDD.NodeID},BDD.AbstractNode})
    f
end

function _without(b::BDD.Forest, f::BDD.AbstractNonTerminalNode, g::BDD.AbstractTerminalNode, ::Dict{Tuple{BDD.NodeID,BDD.NodeID},BDD.AbstractNode})
    if BDD.iszero(g)
        f
    else
        b.zero
    end
end

function _without(b::BDD.Forest, f::BDD.AbstractTerminalNode, g::BDD.AbstractTerminalNode, ::Dict{Tuple{BDD.NodeID,BDD.NodeID},BDD.AbstractNode})
    if BDD.iszero(f)
        b.zero
    elseif BDD.isone(g)
        b.zero
    elseif BDD.iszero(g)
        f
    else
        b.one
    end
end

function _minsol(b::BDD.Forest, f::BDD.AbstractNonTerminalNode, cache1::Dict{BDD.NodeID,BDD.AbstractNode}, cache2::Dict{Tuple{BDD.NodeID,BDD.NodeID},BDD.AbstractNode})
    get!(cache1, BDD.id(f)) do
        g = BDD.get_one(f)
        h = BDD.get_zero(f)
        k = _minsol(b, g, cache1, cache2)
        u = _without(b, k, h, cache2)
        v = _minsol(b, h, cache1, cache2)
        BDD.node!(b, f.header, v, u)
    end
end

function _minsol(::BDD.Forest, f::BDD.AbstractTerminalNode, ::Dict{BDD.NodeID,BDD.AbstractNode}, ::Dict{Tuple{BDD.NodeID,BDD.NodeID},BDD.AbstractNode})
    f
end

function minsol(f::BDD.AbstractNode)
    b = BDD.forest(f)
    cache1 = Dict{BDD.NodeID,BDD.AbstractNode}()
    cache2 = Dict{Tuple{BDD.NodeID,BDD.NodeID},BDD.AbstractNode}()
    return _minsol(b, f, cache1, cache2)
end

