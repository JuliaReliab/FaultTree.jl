import DD.BDD

export FTree
export getbdd
export vars_basic
export vars_repeat
export vars_all
export nvars
export ftbdd!

"""
    FTree

A type for fault tree context.

## Fields
- `bdd`: An instance of BDD context
- `nvars`: The number of BDD variables
- `basic`: The dictionary of basic event. The value is the next index of basic event variable.
- `repeated`: The dictionary of repeated event.
- `desc`: A dictionary of descriptions
"""
mutable struct FTree
    bdd::BDD.Forest
    nvars::Int
    basic::Dict{Symbol,Int}
    basicinv::Dict{Symbol,Symbol}
    repeated::Dict{Symbol,BDD.AbstractNode}
    desc::Dict{AbstractFTEvent,String}
    cache::Dict{AbstractFTObject,BDD.AbstractNode}

    function FTree()
        f = new()
        f.bdd = BDD.bdd()
        f.nvars = 0
        f.basic = Dict{Symbol,Int}()
        f.basicinv = Dict{Symbol,Symbol}()
        f.repeated = Dict{Symbol,BDD.AbstractNode}()
        f.desc = Dict{AbstractFTEvent,String}()
        f.cache = Dict{AbstractFTObject,BDD.AbstractNode}()
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
    vars_basic(ft)

Get the vector of symbols of basic variables
"""
function vars_basic(ft::FTree)
    sort([k for (k,_) = ft.basic])
end

"""
    vars_repeat(ft)

Get the vector of symbols of repeated variables
"""
function vars_repeat(ft::FTree)
    sort([k for (k,_) = ft.repeated])
end

"""
    vars_all(ft)

Get the vector of symbols of variables
"""
function vars_all(ft::FTree)
    sort(vcat([k for (k,_) = ft.basic], [k for (k,_) = ft.repeated]...))
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
