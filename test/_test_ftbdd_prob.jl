using DD.BDD

@testset "FaultTreeBDD_prob1" begin
    ft = FTree()
    top = ftbasic(ft, :x) & ftbasic(ft, :x)
    ftbdd!(ft, top)
    env = Dict(
        :x => 0.1
    )
    println(prob(ft, top, env=env))
end

@testset "FaultTreeBDD2" begin
    ft = FTree()
    x = ftbasic(ft, :x)
    top = ftkofn(ft, 2, x, x, x)
    f = ftbdd!(ft, top)
    env = Dict(
        :x => 0.1
    )
    println(prob(ft, f, env=env))
end

@testset "FaultTreeBDD_prob3" begin
    ft = FTree()
    x = ftrepeated(ft, :x)
    top = ftkofn(ft, 2, x, x, x)
    f = ftbdd!(ft, top)
    env = Dict(
        :x => 0.1
    )
    println(prob(ft, f, env=env))
end
