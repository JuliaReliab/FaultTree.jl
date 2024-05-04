using DD.BDD
import FaultTree: _tsort

@testset "FaultTreeBDD_tsort1" begin
    ft = FTree()
    @repeated ft x, y, z
    top = x & y | z
    f = ftbdd!(ft, top)
    println(todot(f))
    println(_tsort(f))
end

@testset "FaultTreeBDD_grad1" begin
    ft = FTree()
    @repeated ft x, y, z
    top = x & y | z
    f = ftbdd!(ft, top)
    env = @parameters begin
        x = 0.1
        y = 0.1
        z = 0.1
    end
    println(prob(ft, top, env=env))
    println(grad(ft, top, env=env))
end

@testset "FaultTreeBDD_grad1" begin
    ft = FTree()
    @repeated ft x, y, z
    top = x & y | z
    f = ftbdd!(ft, top)
    env = @parameters begin
        x = 1//2
        y = 1//2
        z = 1//2
    end
    println(prob(ft, top, env=env))
    println(grad(ft, top, env=env))
end

@testset "FaultTreeBDD_grad2" begin
    ft = FTree()
    @repeated ft a, b, c, d, e
    x1 = b & c & e
    x2 = b & d
    x3 = a & e
    x4 = a & c & d
    top = x1 | x2 | x3 | x4
    env = @parameters begin
        a = 1//2
        b = 1//2
        c = 1//2
        d = 1//2
        e = 1//2
    end
    println(mcs(ft, top))
    println(prob(ft, top, env=env))
    println(grad(ft, top, env=env))
    println(cgrad(ft, top, env=env))
end

@testset "FaultTreeBDD_grad2" begin
    ft = FTree()
    @repeated ft a, b, c, d, e
    x1 = b & c & e
    x2 = b & d
    x3 = a & e
    x4 = a & c & d
    top = x1 | x2 | x3 | x4
    env = @parameters begin
        a = 0.5
        b = 0.3
        c = 0.2
        d = 0.1
        e = 0.4
    end
    println(mcs(ft, top))
    println(prob(ft, top, env=env))
    println(grad(ft, top, env=env))
    println(cgrad(ft, top, env=env))
end

@testset "FaultTreeBDD_grad3" begin
    ft = FTree()
    @repeated ft a, b, c, d, e
    x1 = b & c & e
    x2 = b & d
    x3 = a & e
    x4 = a & c & d
    top = x1 | x2 | x3 | x4
    println(smeas(ft, top))
end

@testset "FaultTreeBDD_grad4" begin
    ft = FTree()
    @basic ft x, y, z
    x1 = x & y & z
    x2 = x & y & z
    top = x1 | x2
    println(smeas(ft, top))
end

@testset "FaultTreeBDD_grad5" begin
    ft = FTree()
    @repeated ft x1, y1, z1, x2, y2, z2
    xx1 = x1 & y1 & z1
    xx2 = x2 & y2 & z2
    top = xx1 | xx2
    println(smeas(ft, top))
end

@testset "FaultTreeBDD_grad6" begin
    ft = FTree()
    @repeated ft a, b, c, d, e
    x1 = b & c & e
    x2 = b & d
    x3 = a & e
    x4 = a & c & d
    top = x1 | x2 | x3 | x4
    env = @parameters begin
        a = 0.8
        b = 0.8
        c = 0.8
        d = 0.8
        e = 0.8
    end
    println(mcs(ft, top))
    println(smeas(ft, top))
    println(bmeas(ft, top, env=env))
    println(c1meas(ft, top, env=env))
    println(c0meas(ft, top, env=env))
end