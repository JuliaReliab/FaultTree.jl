import DD.BDD

export FTree
export getbdd
export gettop
export nvars
export ftree

"""
    FTree

A type for fault tree context.

## Fields
- `bdd`: An instance of BDD context
- `nvars`: The number of BDD variables
- `basic`: The dictionary of basic event. The value is the next index of basic event variable.
- `repeat`: The dictionary of repeat event.
- `desc`: A dictionary of descriptions
"""
mutable struct FTree
    bdd::BDD.Forest
    nvars::Int
    basic::Dict{Symbol,Int}
    basicinv::Dict{Symbol,Symbol}
    repeat::Dict{Symbol,BDD.AbstractNode}
    desc::Dict{AbstractFTEvent,String}
    top::BDD.AbstractNode

    function FTree(bdd::BDD.Forest)
        f = new()
        f.bdd = bdd
        f.nvars = 0
        f.basic = Dict{Symbol,Int}()
        f.basicinv = Dict{Symbol,Symbol}()
        f.repeat = Dict{Symbol,BDD.AbstractNode}()
        f.desc = Dict{AbstractFTEvent,String}()
        f
    end
end

"""
   getbdd(ft)

Get the BDD context.
"""
function getbdd(ft::FTree)
    ft.bdd
end

"""
   gettop(ft)

Get the BDD node of FT
"""
function gettop(ft::FTree)
    ft.top
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
    ftree(top::AbstractFTObject)
    ftree(b::BDD.Forest, top::AbstractFTObject)

Create FTree.
"""
function ftree(bdd::BDD.Forest, top::AbstractFTObject)
    ft = FTree(bdd)
    ft.top = _tobdd!(ft, top)
    ft
end

function ftree(top::AbstractFTObject)
    b = BDD.bdd()
    ftree(b, top)
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
    get!(ft.repeat, symbol(x)) do
        ft.basicinv[symbol(x)] = symbol(x)
        _nextvar!(ft, symbol(x))
    end
end

function _tobdd!(ft::FTree, x::FTIntermediateEvent)
    _tobdd!(ft, x.x)
end
