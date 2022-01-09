@testset "mcs1" begin
    @ftree testft(px, py, pz) begin
        @repeat begin
            x = px
            y = py
            z = pz
        end
        top = x * y + z
    end
    f = testft(0.9, 0.8, 0.5)

    result = mcs(f.bdd, f.top)
    println(result)
end

@testset "mcs1+" begin
    @ftree testft(px, py, pz) begin
        @repeat begin
            x = px
            y = py
            z = pz
        end
        top = x * y + z
    end
    f = testft(0.9, 0.8, 0.5)

    result = mcs(f)
    println(result)
end

@testset "mcs2" begin
    @ftree CLUSTER(CM, switch, appserver, proxy, BLADE, nic) begin
        @repeat begin
            CM1 = CM
            CM2 = CM
            esw1 = switch
            esw2 = switch
            esw3 = switch
            esw4 = switch
        end
        @basic begin
            SW = appserver
            SWP = proxy
        end
        @repeat begin
            Node_A = BLADE
            nic1_A = nic
            nic2_A = nic
            Node_B = BLADE
            nic1_B = nic
            nic2_B = nic
            Node_C = BLADE
            nic1_C = nic
            nic2_C = nic
            Node_D = BLADE
            nic1_D = nic
            nic2_D = nic
            Node_E = BLADE
            nic1_E = nic
            nic2_E = nic
            Node_F = BLADE
            nic1_F = nic
            nic2_F = nic
            Node_G = BLADE
            nic1_G = nic
            nic2_G = nic
            Node_H = BLADE
            nic1_H = nic
            nic2_H = nic
        end

        eth1_A = nic1_A | esw1
        eth2_A = nic2_A | esw2
        eth_A = eth1_A & eth2_A
        BS_A = Node_A | eth_A

        eth1_B = nic1_B | esw1
        eth2_B = nic2_B | esw2
        eth_B = eth1_B & eth2_B
        BS_B = Node_B | eth_B

        eth1_C = nic1_C | esw1
        eth2_C = nic2_C | esw2
        eth_C = eth1_C & eth2_C
        BS_C = Node_C | eth_C

        eth1_D = nic1_D | esw3
        eth2_D = nic2_D | esw4
        eth_D = eth1_D & eth2_D
        BS_D = Node_D | eth_D

        eth1_E = nic1_E | esw3
        eth2_E = nic2_E | esw4
        eth_E = eth1_E & eth2_E
        BS_E = Node_E | eth_E

        eth1_F = nic1_F | esw3
        eth2_F = nic2_F | esw4
        eth_F = eth1_F & eth2_F
        BS_F = Node_F | eth_F

        eth1_G = nic1_G | esw1
        eth2_G = nic2_G | esw2
        eth_G = eth1_G & eth2_G
        BS_G = Node_G | eth_G

        eth1_H = nic1_H | esw3
        eth2_H = nic2_H | esw4
        eth_H = eth1_H & eth2_H
        BS_H = Node_H | eth_H

        AS1 = SW | BS_A | CM1
        AS2 = SW | BS_A | CM1
        AS3 = SW | BS_B | CM1
        AS4 = SW | BS_B | CM1
        AS5 = SW | BS_C | CM1
        AS6 = SW | BS_C | CM1
        AS7 = SW | BS_D | CM2
        AS8 = SW | BS_D | CM2
        AS9 = SW | BS_E | CM2
        AS10 = SW | BS_E | CM2
        AS11 = SW | BS_F | CM2
        AS12 = SW | BS_F | CM2
        apps = kofn(6, AS1, AS2, AS3, AS4, AS5, AS6, AS7, AS8, AS9, AS10, AS11, AS12)

        PX1 = SWP | BS_G | CM1
        PX2 = SWP | BS_H | CM2
        pxys = PX1 & PX2

        top = apps | pxys
    end

    @bind begin
        cm = 0.496
        switch = 0.01
        appserver = 0.02
        proxy = 0.02
        blade = 0.3363832
        nic = 0.1
    end

    @time f = CLUSTER(cm, switch, appserver, proxy, blade, nic)
    @time result = mcs(f.bdd, f.top)
    println(length(result))
    @time m = prob(f)
    @time result = seval(m)
    println(result)
    println(f.bdd.totalnodeid)
end