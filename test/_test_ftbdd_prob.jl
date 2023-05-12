using DD.BDD

@testset "FaultTreeBDD_prob1" begin
    ft = FTree()
    top = ftbasic(:x) & ftbasic(:x)
    ftbdd!(ft, top)
    env = Dict(
        :x => 0.1
    )
    println(prob(ft, top, env))
end

@testset "FaultTreeBDD2" begin
    ft = FTree()
    x = ftbasic(:x)
    top = ftkofn(2, x, x, x)
    f = ftbdd!(ft, top)
    env = Dict(
        :x => 0.1
    )
    println(prob(ft, f, env))
end

@testset "FaultTreeBDD_prob3" begin
    ft = FTree()
    x = ftrepeat(:x)
    top = ftkofn(2, x, x, x)
    f = ftbdd!(ft, top)
    env = Dict(
        :x => 0.1
    )
    println(prob(ft, f, env))
end
