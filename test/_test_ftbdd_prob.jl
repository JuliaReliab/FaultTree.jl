using DD.BDD

@testset "FaultTreeBDD_prob1" begin
    top = ftbasic(:x) & ftbasic(:x)
    ft = FTree()
    f = ftree(ft, top)
    env = Dict(
        :x => 0.1
    )
    println(prob(ft, f, env))
end

@testset "FaultTreeBDD2" begin
    x = ftbasic(:x)
    top = ftkofn(2, x, x, x)
    ft = FTree()
    f = ftree(ft, top)
    env = Dict(
        :x => 0.1
    )
    println(prob(ft, f, env))
end

@testset "FaultTreeBDD_prob3" begin
    x = ftrepeated(:x)
    top = ftkofn(2, x, x, x)
    ft = FTree()
    f = ftree(ft, top)
    env = Dict(
        :x => 0.1
    )
    println(prob(ft, f, env))
end
