using VSPGeom
using Test

@testset "Single component" begin
    comp = readfile("geom1.csv"; verbose=false)

    @test comp[1].name == "WingGeom"

end
    # comp2 = readfile("geom2.csv"; verbose=false)

