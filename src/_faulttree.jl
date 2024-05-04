import DD.BDD

export AbstractFTObject
export getft
export AbstractFTGate
export AbstractFTEvent
export FTree
export FTAndGate
export FTOrGate
export FTKofNGate
export FTBasicEvent
export FTIntermediateEvent
export FTRepeatEvent
export symbol
export ftree
export ftbasic
export ftintermediate
export ftrepeated
export ftand
export ftor
export ftkofn

"""
    AbstractFTObject

Abstract type for fault tree objects.
"""
abstract type AbstractFTObject end

"""
    AbstractFTGate <: AbstractFTObject

Abstract type for fault tree gates.

### Notes

Every concrete `AbstractFTGate` must have the following fields:
- `args`: a vector of FTNode
"""
abstract type AbstractFTGate <: AbstractFTObject end

"""
    AbstractFTEvent <: AbstractFTObject

Abstract type for fault tree events.

### Fileds
- `x`: the symbol indentifying the event
"""
abstract type AbstractFTEvent <: AbstractFTObject end

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
    env::Dict{Symbol,Number}

    function FTree()
        f = new()
        f.bdd = BDD.bdd()
        f.nvars = 0
        f.basic = Dict{Symbol,Int}()
        f.basicinv = Dict{Symbol,Symbol}()
        f.repeated = Dict{Symbol,BDD.AbstractNode}()
        f.desc = Dict{AbstractFTEvent,String}()
        f.cache = Dict{AbstractFTObject,BDD.AbstractNode}()
        f.env = Dict{Symbol,Number}()
        f
    end
end

"""
    symbol(x)

Get a symbol of ftevent.
"""
function symbol(x::AbstractFTEvent)
    x.x
end

"""
    getft(x)

Get ft.
"""
function getft(x::AbstractFTObject)
    x.ft
end

"""
    FTAndGate <: AbstractFTGate

AND gate

### Fileds
- `args`: a vector of FTNode
"""
mutable struct FTAndGate <: AbstractFTGate
    ft::FTree
    args::Vector{<:AbstractFTObject}

    function FTAndGate(ft::FTree, args::Vector{<:AbstractFTObject})
        new(ft, args)
    end
end

"""
    FTOrGate <: AbstractFTGate

OR gate

### Fileds
- `args`: a vector of FTNode
"""
mutable struct FTOrGate <: AbstractFTGate
    ft::FTree
    args::Vector{<:AbstractFTObject}

    function FTOrGate(ft::FTree, args::Vector{<:AbstractFTObject})
        new(ft, args)
    end
end

"""
    FTKofNGate <: AbstractFTGate

k-out-of-N gate

### Fileds
- `args`: a vector of FTNode
- `k`: an integer indicating K
"""
mutable struct FTKofNGate <: AbstractFTGate
    ft::FTree
    args::Vector{<:AbstractFTObject}
    k::Int

    function FTKofNGate(ft::FTree, args::Vector{<:AbstractFTObject}, k::Int)
        new(ft, args, k)
    end
end

"""
    FTBasicEvent <: AbstractFTEvent

Basic event

### Fileds
- `x`: the symbol indentifying the event
"""
mutable struct FTBasicEvent <: AbstractFTEvent
    ft::FTree
    x::Symbol

    function FTBasicEvent(ft::FTree, x::Symbol)
        new(ft, x)
    end
end

"""
    FTRepeatEvent <: AbstractFTEvent

Repeat event

### Fileds
- `x`: the symbol indentifying the event
"""
mutable struct FTRepeatEvent <: AbstractFTEvent
    ft::FTree
    x::Symbol

    function FTRepeatEvent(ft::FTree, x::Symbol)
        new(ft, x)
    end
end

"""
    FTIntermediateEvent <: AbstractFTEvent

Intermediate event

### Fileds
- `x`: the symbol indentifying the event
"""
mutable struct FTIntermediateEvent <: AbstractFTEvent
    ft::FTree
    x::AbstractFTGate

    function FTIntermediateEvent(ft::FTree, x::AbstractFTGate)
        new(ft, x)
    end
end

### constructors

"""
    ftbasic(x)

Create an FTBasicEvent.
"""
function ftbasic(ft::FTree, x::Symbol)
    FTBasicEvent(ft, x)
end

"""
    ftrepeated(x)

Create an FTRpeatEvent.
"""
function ftrepeated(ft::FTree, x::Symbol)
    FTRepeatEvent(ft, x)
end

"""
    ftintermediate(x)

Create an FTRpeatEvent.
"""
function ftintermediate(ft::FTree, x::AbstractFTGate)
    FTIntermediateEvent(ft, x)
end

"""
    ftand(x, y...)

Create an AND gate with x, y...
"""
function ftand(ft::FTree, x::AbstractFTObject, y::Vararg{AbstractFTObject})
    args = AbstractFTObject[x, y...]
    FTAndGate(ft, args)
end

"""
    ftor(x, y...)

Create an OR gate with x, y...
"""
function ftor(ft::FTree, x::AbstractFTObject, y::Vararg{AbstractFTObject})
    args = AbstractFTObject[x, y...]
    FTOrGate(ft, args)
end

"""
    ftkofn(k::Int, x, y...)

Create an K-out-of-N gate with x, y...
"""
function ftkofn(ft::FTree, k::Int, x::AbstractFTObject, y::Vararg{AbstractFTObject})
    args = AbstractFTObject[x, y...]
    FTKofNGate(ft, args, k)
end

### overloads

function Base.show(io::IO, x::AbstractFTEvent)
    Base.show(io, symbol(x))
end

function Base.show(io::IO, x::AbstractFTGate)
    Base.show(io, objectid(x))
end

function Base.:*(x::AbstractFTObject, y::AbstractFTObject)
    ftand(getft(x), x, y)
end

function Base.:&(x::AbstractFTObject, y::AbstractFTObject)
    ftand(getft(x), x, y)
end

function Base.:+(x::AbstractFTObject, y::AbstractFTObject)
    ftor(getft(x), x, y)
end

function Base.:|(x::AbstractFTObject, y::AbstractFTObject)
    ftor(getft(x), x, y)
end
