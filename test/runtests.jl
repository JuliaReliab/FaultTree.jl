using FaultTree
using DD
using Test

@testset "FaultTree1" begin
    x = ftevent(:x) & ftevent(:y)
    println(x)
    @test x.op == Symbol(:AND)
end

@testset "FaultTree1" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ~(x * y + z)
    println(expr)
end

@testset "todot1" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ~((x & y) | z | x)
    println(todot(expr))
end

@testset "bdd1" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ~((x & y) | z | x)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = bdd!(forest, expr)
    println(todot(forest, ft))
end

@testset "bdd2" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ftkofn(2, x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = bdd!(forest, expr)
    println(todot(forest, ft))
end

@testset "prob1" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ftand(x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = bdd!(forest, expr)
    env = Dict([:x => 0.1, :y => 0.5, :z => 0.8])
    cache = Dict{AbstractDDNode{Int,Int},Float64}()
    result = fteval!(ft, env, cache)
    println(result)
    @test isapprox(result, 0.1*0.5*0.8)
end

@testset "prob2" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ftor(x, y, z)
    ft, = bdd(expr)
    env = Dict([:x => 0.1, :y => 0.5, :z => 0.8])
    result = fteval(ft, env)
    println(result)
    @test isapprox(result, 1-(1-0.1)*(1-0.5)*(1-0.8))
end

@testset "prob3" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ftkofn(2, x, y, z)
    ft, = bdd(expr)
    env = Dict([:x => 0.1, :y => 0.5, :z => 0.8])
    result = fteval(ft, env)
    println(result)
    @test isapprox(result, 0.1*0.5*(1-0.8) + (1-0.1)*0.5*0.8 + 0.1*(1-0.5)*0.8 + 0.1*0.5*0.8)
end

@testset "mcs1" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ftand(x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = bdd!(forest, expr)
    cache = Dict{AbstractDDNode{Int,Int},Vector{Vector{Symbol}}}()
    result = ftmcs!(ft, cache)
    println(result)
end

@testset "mcs2" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ftor(x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = bdd!(forest, expr)
    cache = Dict{AbstractDDNode{Int,Int},Vector{Vector{Symbol}}}()
    result = ftmcs!(ft, cache)
    println(result)
    # @test isapprox(result, 0.1*0.5*0.8)
end

@testset "mcs3" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ftkofn(2, x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = bdd!(forest, expr)
    cache = Dict{AbstractDDNode{Int,Int},Vector{Vector{Symbol}}}()
    result = ftmcs!(ft, cache)
    println(result)
    # @test isapprox(result, 0.1*0.5*0.8)
end

@testset "mcs4" begin
    x = [ftevent(Symbol("x$i")) for i = 1:10]
    expr = (x[9] | (x[2] & x[5] & x[6]) | (x[1] & x[10]) | (x[2] & x[6]))
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = bdd!(forest, expr)
    cache = Dict{AbstractDDNode{Int,Int},Vector{Vector{Symbol}}}()
    result = ftmcs!(ft, cache)
    println(result)
    # @test isapprox(result, 0.1*0.5*0.8)
end

@testset "probx" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ftand(x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = bdd!(forest, expr)
    env = Dict([:x => 0.0, :y => 0.0, :z => 0.0])
    cache = Dict{AbstractDDNode{Int,Int},Float64}()
    result = fteval!(ft, env, cache)
    println(result)
    @test isapprox(result, 0.0)
end

@testset "dprob1" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ftand(x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = bdd!(forest, expr)
    env = Dict([:x => 0.1, :y => 0.5, :z => 0.8])
    denv = Dict([:x => 1.0, :y => 0.0, :z => 0.0])
    cache = Dict{AbstractDDNode{Int,Int},Float64}()
    dcache = Dict{AbstractDDNode{Int,Int},Float64}()
    result = fteval!(ft, env, denv, cache, dcache)
    println(result)
    @test isapprox(result, 0.5*0.8)
end

@testset "dprob2" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ftand(x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = bdd!(forest, expr)
    env = Dict([:x => 0.1, :y => 0.5, :z => 0.8])
    denv = Dict([:x => 0.0, :y => 1.0, :z => 0.0])
    cache = Dict{AbstractDDNode{Int,Int},Float64}()
    dcache = Dict{AbstractDDNode{Int,Int},Float64}()
    result = fteval!(ft, env, denv, cache, dcache)
    println(result)
    @test isapprox(result, 0.1*0.8)
end

@testset "fteval21b" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ftand(x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = bdd!(forest, expr)
    lam1 = 0.001
    lam2 = 0.01
    env = Dict(:x => exp(-lam1), :y => exp(-lam1), :z => exp(-lam2))
    cache = Dict{AbstractDDNode{Int,Int},Float64}()
    result = fteval!(ft, env, cache)
    println(result)
    # @test isapprox(result, 0.1*0.8)
end

@testset "fteval2b" begin
    x = ftevent(:x)
    y = ftevent(:y)
    z = ftevent(:z)
    expr = ftand(x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = bdd!(forest, expr)
    lam1 = 0.001
    lam2 = 0.01
    env0 = Dict(
        :x => Float64[1-exp(-lam1)  0            0            0;
                      exp(-lam1)    1-exp(-lam1) 0            0;
                      0             0            1-exp(-lam1) 0;
                      0             0            exp(-lam1)   1-exp(-lam1)],
        :y => Float64[1-exp(-lam1)  0            0            0;
                      exp(-lam1)    1-exp(-lam1) 0            0;
                      0             0            1-exp(-lam1) 0;
                      0             0            exp(-lam1)   1-exp(-lam1)],
        :z => Float64[1-exp(-lam2)  0            0            0;
                      0             1-exp(-lam2) 0            0;
                      exp(-lam2)    0            1-exp(-lam2) 0;
                      0             exp(-lam2)   0            1-exp(-lam2)],
                      )
    env1 = Dict(
        :x => Float64[exp(-lam1)  0            0            0;
                      -exp(-lam1)    exp(-lam1) 0            0;
                      0             0            exp(-lam1) 0;
                      0             0            -exp(-lam1)   exp(-lam1)],
        :y => Float64[exp(-lam1)  0            0            0;
                      -exp(-lam1)    exp(-lam1) 0            0;
                      0             0            exp(-lam1) 0;
                      0             0            -exp(-lam1)   exp(-lam1)],
        :z => Float64[exp(-lam2)  0            0            0;
                      0             exp(-lam2) 0            0;
                      -exp(-lam2)    0            exp(-lam2) 0;
                      0             -exp(-lam2)   0            exp(-lam2)],
                      )
    cache = Dict{AbstractDDNode{Int,Int},Vector{Float64}}()
    cache[ddval!(forest, 0)] = Float64[0,0,0,0]
    cache[ddval!(forest, 1)] = Float64[1,0,0,0]
    result = ftevalgen!(ft, env0, env1, cache)
    println(result)
    @test isapprox(result, [exp(-2*lam1-lam2), -2*exp(-2*lam1-lam2), -exp(-2*lam1-lam2), 2*exp(-2*lam1-lam2)])
end
