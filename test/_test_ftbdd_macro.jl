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
    env = Dict{Symbol,Float64}()
    @basic x, y
    top = x & x & y
    f = ftree(top)
    println(todot(f.top))
end

@testset "FaultTreeBDD_macro2" begin
    env = Dict{Symbol,Float64}()
    @repeated x, y
    top = x & x & y
    f = ftree(top)
    println(todot(f.top))
end

@testset "FaultTreeBDD_macro2" begin
    env = Dict{Symbol,Float64}()
    @repeated begin
        x
        y
    end
    top = x & x & y
    f = ftree(top)
    println(todot(f.top))
end

@testset "FaultTreeBDD_macro3" begin
    env = @parameters begin
        x = 0.9
        y = 0.8
    end
    @basic x, y
    top = x & x & y
    f = ftree(top)
    println(prob(f, env, type=:G))
end

@testset "FaultTreeBDD_macro3" begin
    env = @parameters begin
        x = 0.9
        y = 0.8
    end
    @repeated x, y
    top = x & x & y
    f = ftree(top)
    println(prob(f, env, type=:G))
end

@testset "FaultTreeBDD_macro3" begin
    @repeated x, y
    top = x & x & y
    f = ftree(top)
    p = prob(f, type=:G,
        @parameters begin
            x = 0.9
            y = 0.8
        end)
    println(p)
end

@testset "FaultTreeBDD_macro3" begin
    p = prob(type=:G,
        let
            @repeated x, y
            top = x & x & y
            ftree(top)
        end,
        @parameters begin
            x = 0.9
            y = 0.8
        end)
    println(p)
end
