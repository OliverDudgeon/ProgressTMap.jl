using ProgressTMap
using Test

@testset "ProgressTMap.jl" begin
  xs = 0:100

  ys = progress_tmap(x -> x^2, xs)

  @test xs .^ 2 == ys
end
