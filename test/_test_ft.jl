@testset "FaultTree1" begin
    top = ftbasic(:x) & ftbasic(:x)
    println(top)
end

@testset "FaultTree1" begin
    top = ftbasic(:x) & ftrepeat(:u) | ftbasic(:x)
    println(top)
end

# @testset "FaultTree2" begin
#     x = 0.9
#     top = ftbasic(:x) & ftbasic(:x)
#     println(todot(top))
#     f = ftree(top, Dict(:x=>x))
#     println(BDD.todot(f.bdd, f.top))
#     println(cprob(f))
# end

# @testset "FaultTree3" begin
#     x = 0.9
#     top = ftbasic(:x) & ftbasic(:x)
#     println(todot(top))
#     f = ftree(top, Dict(:x=>x))
#     println(BDD.todot(f.bdd, f.top))
#     println(prob(f, type=:G))
# end

# @testset "FaultTree4" begin
#     x = 0.9
#     top = ftbasic(:x) & ftbasic(:x)
#     println(todot(top))
#     f = ftree(top, Dict(:x=>x))
#     println(BDD.todot(f.bdd, f.top))
#     println(cprob(f, type=:G))
# end

# @testset "FaultTreeMacro1" begin
#     env = Dict()
#     @basic env x = 0.9
#     top = x & x
#     println(todot(top))
#     f = ftree(top, env)
#     println(BDD.todot(f.bdd, f.top))
#     println(cprob(f, type=:G))
# end

# @testset "FaultTreeMacro2" begin
#     env = Dict()
#     @repeat env begin
#         x = 0.9
#         y = 0.8
#     end
#     top = x & y
#     println(todot(top))
#     f = ftree(top, env)
#     println(BDD.todot(f.bdd, f.top))
#     println(typeof(f))
#     println(prob(f, type=:F))
# end

# @testset "FaultTreeMacro3" begin
#     @ftree test(lam1, lam2) begin
#         @repeat begin
#             x = exp(-lam1)
#             y = exp(-lam2)
#         end
#         top = x & y
#     end
#     f = test(1.0, 2.0)
#     println(BDD.todot(f.bdd, f.top))
#     println(typeof(f))
#     println(prob(f))
# end

# @testset "FaultTreeMacro4" begin
#     @ftree test(lam1) begin
#         @repeat begin
#             x = exp(-lam1)
#         end
#         top = x & x
#     end
#     f = test(1.0)
#     println(BDD.todot(f.bdd, f.top))
#     println(typeof(f))
#     println(prob(f))
# end

# @testset "FaultTreeMacro5" begin
#     @ftree test(lam1) begin
#         @basic begin
#             x = exp(-lam1)
#         end
#         x & x
#     end
#     f = test(1.0)
#     println(BDD.todot(f.bdd, f.top))
#     println(typeof(f))
#     println(prob(f))
# end

# @testset "FaultTreeMacro6" begin
#     @ftree test(_x) begin
#         @basic begin
#             x = _x
#         end
#         x & x
#     end
#     f = test(:x)
#     println(BDD.todot(f.bdd, f.top))
#     println(typeof(f))
# end
