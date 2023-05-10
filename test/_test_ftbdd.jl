using DD.BDD

@testset "FaultTreeBDD1" begin
    top = ftbasic(:x) & ftbasic(:x)
    f = ftree(top)
    println(todot(f.top))
end

@testset "FaultTreeBDD2" begin
    x = ftbasic(:x)
    top = ftkofn(2, x, x, x)
    f = ftree(top)
    println(todot(f.top))
end
