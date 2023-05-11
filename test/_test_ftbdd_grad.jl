using DD.BDD
import FaultTree: _tsort

@testset "FaultTreeBDD_tsort1" begin
    ft = FTree()
    @repeated x, y, z
    top = x & y | z
    f = ftbdd!(ft, top)
    println(todot(f))
    println(_tsort(f))
end

@testset "FaultTreeBDD_grad1" begin
    ft = FTree()
    @repeated x, y, z
    top = x & y | z
    f = ftbdd!(ft, top)
    env = @parameters begin
        x = 0.1
        y = 0.1
        z = 0.1
    end
    println(prob(ft, top, env))
    println(grad(ft, top, env))
end
