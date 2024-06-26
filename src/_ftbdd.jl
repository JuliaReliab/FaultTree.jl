import DD.BDD

export getbdd
export nvars
export ftbdd!
export getenv

"""
   getbdd(ft)

Get the BDD context.
"""
function getbdd(ft::FTree)
    ft.bdd
end

"""
    nvars(ft)

Get the number of BDD variables.
"""
function nvars(ft::FTree)
    ft.nvars
end

"""
    geteventsymbol(ft, x)

Get an event symbol corresponding to a given BDD node.
"""
function geteventsymbol(ft::FTree, x::BDD.AbstractNonTerminalNode)
    ft.basicinv[BDD.label(x)]
end

"""
     getenv(ft)

Get environment
"""
function getenv(ft::FTree)
    ft.env
end

"""
    _nextvar!(ft, x)

Get the next BDD variable with Symbol x.
"""
function _nextvar!(ft::FTree, x::Symbol)
    level = nvars(ft) + 1
    BDD.defvar!(getbdd(ft), x, level)
    ft.nvars = level
    BDD.var!(getbdd(ft), x)
end

"""
    ftbdd!(ft::FTree, top::AbstractFTObject)

Create BDD node from a given FT node.
"""
function ftbdd!(ft::FTree, top::AbstractFTObject)
    get!(ft.cache, top) do
        _tobdd!(ft, top)
    end
end

function _tobdd!(ft::FTree, x::FTAndGate)
    args = [_tobdd!(ft, f) for f = x.args]
    BDD.and!(getbdd(ft), args...)
end

function _tobdd!(ft::FTree, x::FTOrGate)
    args = [_tobdd!(ft, f) for f = x.args]
    BDD.or!(getbdd(ft), args...)
end

function _tobdd!(ft::FTree, x::FTKofNGate)
    args = [_tobdd!(ft, f) for f = x.args]
    _koutofn(getbdd(ft), x.k, args)
end

function _koutofn(b::BDD.Forest, k::Int, args)
    n = length(args)
    (k == 1) && return BDD.or!(b, args...)
    (k == n) && return BDD.and!(b, args...)
    x = args[1]
    xs = args[2:end]
    BDD.ifthenelse!(b, x, _koutofn(b, k-1, xs), _koutofn(b, k, xs))
end

function _tobdd!(ft::FTree, x::FTBasicEvent)
    i = get!(ft.basic, symbol(x), 0) + 1
    s = Symbol(symbol(x), "_", i)
    ft.basic[symbol(x)] = i
    ft.basicinv[s] = symbol(x)
    _nextvar!(ft, s)
end

function _tobdd!(ft::FTree, x::FTRepeatEvent)
    get!(ft.repeated, symbol(x)) do
        ft.basicinv[symbol(x)] = symbol(x)
        _nextvar!(ft, symbol(x))
    end
end

function _tobdd!(ft::FTree, x::FTIntermediateEvent)
    _tobdd!(ft, x.x)
end
