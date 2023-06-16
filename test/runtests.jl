using VSPGeom
using Test

@testset "1-component DegenGeom file" begin
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

@testset "2-component DegenGeom file" begin
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

@testset "1-component STL file" begin
    geom = readSTL("cube.stl")

    @test length(geom) == 1

    # Check a few vertices
    @test geom[1].position[1] ≈ [0.0, 0.0, 0.0]
    @test geom[1].position[3] ≈ [1.0, 0.0, 0.0]
    @test geom[1].position[end-2] ≈ [0.0, 0.0, 1.0]
    @test geom[1].position[end] ≈ [0.0, 1.0, 1.0]

    # Check a few normals
    @test geom[1].normals[1] ≈ [0.0, 0.0, -1.0]
    @test geom[1].normals[end] ≈ [0.0, 0.0, 1.0]

    # Check vetices of a cell
    @test geom[1][5].points[1] ≈ [0.0, 1.0, 0.0]
    @test geom[1][5].points[2] ≈ [1.0, 1.0, 1.0]
    @test geom[1][5].points[3] ≈ [1.0, 1.0, 0.0]
end

@testset "2-component STL file" begin
    geom = readSTL("geom2.stl")

    @test length(geom) == 2

    # Check a few vertices
    @test geom[1].position[1] ≈ [11.7636, 1.22787, -0.282198]
    @test geom[1].position[3] ≈ [11.4687, 1.2176, -0.340498]
    @test geom[1].position[end-2] ≈ [21.2149, 1.09203, 0.730005]
    @test geom[1].position[end] ≈ [21.5042, 1.07642, 0.762578]

    # Check a few normals
    @test geom[1].normals[1] ≈ [0.013477, 0.970861, -0.239264]
    @test geom[1].normals[end] ≈ [-0.00752691, 0.874019, 0.485833]

    # Check vertices of a cell
    @test geom[1][17].points[1] ≈ [12.8589, 0.490134, -1.38012]
    @test geom[1][17].points[2] ≈ [12.8557, 0.238678, -1.47264]
    @test geom[1][17].points[3] ≈ [12.6587, 0.378501, -1.42989]

    # Check a few vertices
    @test geom[2].position[1] ≈ [15.4337, 1.55734, -0.360698]
    @test geom[2].position[3] ≈ [15.7579, 1.81622, -0.347975]
    @test geom[2].position[end-2] ≈ [19.4921, 12.9635, 2.88386f-19]
    @test geom[2].position[end] ≈ [19.6233, 12.9635, -1.01573f-17]

    # Check a few normals
    @test geom[2].normals[1] ≈ [0.0214371, 0.0222755, -0.999522]
    @test geom[2].normals[end] ≈ [-0.0, 1.0, 0.0]

    # Check vertices of a cell
    @test geom[2][17].points[1] ≈ [18.2998, 1.24046, -0.186022]
    @test geom[2][17].points[2] ≈ [18.516, 1.58054, -0.166472]
    @test geom[2][17].points[3] ≈ [18.5552, 1.24274, -0.162491]
end
