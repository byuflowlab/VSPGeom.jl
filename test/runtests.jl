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

@testset "1-component STL file      " begin
    geom = readSTL("cube.stl")

    @test length(geom) == 1

    # Check a few vertices
    @test geom[1].points[1] ≈ [0.0, 0.0, 0.0]
    @test geom[1].points[3] ≈ [1.0, 0.0, 0.0]
    @test geom[1].points[end-2] ≈ [0.0, 0.0, 1.0]
    @test geom[1].points[end] ≈ [1.0, 0.0, 1.0]

    # Check a few normals
    @test geom[1].normals[1] ≈ [0.0, 0.0, -1.0]
    @test geom[1].normals[end] ≈ [0.0, 0.0, 1.0]

    # Check vertices of a cell
    vtxs = getVertices(geom[1], 5)
    @test vtxs[1] ≈ [0.0, 1.0, 0.0]
    @test vtxs[2] ≈ [1.0, 1.0, 1.0]
    @test vtxs[3] ≈ [1.0, 1.0, 0.0]

    # Check indexing
    @test geom[1].cells[1] == [1, 2, 3]
    @test geom[1].cells[end] == [6, 7, 5]

    setZeroBased!(geom[1]; value=true)
    @test geom[1].cells[1] == [0, 1, 2]
    @test geom[1].cells[end] == [5, 6, 4]
end

@testset "1-component STL file 0-idx" begin
    geom = readSTL("cube.stl"; zeroBased=true)

    @test length(geom) == 1

    # Check a few vertices
    @test geom[1].points[1] ≈ [0.0, 0.0, 0.0]
    @test geom[1].points[3] ≈ [1.0, 0.0, 0.0]
    @test geom[1].points[end-2] ≈ [0.0, 0.0, 1.0]
    @test geom[1].points[end] ≈ [1.0, 0.0, 1.0]

    # Check a few normals
    @test geom[1].normals[1] ≈ [0.0, 0.0, -1.0]
    @test geom[1].normals[end] ≈ [0.0, 0.0, 1.0]

    # Check vertices of a cell
    vtxs = getVertices(geom[1], 5)
    @test vtxs[1] ≈ [0.0, 1.0, 0.0]
    @test vtxs[2] ≈ [1.0, 1.0, 1.0]
    @test vtxs[3] ≈ [1.0, 1.0, 0.0]

    # Check indexing
    @test geom[1].cells[1] == [0, 1, 2]
    @test geom[1].cells[end] == [5, 6, 4]

    setZeroBased!(geom[1]; value=false)
    @test geom[1].cells[1] == [1, 2, 3]
    @test geom[1].cells[end] == [6, 7, 5]
end

@testset "2-component STL file      " begin
    geom = readSTL("geom2.stl")

    @test length(geom) == 2

    # Check a few vertices
    @test geom[1].points[1] ≈ [11.763577437, 1.2278723836, -0.28219811473]
    @test geom[1].points[3] ≈ [11.46871474, 1.217597919, -0.34049756511]
    @test geom[1].points[end-2] ≈ [25.433571579, 1.1978023849, 0.25447996152]
    @test geom[1].points[end] ≈ [21.317977058, 0.9888187956, 0.91728058288]

    # Check a few normals
    @test geom[1].normals[1] ≈ [0.01347703454, 0.97086104543, -0.2392638711]
    @test geom[1].normals[end] ≈ [-0.007526908253, 0.874019297, 0.48583290762]

    # Check vertices of a cell
    vtxs = getVertices(geom[1], 17)
    @test vtxs[1] ≈ [12.858892659, 0.49013393681, -1.3801196343]
    @test vtxs[2] ≈ [12.855663681, 0.23867768298, -1.472636823]
    @test vtxs[3] ≈ [12.658680668, 0.37850085853, -1.4298881016]

    # Check a few vertices
    @test geom[2].points[1] ≈ [15.43371087, 1.5573433693, -0.36069807445]
    @test geom[2].points[3] ≈ [15.757918365, 1.8162172852, -0.34797536991]
    @test geom[2].points[end-2] ≈ [19.492067438, 12.963541984, 2.8838561131e-19]
    @test geom[2].points[end] ≈ [20.043780348, 12.963541984, 4.0137370772e-18]

    # Check a few normals
    @test geom[2].normals[1] ≈ [0.021437088725, 0.022275548214, -0.99952201135]
    @test geom[2].normals[end] ≈ [-0.0, 1.0, 0.0]

    # Check vertices of a cell
    vtxs = getVertices(geom[2], 17)
    @test vtxs[1] ≈ [18.299825904, 1.2404634609, -0.1860224922]
    @test vtxs[2] ≈ [18.515960196, 1.5805374641, -0.16647212648]
    @test vtxs[3] ≈ [18.55517402, 1.2427364009, -0.16249121431]
end
