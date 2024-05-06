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
    println(extractpath(mcs(ft, top)))
    println(smeas(ft, top))
    println(bmeas(ft, top, env=env))
    println(c1meas(ft, top, env=env))
    println(c0meas(ft, top, env=env))
end

@testset "euro1" begin
    ft = FTree()
    @repeated ft c[1:61]
    g69 = c[1] & c[9]
    g68 = c[1] & c[8]
    g67 = c[1] & c[7]
    g66 = c[1] & c[6]
    g65 = c[1] & c[5]
    g64 = c[1] & c[4]
    g63 = c[1] & c[3]
    g62 = c[1] & c[2]
    g70 = g62 | c[10]
    g71 = g63 | c[11]
    g72 = g64 | c[12]
    g73 = g65 | c[13]
    g74 = g62 | c[14]
    g75 = g63 | c[15]
    g76 = g64 | c[16]
    g77 = g65 | c[17]
    g78 = g62 | c[18]
    g79 = g63 | c[19]
    g80 = g64 | c[20]
    g81 = g65 | c[21]
    g82 = g62 | c[22]
    g83 = g63 | c[23]
    g84 = g64 | c[24]
    g85 = g65 | c[25]
    g86 = g62 | c[26]
    g87 = g63 | c[27]
    g88 = g64 | c[28]
    g89 = g65 | c[29]
    g90 = g66 | c[30]
    g91 = g68 | c[31]
    g92 = g67 | c[32]
    g93 = g69 | c[33]
    g94 = g66 | c[34]
    g95 = g68 | c[35]
    g96 = g67 | c[36]
    g97 = g69 | c[37]
    g98 = g66 | c[38]
    g99 = g68 | c[39]
    g100 = g67 | c[40]
    g101 = g69 | c[41]
    g102 = g66 | c[42]
    g103 = g68 | c[43]
    g104 = g67 | c[44]
    g105 = g69 | c[45]
    g106 = ftkofn(ft, 3, g70, g71, g72, g73)
    g107 = ftkofn(ft, 3, g74, g75, g76, g77)
    g108 = ftkofn(ft, 3, g78, g79, g80, g81)
    g109 = ftkofn(ft, 3, g82, g83, g84, g85)
    g110 = ftkofn(ft, 3, g86, g87, g88, g89)
    g111 = ftkofn(ft, 3, g94, g95, g96, g97)
    g112 = ftkofn(ft, 3, g98, g99, g100, g101)
    g113 = g90 & g92
    g114 = g91 & g93
    g115 = g102 & g104
    g116 = g103 & g105
    g117 = g113 | c[46]
    g118 = g114 | c[47]
    g119 = g107 | g108 | c[52]
    g120 = g109 | g110
    g121 = g66 | g117 | c[48]
    g122 = g68 | g118 | c[49]
    g123 = g67 | g117 | c[50]
    g124 = g69 | g118 | c[51]
    g125 = ftkofn(ft, 2, g121, g123, g122, g124)
    g126 = g111 | g112 | g125 | c[53]
    g127 = g115 & g120
    g128 = g116 & g120
    g129 = g62 | g127 | c[54]
    g130 = g63 | g128 | c[55]
    g131 = g64 | g127 | c[56]
    g132 = g65 | g128 | c[57]
    g133 = g62 | g129 | c[58]
    g134 = g63 | g130 | c[59]
    g135 = g64 | g131 | c[60]
    g136 = g65 | g132 | c[61]
    g137 = ftkofn(ft, 3, g133, g134, g135, g136)
    g138 = g106 | g119 | g137
    g139 = g62 | g66 | g117 | g129 | c[48]
    g140 = g63 | g68 | g118 | g130 | c[49]
    g141 = g64 | g67 | g117 | g131 | c[50]
    g142 = g65 | g69 | g118 | g132 | c[51]
    g143 = g139 & g140 & g141 & g142
    g144 = g111 | g112 | g143 | c[53]
    top = g126 & g138 & g144
    @time bdd = ftbdd!(ft, top)
    println(BDD.size(bdd))
    @time result = mcs(ft, bdd)
    println(size(result))
    @time result2 = smeas(ft, bdd)
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