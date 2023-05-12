using DD.BDD

@testset "FaultTreeBDD_macro1" begin
    env = Dict{Symbol,Float64}()
    m = @macroexpand @basic begin
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
    m = @macroexpand @basic x, y
    println(m)
    # top = x & x & y
    # f = ftree(top)
    # println(todot(f.top))
end

@testset "FaultTreeBDD_macro1" begin
    ft = FTree()
    env = Dict{Symbol,Float64}()
    @basic x, y
    top = x & x & y
    f = ftbdd!(ft, top)
    println(todot(f))
end

@testset "FaultTreeBDD_macro2" begin
    ft = FTree()
    env = Dict{Symbol,Float64}()
    @repeat x, y
    top = x & x & y
    f = ftbdd!(ft, top)
    println(todot(f))
end

@testset "FaultTreeBDD_macro2" begin
    ft = FTree()
    env = Dict{Symbol,Float64}()
    @repeat begin
        x
        y
    end
    top = x & x & y
    f = ftbdd!(ft, top)
    println(todot(f))
end

@testset "FaultTreeBDD_macro3" begin
    ft = FTree()
    @basic x, y
    env = @parameters begin
        x = 0.9
        y = 0.8
    end
    top = x & x & y
    ftbdd!(ft, top)
    println(prob(ft, top, env))
end

@testset "FaultTreeBDD_macro3" begin
    ft = FTree()
    @repeat x, y
    env = @parameters begin
        x = 0.9
        y = 0.8
    end
    top = x & x & y
    f = ftbdd!(ft, top)
    println(prob(ft, f, env))
end

@testset "FaultTreeBDD_macro3" begin
    ft = FTree()
    @repeat x, y
    top = x & x & y
    f = ftbdd!(ft, top)
    p = prob(ft, top,
        @parameters begin
            x = 0.9
            y = 0.8
        end)
    println(p)
end

@testset "FaultTreeBDD_macro3" begin
    ft = FTree()
    p = prob(ft,
        let
            @repeat x, y
            top = x & x & y
        end,
        @parameters begin
            x = 0.9
            y = 0.8
        end)
    println(p)
end
