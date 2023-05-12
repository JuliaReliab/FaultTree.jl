using DD.BDD

@testset "FaultTreeBDD_MCS1" begin
    ft = FTree()
    top = ftbasic(:x) & ftbasic(:x)
    f = ftbdd!(ft, top)
    result = mcs(ft, f)
    println(result)
end

@testset "FaultTreeBDD_MCS2" begin
    ft = FTree()
    x = ftbasic(:x)
    top = ftkofn(2, x, x, x)
    f = ftbdd!(ft, top)
    result = mcs(ft, f)
    println(result)
end

@testset "FaultTreeBDD_MCS3" begin
    ft = FTree()
    x = ftrepeat(:x)
    y = ftrepeat(:y)
    z = ftrepeat(:z)
    top = x * y + z
    f = ftbdd!(ft, top)
    result = mcs(ft, top)
    println(result)
end
