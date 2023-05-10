using DD.BDD

@testset "FaultTreeBDD1" begin
    ft = FTree()
    top = ftbasic(:x) & ftbasic(:x)
    f = ftbdd!(ft, top)
    println(todot(f))
end

@testset "FaultTreeBDD2" begin
    ft = FTree()
    x = ftbasic(:x)
    top = ftkofn(2, x, x, x)
    f = ftbdd!(ft, top)
    println(todot(f))
end
