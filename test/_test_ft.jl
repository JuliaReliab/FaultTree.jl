@testset "FaultTree1" begin
    ft = FTree()
    top = ftbasic(ft, :x) & ftbasic(ft, :x)
    println(top)
end

@testset "FaultTree1" begin
    ft = FTree()
    top = ftbasic(ft, :x) & ftrepeated(ft, :u) | ftbasic(ft, :x)
    println(top)
end

