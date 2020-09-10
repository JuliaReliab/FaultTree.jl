using FaultTree
using DD
using Test

@testset "FaultTree1" begin
    x = ftree(true)
    println(x)
    @test x.var == Symbol(true)
    x = ftree(:(x & y))
    println(x)
    @test x.op == Symbol(:AND)
end

@testset "FaultTree1" begin
    x = ftree(:x)
    y = ftree(:y)
    z = ftree(:z)
    expr = ~((x & y) | z)
    println(expr)
end

@testset "todot1" begin
    x = ftree(:x)
    y = ftree(:y)
    z = ftree(:z)
    expr = ~((x & y) | z | x)
    println(todot(expr))
end

@testset "tobdd1" begin
    x = ftree(:x)
    y = ftree(:y)
    z = ftree(:z)
    expr = ~((x & y) | z | x)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = tobdd!(forest, expr)
    println(todot(forest, ft))
end

@testset "tobdd2" begin
    x = ftree(:x)
    y = ftree(:y)
    z = ftree(:z)
    expr = ftkofn(2, x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = tobdd!(forest, expr)
    println(todot(forest, ft))
end

@testset "prob1" begin
    x = ftree(:x)
    y = ftree(:y)
    z = ftree(:z)
    expr = ftand(x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = tobdd!(forest, expr)
    vars = Dict(:x=>0.1, :y=>0.5, :z=>0.8)
    cache = Dict{AbstractDDNode{Int,Int},Float64}()
    result = ftprob!(ft, vars, cache)
    println(result)
    @test isapprox(result, 0.1*0.5*0.8)
end

@testset "prob2" begin
    x = ftree(:x)
    y = ftree(:y)
    z = ftree(:z)
    expr = ftor(x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = tobdd!(forest, expr)
    vars = Dict(:x=>0.1, :y=>0.5, :z=>0.8)
    cache = Dict{AbstractDDNode{Int,Int},Float64}()
    result = ftprob!(ft, vars, cache)
    println(result)
    @test isapprox(result, 1-(1-0.1)*(1-0.5)*(1-0.8))
end

@testset "prob3" begin
    x = ftree(:x)
    y = ftree(:y)
    z = ftree(:z)
    expr = ftkofn(2, x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = tobdd!(forest, expr)
    vars = Dict(:x=>0.1, :y=>0.5, :z=>0.8)
    cache = Dict{AbstractDDNode{Int,Int},Float64}()
    result = ftprob!(ft, vars, cache)
    println(result)
    @test isapprox(result, 0.1*0.5*(1-0.8) + (1-0.1)*0.5*0.8 + 0.1*(1-0.5)*0.8 + 0.1*0.5*0.8)
end

@testset "prob4" begin
    x = ftree(:x)
    y = ftree(:y)
    z = ftree(:z)
    expr = ftkofn(2, x, y, z)
    vars = Dict(:x=>0.1, :y=>0.5, :z=>0.8)
    result = ftprob(expr, vars)
    println(result)
    @test isapprox(result, 0.1*0.5*(1-0.8) + (1-0.1)*0.5*0.8 + 0.1*(1-0.5)*0.8 + 0.1*0.5*0.8)
end

@testset "prob4" begin
    s = [Symbol("x$i") for i = 1:10]
    nodes = [ftree(x) for x = s]
    expr = ftkofn(5, nodes...)
    vars = Dict([x => rand() for x = s]...)
    @time bdd, = tobdd(expr)
    @time result = ftprob(bdd, vars)
    println(result)
end

@testset "mcs1" begin
    x = ftree(:x)
    y = ftree(:y)
    z = ftree(:z)
    expr = ftand(x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = tobdd!(forest, expr)
    cache = Dict{AbstractDDNode{Int,Int},Vector{Vector{Symbol}}}()
    result = ftmcs!(ft, cache)
    println(result)
end

@testset "mcs2" begin
    x = ftree(:x)
    y = ftree(:y)
    z = ftree(:z)
    expr = ftor(x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = tobdd!(forest, expr)
    cache = Dict{AbstractDDNode{Int,Int},Vector{Vector{Symbol}}}()
    result = ftmcs!(ft, cache)
    println(result)
    # @test isapprox(result, 0.1*0.5*0.8)
end

@testset "mcs3" begin
    x = ftree(:x)
    y = ftree(:y)
    z = ftree(:z)
    expr = ftkofn(2, x, y, z)
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = tobdd!(forest, expr)
    cache = Dict{AbstractDDNode{Int,Int},Vector{Vector{Symbol}}}()
    result = ftmcs!(ft, cache)
    println(result)
    # @test isapprox(result, 0.1*0.5*0.8)
end

@testset "mcs4" begin
    x = [ftree(Symbol("x$i")) for i = 1:10]
    expr = ftree(:(x9 | (x2 & x5 & x6) | (x1 & x10) | (x2 & x6)))
    forest = BDDForest{Int,Int,Int}(FullyReduced())
    ft = tobdd!(forest, expr)
    cache = Dict{AbstractDDNode{Int,Int},Vector{Vector{Symbol}}}()
    result = ftmcs!(ft, cache)
    println(result)
    # @test isapprox(result, 0.1*0.5*0.8)
end
