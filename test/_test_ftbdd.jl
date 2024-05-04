using DD.BDD

@testset "FaultTreeBDD1" begin
    ft = FTree()
    top = ftbasic(ft, :x) & ftbasic(ft, :x)
    f = ftbdd!(ft, top)
    println(todot(f))
end

@testset "FaultTreeBDD2" begin
    ft = FTree()
    x = ftbasic(ft, :x)
    top = ftkofn(ft, 2, x, x, x)
    f = ftbdd!(ft, top)
    println(todot(f))
end
