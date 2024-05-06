export @basic
export @repeated
export @parameters

"""
    @basic block

A macro to define a basic event

### Example
```julia
ft = FTree()
@basic ft x
```
=>
```julia
begin
    ft = FTree()
    x = ftbasic(ft, :x)
end
````

```julia
ft = FTree()
@basic ft x, y
```
=>
```julia
begin
    ft = FTree()
    x = ftbasic(ft, :x)
    y = ftbasic(ft, :y)
end
````

```julia
ft = FTree()
@basic ft begin
    x
    y
end
```
=>
```julia
begin
    ft = FTree()
    x = ftbasic(ft, :x)
    y = ftbasic(ft, :y)
end
````
"""
macro basic(ft, x)
    if Meta.isexpr(x, :tuple)
        body = [_genbasic(ft, x) for x = x.args]
        esc(Expr(:block, body...))
    elseif Meta.isexpr(x, :block)
        body = [_genbasic(ft, x) for x = x.args]
        esc(Expr(:block, body...))
    else
        esc(_genbasic(ft, x))
    end
end

function _genbasic(ft, x::Any)
    x
end

function _genbasic(ft, x::Expr)
    if Meta.isexpr(x, :ref)
        s = x.args[1]
        i = x.args[2]
        Expr(:block,
            Expr(:(=), s, Expr(:call, :Dict)),
            Expr(:for, Expr(:(=), :i, i),
                Expr(:block,
                    Expr(:(=), Expr(:ref, s, :i),
                        Expr(:call, :ftbasic, ft,
                            Expr(:call, :Symbol, Expr(:string, string(s), "[", :i, "]")))))))
    else
        x
    end
end

function _genbasic(ft, x::Symbol)
    Expr(:(=), x, Expr(:call, :ftbasic, ft, Expr(:quote, x)))
end

"""
    @repeated block

A macro to define a repeated event

### Example
```julia
ft = FTree()
@repeated ft x
```
=>
```julia
begin
    ft = FTree()
    x = ftrepeated(ft, :x)
end
````

```julia
ft = FTree()
@repeated ft x, y
```
=>
```julia
begin
    ft = FTree()
    x = ftrepeated(ft, :x)
    y = ftrepeated(ft, :y)
end
````

```julia
ft = FTree()
@repeated ft begin
    x
    y
end
```
=>
```julia
begin
    ft = FTree()
    x = ftrepeated(ft, :x)
    y = ftrepeated(ft, :y)
end
````
"""
macro repeated(ft, x)
    if Meta.isexpr(x, :tuple)
        body = [_genrepeat(ft, x) for x = x.args]
        esc(Expr(:block, body...))
    elseif Meta.isexpr(x, :block)
        body = [_genrepeat(ft, x) for x = x.args]
        esc(Expr(:block, body...))
    else
        esc(_genrepeat(ft, x))
    end
end

function _genrepeat(ft, x::Any)
    x
end

function _genrepeat(ft, x::Expr)
    if Meta.isexpr(x, :ref)
        s = x.args[1]
        i = x.args[2]
        Expr(:block,
            Expr(:(=), s, Expr(:call, :Dict)),
            Expr(:for, Expr(:(=), :i, i),
                Expr(:block,
                    Expr(:(=), Expr(:ref, s, :i),
                        Expr(:call, :ftrepeated, ft,
                            Expr(:call, :Symbol, Expr(:string, string(s), "[", :i, "]")))))))
    else
        x
    end
end

function _genrepeat(ft, x::Symbol)
    Expr(:(=), x, Expr(:call, :ftrepeated, ft, Expr(:quote, x)))
end

"""
    @parameters block

A macro to define parameters of FTevents

### Example
```julia
ft = FTree()
@parameters ft begin
    x = 0.1
    y = 0.2
end
```
=>
```julia
env = Dict(:x => 0.1, :y => 0.2)
ft.env = env
````
"""
macro parameters(x)
    body = if Meta.isexpr(x, :block)
        [_genparam(x) for x = x.args if typeof(x) == Expr]
    else
        [_genparam(x)]
    end
    expr = Expr(:call, :Dict, body...)
    esc(expr)
end

function _genparam(x::Any)
    nothing
end

function _genparam(x::Expr)
    if Meta.isexpr(x, :(=))
        label = x.args[1]
        value = x.args[2]
        Expr(:call, :(=>), Expr(:., label, Expr(:quote, :x)), value)
    else
        throw("Error")
    end
end

macro parameters(ft, x)
    body = if Meta.isexpr(x, :block)
        [_genparam(x) for x = x.args if typeof(x) == Expr]
    else
        [_genparam(x)]
    end
    expr = Expr(:(=), Expr(:., ft, Expr(:quote, :env)), Expr(:call, :Dict, body...))
    esc(expr)
end
