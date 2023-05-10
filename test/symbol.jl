# @testset "SymbolFaultTree1" begin
#     @ftree testft(px, py, pz) begin
#         @repeated begin
#             x = px
#             y = py
#             z = pz
#         end
#         top = x * y + z
#     end
#     @vars px py pz
#     f = testft(px, py, pz)
#     println(typeof(f))
#     e = prob(f)
#     println(typeof(e))
# end

# @testset "SymbolFaultTree2" begin
#     @ftree testft(px, py, pz) begin
#         @repeated begin
#             x = px
#             y = py
#             z = pz
#         end
#         top = x * y + z
#     end
#     @vars px py pz
#     f = testft(px, py, pz)
#     println(typeof(f))
#     e = prob(f)
#     println(typeof(e))
#     @bind begin
#         px = 0.9
#         py = 0.5
#         pz = 0.6
#     end
#     @test seval(e) == 1 - (1 - 0.9 * 0.5) * (1 - 0.6)
# end

# @testset "SymbolFaultTree3" begin
#     @ftree testft(px, py, pz) begin
#         @repeated begin
#             x = px
#             y = py
#             z = pz
#         end
#         top = x * y + z
#     end
#     @vars px py pz
#     f = testft(px, py, pz)
#     println(typeof(f))
#     e = prob(f)
#     println(typeof(e))
#     @bind begin
#         px = 0.9
#         py = 0.5
#         pz = 0.6
#     end
#     @test seval(e, :px) == (1 - 0.6) * 0.5
# end

# @testset "SymbolFaultTree4" begin
#     @ftree testft(px, py, pz) begin
#         @repeated begin
#             x = px
#             y = py
#             z = pz
#         end
#         top = x * y + z
#     end
#     @vars px py pz
#     f = testft(px, py, pz)
#     println(typeof(f))
#     e = prob(f)
#     println(typeof(e))
#     @bind begin
#         px = 0.9
#         py = 0.5
#         pz = 0.6
#     end
#     @test seval(e, (:px, :py)) == 1 - 0.6
# end
