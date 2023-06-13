using VSPGeom
using Test

@testset "1-component file" begin
    compList = readDegenGeom("geom1.csv"; verbose=false)
    comp = compList[1]

    @test length(compList) == 1

    @test comp.type == "LIFTING_SURFACE"
    @test comp.name == "WingGeom"
    @test comp.SurfNdx == 0
    @test comp.GeomID == "JQAHXXAFRR"
    @test comp.MainSurfNdx == 0
    @test comp.SymCopyNdx == 0

    @test size(comp.surface_node) == (15, 5)
    @test degenGeomSize(comp.surface_node) == (3, 5)

    @test size(comp.surface_face) == (8, 4)
    @test degenGeomSize(comp.surface_face) == (2, 4)

    @test size(comp.plate) == (9, 14)
    @test degenGeomSize(comp.plate) == (3, 3)

    @test size(comp.stick_node) == (3, 67)
    @test degenGeomSize(comp.stick_node) == (3, 1)

    @test size(comp.stick_face) == (2, 4)
    @test degenGeomSize(comp.stick_face) == (2, 1)

    @test size(comp.point) == (1, 22)
    @test degenGeomSize(comp.point) == (1, 1)
end

@testset "2-component file" begin
    comp = readDegenGeom("geom2.csv"; verbose=false)

    @test length(comp) == 2

    @test comp[1].type == "LIFTING_SURFACE"
    @test comp[1].name == "WingGeom"
    @test comp[1].SurfNdx == 0
    @test comp[1].GeomID == "DEDCFKVXLQ"
    @test comp[1].MainSurfNdx == 0
    @test comp[1].SymCopyNdx == 0

    @test size(comp[1].surface_node) == (15, 5)
    @test degenGeomSize(comp[1].surface_node) == (3, 5)

    @test size(comp[1].surface_face) == (8, 4)
    @test degenGeomSize(comp[1].surface_face) == (2, 4)

    @test size(comp[1].plate) == (9, 14)
    @test degenGeomSize(comp[1].plate) == (3, 3)

    @test size(comp[1].stick_node) == (3, 67)
    @test degenGeomSize(comp[1].stick_node) == (3, 1)

    @test size(comp[1].stick_face) == (2, 4)
    @test degenGeomSize(comp[1].stick_face) == (2, 1)

    @test size(comp[1].point) == (1, 22)
    @test degenGeomSize(comp[1].point) == (1, 1)

    @test comp[2].type == "BODY"
    @test comp[2].name == "FuselageGeom"
    @test comp[2].SurfNdx == 0
    @test comp[2].GeomID == "HLXZCNWTXO"
    @test comp[2].MainSurfNdx == 0
    @test comp[2].SymCopyNdx == 0

    @test size(comp[2].surface_node) == (18, 5)
    @test degenGeomSize(comp[2].surface_node) == (2, 9)

    @test size(comp[2].surface_face) == (8, 4)
    @test degenGeomSize(comp[2].surface_face) == (1, 8)

    @test size(comp[2].plate) == (10, 14)
    @test degenGeomSize(comp[2].plate) == (2, 5)

    @test size(comp[2].stick_node) == (2, 67)
    @test degenGeomSize(comp[2].stick_node) == (2, 1)

    @test size(comp[2].stick_face) == (1, 4)
    @test degenGeomSize(comp[2].stick_face) == (1, 1)

    @test size(comp[2].point) == (1, 22)
    @test degenGeomSize(comp[2].point) == (1, 1)
end
