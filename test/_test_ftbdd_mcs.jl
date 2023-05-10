using DD.BDD

@testset "FaultTreeBDD_MCS1" begin
    top = ftbasic(:x) & ftbasic(:x)
    f = ftree(top)
    result = mcs(f)
    println(result)
end

@testset "FaultTreeBDD_MCS2" begin
    x = ftbasic(:x)
    top = ftkofn(2, x, x, x)
    f = ftree(top)
    result = mcs(f)
    println(result)
end

@testset "FaultTreeBDD_MCS3" begin
    x = ftrepeated(:x)
    y = ftrepeated(:y)
    z = ftrepeated(:z)
    top = x * y + z
    f = ftree(top)
    result = mcs(f)
    println(result)
end
