using DD.BDD

@testset "FaultTreeBDD1" begin
    top = ftbasic(:x) & ftbasic(:x)
    ft = FTree()
    f = ftree(ft, top)
    println(todot(f))
end

@testset "FaultTreeBDD2" begin
    x = ftbasic(:x)
    top = ftkofn(2, x, x, x)
    ft = FTree()
    f = ftree(ft, top)
    println(todot(f))
end
