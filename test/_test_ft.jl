@testset "FaultTree1" begin
    top = ftbasic(:x) & ftbasic(:x)
    println(top)
end

@testset "FaultTree1" begin
    top = ftbasic(:x) & ftrepeated(:u) | ftbasic(:x)
    println(top)
end

