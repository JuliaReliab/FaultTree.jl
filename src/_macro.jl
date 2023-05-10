export @basic
export @repeat
export @parameters

"""
    @basic block

A macro to define a basic event

### Example
```julia
@basic x
```
=>
```julia
begin
    x = ftbasic(:x)
end
````

```julia
@basic x, y
```
=>
```julia
begin
    x = ftbasic(:x)
    y = ftbasic(:y)
end
````

```julia
@basic begin
    x
    y
end
```
=>
```julia
begin
    x = ftbasic(:x)
    y = ftbasic(:y)
end
````
"""
macro basic(x)
    if Meta.isexpr(x, :tuple)
        body = [_genbasic(x) for x = x.args]
        esc(Expr(:block, body...))
    elseif Meta.isexpr(x, :block)
        body = [_genbasic(x) for x = x.args]
        esc(Expr(:block, body...))
    else
        esc(_genbasic(x))
    end
end

function _genbasic(x::Any)
    x
end

function _genbasic(x::Symbol)
    Expr(:(=), x, Expr(:call, :ftbasic, Expr(:quote, x)))
end

"""
    @repeat block

A macro to define a repeat event

### Example
```julia
@repeat x
```
=>
```julia
begin
    x = ftrepeat(:x)
end
````

```julia
@repeat x, y
```
=>
```julia
begin
    x = ftrepeat(:x)
    y = ftrepeat(:y)
end
````

```julia
@repeat begin
    x
    y
end
```
=>
```julia
begin
    x = ftrepeat(:x)
    y = ftrepeat(:y)
end
````
"""
macro repeat(x)
    if Meta.isexpr(x, :tuple)
        body = [_genrepeat(x) for x = x.args]
        esc(Expr(:block, body...))
    elseif Meta.isexpr(x, :block)
        body = [_genrepeat(x) for x = x.args]
        esc(Expr(:block, body...))
    else
        esc(_genrepeat(x))
    end
end

function _genrepeat(x::Any)
    x
end

function _genrepeat(x::Symbol)
    Expr(:(=), x, Expr(:call, :ftrepeat, Expr(:quote, x)))
end

"""
    @parameters block

A macro to define parameters of FTevents

### Example
```julia
env = @parameters begin
    x = 0.1
    y = 0.2
end
```
=>
```julia
env = Dict(:x => 0.1, :y => 0.2)
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
        Expr(:call, :(=>), Expr(:quote, label), value)
    else
        throw("Error")
    end
end
