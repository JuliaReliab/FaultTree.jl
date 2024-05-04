using DD.BDD

@testset "Sample" begin
    ft = FTree()

    @basic ft A
    @repeated ft B, C
    
    top = (A | B) & C
    
    env = @parameters begin
        A = 0.1
        B = 0.3
        C = 0.5
    end
    
    x = ftbdd!(ft, top)
    println(prob(ft, x, env=env))
    println(mcs(ft, x))
end

@testset "Sample0" begin
    ft = FTree()
    @repeated ft midplane, cooling, power
    cm = ftbdd!(ft, midplane | cooling | power)

    env = @parameters begin
        midplane = 0.8
        cooling = 0.5
        power = 0.3
    end

    @time println(prob(ft, cm, env=env))
    @time println(prob(ft, cm, env=env))
end

@testset "Sample1" begin
    ft = FTree()

    Node = [ftrepeated(ft, Symbol("Node_", x)) for x = 1:8]
    nic1 = [ftrepeated(ft, Symbol("nic1_", x)) for x = 1:8]
    nic2 = [ftrepeated(ft, Symbol("nic2_", x)) for x = 1:8]
    CM = [ftrepeated(ft, Symbol("CM", i)) for i = 1:2]
    esw = [ftrepeated(ft, Symbol("esw", i)) for i = 1:4]
    @basic ft SW, SWP

    eth1 = Vector{AbstractFTObject}(undef, 8)
    eth2 = Vector{AbstractFTObject}(undef, 8)
    eth = Vector{AbstractFTObject}(undef, 8)
    BS = Vector{AbstractFTObject}(undef, 8)
    AS = Vector{AbstractFTObject}(undef, 12)

    for i = 1:8
        if i in [1,2,3,7]
            eth1[i] = nic1[i] | esw[1]
            eth2[i] = nic2[i] | esw[2]
        end
        if i in [4,5,6,8]
            eth1[i] = nic1[i] | esw[3]
            eth2[i] = nic2[i] | esw[4]
        end
        eth[i] = eth1[i] & eth2[i]
        BS[i] = Node[i] | eth[i]
    end

    for i = 1:12
        if i in [1,2,3,4,5,6]
            AS[i] = SW | BS[div(i,2)+1] | CM[1]
        end
        if i in [6,7,8,9,10,11,12]
            AS[i] = SW | BS[div(i,2)+1] | CM[2]
        end
    end

    PX1 = SWP | BS[7] | CM[1]
    PX2 = SWP | BS[8] | CM[2]
    pxys = PX1 & PX2
    
    apps = ftkofn(ft, 6, [AS[i] for i = 1:12]...)
    top = apps | pxys

    # ftbdd!(ft, top)
    # open("result.txt", "w") do iow
    #     write(iow, todot(gettop(f)))
    # end

    env = Dict(
        [symbol(x) => 0.1 for x = Node]...,
        [symbol(x) => 0.01 for x = nic1]...,
        [symbol(x) => 0.02 for x = nic2]...,
        [symbol(x) => 0.02 for x = CM]...,
        [symbol(x) => 0.001 for x = esw]...,
        :SW => 0.001,
        :SWP => 0.1
    )

    @time println(prob(ft, top, env=env))
    @time println(prob(ft, top, env=env))
    @time println(grad(ft, top, env=env))
    @time println(smeas(ft, top))
end

@testset "example" begin
    ft = FTree()

    @basic ft A
    @repeated ft B, C
    
    top = (A | B) & C
    
    env = @parameters begin
        A = 0.9
        B = 0.98
        C = 0.89
    end
    
    println(prob(ft, top, env=env))
    println(mcs(ft, top))
    println(smeas(ft, top))
    println(bmeas(ft, top, env=env))
    println(c1meas(ft, top, env=env))
    println(c0meas(ft, top, env=env))
end

# @testset "Sample2" begin
#     @ftree CM(midplane, cooling, power) begin
#         @repeated begin
#             MP = midplane
#             Cool = cooling
#             Pwr = power
#         end
#         top = MP | Cool | Pwr
#     end

#     @ftree BLADE(base, processor, memory, disk, os) begin
#         @repeated begin
#             Base = base
#             CPU = processor
#             Mem = memory
#             RAID = disk
#             OS = os
#         end
#         top = Base | CPU | Mem | RAID | OS
#     end

#     @ftree CLUSTER(CM, switch, appserver, proxy, BLADE, nic) begin
#         @repeated begin
#             CM1 = prob(CM)
#             CM2 = prob(CM)
#             esw1 = switch
#             esw2 = switch
#             esw3 = switch
#             esw4 = switch
#         end
#         @basic begin
#             SW = appserver
#             SWP = proxy
#         end
#         @repeated begin
#             Node_A = prob(BLADE)
#             nic1_A = nic
#             nic2_A = nic
#             Node_B = prob(BLADE)
#             nic1_B = nic
#             nic2_B = nic
#             Node_C = prob(BLADE)
#             nic1_C = nic
#             nic2_C = nic
#             Node_D = prob(BLADE)
#             nic1_D = nic
#             nic2_D = nic
#             Node_E = prob(BLADE)
#             nic1_E = nic
#             nic2_E = nic
#             Node_F = prob(BLADE)
#             nic1_F = nic
#             nic2_F = nic
#             Node_G = prob(BLADE)
#             nic1_G = nic
#             nic2_G = nic
#             Node_H = prob(BLADE)
#             nic1_H = nic
#             nic2_H = nic
#         end

#         eth1_A = nic1_A | esw1
#         eth2_A = nic2_A | esw2
#         eth_A = eth1_A & eth2_A
#         BS_A = Node_A | eth_A

#         eth1_B = nic1_B | esw1
#         eth2_B = nic2_B | esw2
#         eth_B = eth1_B & eth2_B
#         BS_B = Node_B | eth_B

#         eth1_C = nic1_C | esw1
#         eth2_C = nic2_C | esw2
#         eth_C = eth1_C & eth2_C
#         BS_C = Node_C | eth_C

#         eth1_D = nic1_D | esw3
#         eth2_D = nic2_D | esw4
#         eth_D = eth1_D & eth2_D
#         BS_D = Node_D | eth_D

#         eth1_E = nic1_E | esw3
#         eth2_E = nic2_E | esw4
#         eth_E = eth1_E & eth2_E
#         BS_E = Node_E | eth_E

#         eth1_F = nic1_F | esw3
#         eth2_F = nic2_F | esw4
#         eth_F = eth1_F & eth2_F
#         BS_F = Node_F | eth_F

#         eth1_G = nic1_G | esw1
#         eth2_G = nic2_G | esw2
#         eth_G = eth1_G & eth2_G
#         BS_G = Node_G | eth_G

#         eth1_H = nic1_H | esw3
#         eth2_H = nic2_H | esw4
#         eth_H = eth1_H & eth2_H
#         BS_H = Node_H | eth_H

#         AS1 = SW | BS_A | CM1
#         AS2 = SW | BS_A | CM1
#         AS3 = SW | BS_B | CM1
#         AS4 = SW | BS_B | CM1
#         AS5 = SW | BS_C | CM1
#         AS6 = SW | BS_C | CM1
#         AS7 = SW | BS_D | CM2
#         AS8 = SW | BS_D | CM2
#         AS9 = SW | BS_E | CM2
#         AS10 = SW | BS_E | CM2
#         AS11 = SW | BS_F | CM2
#         AS12 = SW | BS_F | CM2
#         apps = kofn(6, AS1, AS2, AS3, AS4, AS5, AS6, AS7, AS8, AS9, AS10, AS11, AS12)

#         PX1 = SWP | BS_G | CM1
#         PX2 = SWP | BS_H | CM2
#         pxys = PX1 & PX2

#         top = apps | pxys
#     end

#     midplane = 0.1
#     cooling = 0.2
#     power = 0.3

#     base = 0.1
#     processor = 0.01
#     memory = 0.05
#     disk = 0.02
#     os = 0.2

#     switch = 0.01
#     appserver = 0.02
#     proxy = 0.02
#     nic = 0.1

#     @time cm = CM(midplane, cooling, power)
#     @time cm = CM(midplane, cooling, power)
#     @time result = prob(cm)
#     @time result = prob(cm)
#     println(result)

#     @time blade = BLADE(base, processor, memory, disk, os)
#     @time blade = BLADE(base, processor, memory, disk, os)
#     @time result = prob(blade)
#     @time result = prob(blade)
#     println(result)

#     @time f = CLUSTER(cm, switch, appserver, proxy, blade, nic)
#     @time f = CLUSTER(cm, switch, appserver, proxy, blade, nic)
#     @time result = prob(f)
#     @time result = prob(f)
#     println(result)
#     println(f.bdd.totalnodeid)
# end

# @testset "Sample3-" begin
#     @ftree CLUSTER(CM, switch, appserver, proxy, BLADE, nic) begin
#         @repeated begin
#             CM1 = CM
#             CM2 = CM
#             esw1 = switch
#             esw2 = switch
#             esw3 = switch
#             esw4 = switch
#         end
#         @basic begin
#             SW = appserver
#             SWP = proxy
#         end
#         @repeated begin
#             Node_A = BLADE
#             nic1_A = nic
#             nic2_A = nic
#             Node_B = BLADE
#             nic1_B = nic
#             nic2_B = nic
#             Node_C = BLADE
#             nic1_C = nic
#             nic2_C = nic
#             Node_D = BLADE
#             nic1_D = nic
#             nic2_D = nic
#             Node_E = BLADE
#             nic1_E = nic
#             nic2_E = nic
#             Node_F = BLADE
#             nic1_F = nic
#             nic2_F = nic
#             Node_G = BLADE
#             nic1_G = nic
#             nic2_G = nic
#             Node_H = BLADE
#             nic1_H = nic
#             nic2_H = nic
#         end

#         eth1_A = nic1_A | esw1
#         eth2_A = nic2_A | esw2
#         eth_A = eth1_A & eth2_A
#         BS_A = Node_A | eth_A

#         eth1_B = nic1_B | esw1
#         eth2_B = nic2_B | esw2
#         eth_B = eth1_B & eth2_B
#         BS_B = Node_B | eth_B

#         eth1_C = nic1_C | esw1
#         eth2_C = nic2_C | esw2
#         eth_C = eth1_C & eth2_C
#         BS_C = Node_C | eth_C

#         eth1_D = nic1_D | esw3
#         eth2_D = nic2_D | esw4
#         eth_D = eth1_D & eth2_D
#         BS_D = Node_D | eth_D

#         eth1_E = nic1_E | esw3
#         eth2_E = nic2_E | esw4
#         eth_E = eth1_E & eth2_E
#         BS_E = Node_E | eth_E

#         eth1_F = nic1_F | esw3
#         eth2_F = nic2_F | esw4
#         eth_F = eth1_F & eth2_F
#         BS_F = Node_F | eth_F

#         eth1_G = nic1_G | esw1
#         eth2_G = nic2_G | esw2
#         eth_G = eth1_G & eth2_G
#         BS_G = Node_G | eth_G

#         eth1_H = nic1_H | esw3
#         eth2_H = nic2_H | esw4
#         eth_H = eth1_H & eth2_H
#         BS_H = Node_H | eth_H

#         AS1 = SW | BS_A | CM1
#         AS2 = SW | BS_A | CM1
#         AS3 = SW | BS_B | CM1
#         AS4 = SW | BS_B | CM1
#         AS5 = SW | BS_C | CM1
#         AS6 = SW | BS_C | CM1
#         AS7 = SW | BS_D | CM2
#         AS8 = SW | BS_D | CM2
#         AS9 = SW | BS_E | CM2
#         AS10 = SW | BS_E | CM2
#         AS11 = SW | BS_F | CM2
#         AS12 = SW | BS_F | CM2
#         apps = kofn(6, AS1, AS2, AS3, AS4, AS5, AS6, AS7, AS8, AS9, AS10, AS11, AS12)

#         PX1 = SWP | BS_G | CM1
#         PX2 = SWP | BS_H | CM2
#         pxys = PX1 & PX2

#         top = apps | pxys
#     end

#     @bind begin
#         cm = 0.496
#         switch = 0.01
#         appserver = 0.02
#         proxy = 0.02
#         blade = 0.3363832
#         nic = 0.1
#     end

#     @time f = CLUSTER(cm, switch, appserver, proxy, blade, nic)
#     @time f = CLUSTER(cm, switch, appserver, proxy, blade, nic)
#     @time m = prob(f)
#     @time m = prob(f)
#     @time result = seval(m)
#     @time result = seval(m)
#     println(result)
#     println(f.bdd.totalnodeid)
# end

# @testset "Sample3" begin
#     @ftree CM(midplane, cooling, power) begin
#         @repeated begin
#             MP = midplane
#             Cool = cooling
#             Pwr = power
#         end
#         top = MP | Cool | Pwr
#     end

#     @ftree BLADE(base, processor, memory, disk, os) begin
#         @repeated begin
#             Base = base
#             CPU = processor
#             Mem = memory
#             RAID = disk
#             OS = os
#         end
#         top = Base | CPU | Mem | RAID | OS
#     end

#     @ftree CLUSTER(CM, switch, appserver, proxy, BLADE, nic) begin
#         @repeated begin
#             CM1 = prob(CM)
#             CM2 = prob(CM)
#             esw1 = switch
#             esw2 = switch
#             esw3 = switch
#             esw4 = switch
#         end
#         @basic begin
#             SW = appserver
#             SWP = proxy
#         end
#         @repeated begin
#             Node_A = prob(BLADE)
#             nic1_A = nic
#             nic2_A = nic
#             Node_B = prob(BLADE)
#             nic1_B = nic
#             nic2_B = nic
#             Node_C = prob(BLADE)
#             nic1_C = nic
#             nic2_C = nic
#             Node_D = prob(BLADE)
#             nic1_D = nic
#             nic2_D = nic
#             Node_E = prob(BLADE)
#             nic1_E = nic
#             nic2_E = nic
#             Node_F = prob(BLADE)
#             nic1_F = nic
#             nic2_F = nic
#             Node_G = prob(BLADE)
#             nic1_G = nic
#             nic2_G = nic
#             Node_H = prob(BLADE)
#             nic1_H = nic
#             nic2_H = nic
#         end

#         eth1_A = nic1_A | esw1
#         eth2_A = nic2_A | esw2
#         eth_A = eth1_A & eth2_A
#         BS_A = Node_A | eth_A

#         eth1_B = nic1_B | esw1
#         eth2_B = nic2_B | esw2
#         eth_B = eth1_B & eth2_B
#         BS_B = Node_B | eth_B

#         eth1_C = nic1_C | esw1
#         eth2_C = nic2_C | esw2
#         eth_C = eth1_C & eth2_C
#         BS_C = Node_C | eth_C

#         eth1_D = nic1_D | esw3
#         eth2_D = nic2_D | esw4
#         eth_D = eth1_D & eth2_D
#         BS_D = Node_D | eth_D

#         eth1_E = nic1_E | esw3
#         eth2_E = nic2_E | esw4
#         eth_E = eth1_E & eth2_E
#         BS_E = Node_E | eth_E

#         eth1_F = nic1_F | esw3
#         eth2_F = nic2_F | esw4
#         eth_F = eth1_F & eth2_F
#         BS_F = Node_F | eth_F

#         eth1_G = nic1_G | esw1
#         eth2_G = nic2_G | esw2
#         eth_G = eth1_G & eth2_G
#         BS_G = Node_G | eth_G

#         eth1_H = nic1_H | esw3
#         eth2_H = nic2_H | esw4
#         eth_H = eth1_H & eth2_H
#         BS_H = Node_H | eth_H

#         AS1 = SW | BS_A | CM1
#         AS2 = SW | BS_A | CM1
#         AS3 = SW | BS_B | CM1
#         AS4 = SW | BS_B | CM1
#         AS5 = SW | BS_C | CM1
#         AS6 = SW | BS_C | CM1
#         AS7 = SW | BS_D | CM2
#         AS8 = SW | BS_D | CM2
#         AS9 = SW | BS_E | CM2
#         AS10 = SW | BS_E | CM2
#         AS11 = SW | BS_F | CM2
#         AS12 = SW | BS_F | CM2
#         apps = kofn(6, AS1, AS2, AS3, AS4, AS5, AS6, AS7, AS8, AS9, AS10, AS11, AS12)

#         PX1 = SWP | BS_G | CM1
#         PX2 = SWP | BS_H | CM2
#         pxys = PX1 & PX2

#         top = apps | pxys
#     end

#     @bind begin
#         midplane = 0.1
#         cooling = 0.2
#         power = 0.3
#         base = 0.1
#         processor = 0.01
#         memory = 0.05
#         disk = 0.02
#         os = 0.2
#         switch = 0.01
#         appserver = 0.02
#         proxy = 0.02
#         nic = 0.1
#     end

#     @time cm = CM(midplane, cooling, power)
#     @time cm = CM(midplane, cooling, power)
#     @time m = prob(cm)
#     @time m = prob(cm)
#     @time result = seval(m)
#     @time result = seval(m)
#     println(result)

#     @time blade = BLADE(base, processor, memory, disk, os)
#     @time blade = BLADE(base, processor, memory, disk, os)
#     @time m = prob(blade)
#     @time m = prob(blade)
#     @time result = seval(m)
#     @time result = seval(m)
#     println(result)

#     @time f = CLUSTER(cm, switch, appserver, proxy, blade, nic)
#     @time f = CLUSTER(cm, switch, appserver, proxy, blade, nic)
#     @time m = prob(f)
#     @time m = prob(f)
#     @time result = seval(m)
#     @time result = seval(m)
#     println(result)
#     println(f.bdd.totalnodeid)
# end

# @testset "Sample4" begin
#     @ftree CM(midplane, cooling, power) begin
#         @repeated begin
#             MP = midplane
#             Cool = cooling
#             Pwr = power
#         end
#         top = MP | Cool | Pwr
#     end

#     @ftree BLADE(base, processor, memory, disk, os) begin
#         @repeated begin
#             Base = base
#             CPU = processor
#             Mem = memory
#             RAID = disk
#             OS = os
#         end
#         top = Base | CPU | Mem | RAID | OS
#     end

#     @ftree CLUSTER(CM, switch, appserver, proxy, BLADE, nic) begin
#         @repeated begin
#             CM1 = CM
#             CM2 = CM
#             esw1 = switch
#             esw2 = switch
#             esw3 = switch
#             esw4 = switch
#         end
#         @basic begin
#             SW = appserver
#             SWP = proxy
#         end
#         @repeated begin
#             Node_A = BLADE
#             nic1_A = nic
#             nic2_A = nic
#             Node_B = BLADE
#             nic1_B = nic
#             nic2_B = nic
#             Node_C = BLADE
#             nic1_C = nic
#             nic2_C = nic
#             Node_D = BLADE
#             nic1_D = nic
#             nic2_D = nic
#             Node_E = BLADE
#             nic1_E = nic
#             nic2_E = nic
#             Node_F = BLADE
#             nic1_F = nic
#             nic2_F = nic
#             Node_G = BLADE
#             nic1_G = nic
#             nic2_G = nic
#             Node_H = BLADE
#             nic1_H = nic
#             nic2_H = nic
#         end

#         eth1_A = nic1_A | esw1
#         eth2_A = nic2_A | esw2
#         eth_A = eth1_A & eth2_A
#         BS_A = Node_A | eth_A

#         eth1_B = nic1_B | esw1
#         eth2_B = nic2_B | esw2
#         eth_B = eth1_B & eth2_B
#         BS_B = Node_B | eth_B

#         eth1_C = nic1_C | esw1
#         eth2_C = nic2_C | esw2
#         eth_C = eth1_C & eth2_C
#         BS_C = Node_C | eth_C

#         eth1_D = nic1_D | esw3
#         eth2_D = nic2_D | esw4
#         eth_D = eth1_D & eth2_D
#         BS_D = Node_D | eth_D

#         eth1_E = nic1_E | esw3
#         eth2_E = nic2_E | esw4
#         eth_E = eth1_E & eth2_E
#         BS_E = Node_E | eth_E

#         eth1_F = nic1_F | esw3
#         eth2_F = nic2_F | esw4
#         eth_F = eth1_F & eth2_F
#         BS_F = Node_F | eth_F

#         eth1_G = nic1_G | esw1
#         eth2_G = nic2_G | esw2
#         eth_G = eth1_G & eth2_G
#         BS_G = Node_G | eth_G

#         eth1_H = nic1_H | esw3
#         eth2_H = nic2_H | esw4
#         eth_H = eth1_H & eth2_H
#         BS_H = Node_H | eth_H

#         AS1 = SW | BS_A | CM1
#         AS2 = SW | BS_A | CM1
#         AS3 = SW | BS_B | CM1
#         AS4 = SW | BS_B | CM1
#         AS5 = SW | BS_C | CM1
#         AS6 = SW | BS_C | CM1
#         AS7 = SW | BS_D | CM2
#         AS8 = SW | BS_D | CM2
#         AS9 = SW | BS_E | CM2
#         AS10 = SW | BS_E | CM2
#         AS11 = SW | BS_F | CM2
#         AS12 = SW | BS_F | CM2
#         apps = kofn(6, AS1, AS2, AS3, AS4, AS5, AS6, AS7, AS8, AS9, AS10, AS11, AS12)

#         PX1 = SWP | BS_G | CM1
#         PX2 = SWP | BS_H | CM2
#         pxys = PX1 & PX2

#         top = apps | pxys
#     end

#     @bind begin
#         midplane = 0.1
#         cooling = 0.2
#         power = 0.3
#         base = 0.1
#         processor = 0.01
#         memory = 0.05
#         disk = 0.02
#         os = 0.2
#         switch = 0.01
#         appserver = 0.02
#         proxy = 0.02
#         nic = 0.1
#     end

#     @time cm = CM(midplane, cooling, power)
#     @time cm = CM(midplane, cooling, power)
#     @time m = prob(cm)
#     @time m = prob(cm)
#     @time result = seval(m)
#     @time result = seval(m)
#     println(result)

#     @time blade = BLADE(base, processor, memory, disk, os)
#     @time blade = BLADE(base, processor, memory, disk, os)
#     @time m = prob(blade)
#     @time m = prob(blade)
#     @time result = seval(m)
#     @time result = seval(m)
#     println(result)

#     @time f = CLUSTER(prob(cm), switch, appserver, proxy, prob(blade), nic)
#     @time f = CLUSTER(prob(cm), switch, appserver, proxy, prob(blade), nic)
#     @time m = prob(f)
#     @time m = prob(f)
#     @time result = seval(m)
#     @time result = seval(m)
#     println(result)
# end