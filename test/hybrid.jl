## use SymbolicMarkov ^0.7.2 to run this test
using SymbolicMarkov

@testset "hybrid1" begin
    @ftree CM(midplane, cooling, power) begin
        @repeat begin
            MP = midplane
            Cool = cooling
            Pwr = power
        end
        top = MP | Cool | Pwr
    end
    @bind begin
        midplane = 0.8
        cooling = 0.5
        power = 0.3
    end
    cm = CM(midplane, cooling, power)
    @time println(seval(prob(cm), (midplane, cooling)))
end

@testset "hybrid2" begin
    @ftree CM(midplane, cooling, power) begin
        @repeat begin
            MP = midplane
            Cool = cooling
            Pwr = power
        end
        top = MP | Cool | Pwr
    end

    @markov midplane(lam, mu) begin
        @tr begin
            :up => :down, lam
            :down => :up, mu
        end
        @reward :r begin
            :up, 1
        end
    end

    @bind begin
        lam = 0.8
        mu = 1.5
        cooling = 0.5
        power = 0.3
    end

    m = ctmc(midplane(lam, mu), :DenseCTMC)

    cm = CM(exrss(m, reward=:r), cooling, power)
    @time println(seval(prob(cm)))
    seval(exrss(m, reward=:r), (lam, cooling))
end
