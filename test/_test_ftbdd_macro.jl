using DD.BDD

@testset "FaultTreeBDD_macro1" begin
    env = Dict{Symbol,Float64}()
    ft = FTree()
    m = @macroexpand @basic ft begin
        x
        y
    end
    println(m)
    # top = x & x & y
    # f = ftree(top)
    # println(todot(f.top))
end

@testset "FaultTreeBDD_macro1" begin
    env = Dict{Symbol,Float64}()
    ft = FTree()
    m = @macroexpand @basic ft x, y
    println(m)
    # top = x & x & y
    # f = ftree(top)
    # println(todot(f.top))
end

@testset "FaultTreeBDD_macro1" begin
    ft = FTree()
    env = Dict{Symbol,Float64}()
    @basic ft x, y
    top = x & x & y
    f = ftbdd!(ft, top)
    println(todot(f))
end

@testset "FaultTreeBDD_macro2" begin
    ft = FTree()
    env = Dict{Symbol,Float64}()
    @repeated ft x, y
    top = x & x & y
    f = ftbdd!(ft, top)
    println(todot(f))
end

@testset "FaultTreeBDD_macro2" begin
    ft = FTree()
    env = Dict{Symbol,Float64}()
    @repeated ft begin
        x
        y
    end
    top = x & x & y
    f = ftbdd!(ft, top)
    println(todot(f))
end

@testset "FaultTreeBDD_macro3" begin
    ft = FTree()
    @basic ft x, y
    env = @parameters begin
        x = 0.9
        y = 0.8
    end
    top = x & x & y
    ftbdd!(ft, top)
    println(prob(ft, top, env=env))
end

@testset "FaultTreeBDD_macro3" begin
    ft = FTree()
    @repeated ft x, y
    env = @parameters begin
        x = 0.9
        y = 0.8
    end
    top = x & x & y
    f = ftbdd!(ft, top)
    println(prob(ft, f, env=env))
end

@testset "FaultTreeBDD_macro3" begin
    ft = FTree()
    @repeated ft x, y
    top = x & x & y
    f = ftbdd!(ft, top)
    p = prob(ft, top, env=@parameters begin
            x = 0.9
            y = 0.8
        end)
    println(p)
end

@testset "FaultTreeBDD_macro3" begin
    ft = FTree()
    p = prob(ft,
        let
            @repeated ft x, y
            top = x & x & y
        end, env=Dict(
            :x => 0.9,
            :y => 0.8))
    println(p)
end

@testset "FaultTreeBDD_macro4" begin
    ft = FTree()
    @repeated ft x,y
    println(@macroexpand @parameters ft begin
        x = 0.9
        y = 0.8
    end)
    # p = prob(ft, x & X & y)
    # println(p)
end
