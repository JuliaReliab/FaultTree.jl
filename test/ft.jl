@testset "FaultTree1" begin
    @vars x y
    top = ftevent(:x) & ftevent(:y)
    println(todot(top))
    f = faulttree(Dict(:x=>x, :y=>y), top)
    println(BDD.todot(f.bdd, f.top))
end

@testset "FaultTree2" begin
    @faulttree testft(x, y, z) begin
        top = x * y + z
    end
    @vars x y z
    ftinstance = testft(x, y, z)
    env = SymbolicEnv()
    @bind env begin
        :x => 0.1
        :y => 0.2
        :z => 0.1
    end
    println(seval(ftinstance, env))
end

@testset "FaultTree3" begin
    @faulttree testft(x, y, z) begin
        top = x * y + z
    end
    @vars x y z
    ftinstance = testft(x, y, z)
    env = SymbolicEnv()
    @bind env begin
        :x => 0.1
        :y => 0.2
        :z => 0.1
    end
    println(seval(ftinstance, :x, env))
end

@testset "FaultTree4" begin
    @faulttree testft(x, y, z) begin
        top = x * y + z
    end
    @vars x y z
    ftinstance = testft(x, y, z)
    env = SymbolicEnv()
    @bind env begin
        :x => 0.1
        :y => 0.2
        :z => 0.1
    end
    println(seval(ftinstance, (:x, :y), env))
end
