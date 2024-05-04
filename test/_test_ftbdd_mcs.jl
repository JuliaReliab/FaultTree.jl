using DD.BDD

@testset "FaultTreeBDD_MCS1" begin
    ft = FTree()
    top = ftbasic(ft, :x) & ftbasic(ft, :x)
    f = ftbdd!(ft, top)
    result = mcs(ft, f)
    println(result)
end

@testset "FaultTreeBDD_MCS2" begin
    ft = FTree()
    x = ftbasic(ft, :x)
    top = ftkofn(ft, 2, x, x, x)
    f = ftbdd!(ft, top)
    result = mcs(ft, f)
    println(result)
end

@testset "FaultTreeBDD_MCS3" begin
    ft = FTree()
    x = ftrepeated(ft, :x)
    y = ftrepeated(ft, :y)
    z = ftrepeated(ft, :z)
    top = x * y + z
    f = ftbdd!(ft, top)
    result = mcs(ft, top)
    println(result)
end

@testset "FaultTreeBDD_MCS4" begin
    ft = FTree()
    x = ftrepeated(ft, :x)
    y = ftrepeated(ft, :y)
    z = ftrepeated(ft, :z)
    top = (x | z) & (y | z)
    f = ftbdd!(ft, top)
    result = mcs(ft, top)
    println(result)

    b = minsol(f)
    println(todot(b))
    println(extractpath(b))
end
