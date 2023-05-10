using DD.BDD

@testset "FaultTreeBDD_prob1" begin
    top = ftbasic(:x) & ftbasic(:x)
    f = ftree(top)
    env = Dict(
        :x => 0.1
    )
    println(prob(f, env))
end

@testset "FaultTreeBDD2" begin
    x = ftbasic(:x)
    top = ftkofn(2, x, x, x)
    f = ftree(top)
    env = Dict(
        :x => 0.1
    )
    println(prob(f, env))
end

@testset "FaultTreeBDD_prob3" begin
    x = ftrepeat(:x)
    top = ftkofn(2, x, x, x)
    f = ftree(top)
    env = Dict(
        :x => 0.1
    )
    println(prob(f, env))
end
