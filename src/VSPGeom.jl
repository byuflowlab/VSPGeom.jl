#=
OpenVSP Degenerate Geometry import tool

# AUTHORSHIP
* Created by    : Cibin Joseph
* Email         : cibinjoseph92@gmail.com
* Date          : Jun 2023
* License       : MIT License
=#
module VSPGeom
export VSPComponent, readDegenGeom, degenGeomSize
export TriMesh, readSTL, getVertices

using CSV, DataFrames

"""
    VSPComponent()

Parameters defining the VSPComponent object.

**Arguments**
- `type::String`: Type
- `name::String`: Name
- `SurfNdx::Int`: Surface index
- `GeomID::String`: Geometry ID
- `MainSurfNdx::Int`: Main surface index
- `SymCopyNdx::Int`: Symmetry copy index
- `surface_node::DataFrame`: Surface node DegenGeom
- `surface_face::DataFrame`: Surface face DegenGeom
- `plate::DataFrame`: Plate DegenGeom
- `stick_node::DataFrame`: Stick node DegenGeom
- `stick_face::DataFrame`: Stick face DegenGeom
- `point::DataFrame`: Point DegenGeom
"""
struct VSPComponent
    name::String
    type::String
    SurfNdx::Int
    GeomID::String
    MainSurfNdx::Int
    SymCopyNdx::Int
    surface_node::DataFrame
    surface_face::DataFrame
    plate::DataFrame
    stick_node::DataFrame
    stick_face::DataFrame
    point::DataFrame
end

struct TriMesh
    name::String
    ncells::Int
    normals::Vector{Vector{Float64}}
    points::Vector{Vector{Float64}}
    cells::Vector{Vector{Int}}
end

# Convenience constructors
VSPComponent(name; type="", SurfNdx=0, GeomID="", MainSurfNdx=0, SymCopyNdx=0,
             surface_node=DataFrame(), surface_face=DataFrame(), plate=DataFrame(), 
             stick_node=DataFrame(), stick_face=DataFrame(), point=DataFrame()) =
VSPComponent(name, type, SurfNdx, GeomID, MainSurfNdx, SymCopyNdx,
             surface_node, surface_face, plate, stick_node, stick_face, point)

TriMesh(name, ncells, normals; points=[], cells=[]) =
TriMesh(name, ncells, normals, points, cells)

function _addParams!(comp::VSPComponent, words)
    comp.type = String(words[1])
    comp.SurfNdx = parse(Int, words[3])
    comp.GeomID = String(words[4])
    comp.MainSurfNdx = parse(Int, words[5])
    comp.SymCopyNdx = parse(Int, words[6])
end

function _getCSV(lines, istart::Int, nx::Int, ny::Int)
    iend = istart + nx*ny
    data = join(lines[istart+1:iend], "\n")
    header = String.(split(lines[istart][3:end], ","))

    csvData = CSV.read(IOBuffer(data), DataFrame; header=header, silencewarnings=true)
    metadata!(csvData, "nx", nx)
    metadata!(csvData, "ny", ny)
    return csvData
end

function _isinside(p, points, tol)
    retVal = false
    for pt in points
        if isapprox(p, pt; atol=tol)
            retVal = true
            break
        end
    end
    return retVal
end

function _getSTLdata(lines)
    name = ""
    vertices = []
    normals = []

    # Read each line of the file
    for line in lines
        # Trim leading and trailing whitespaces and split to words
        words = split(strip(line))

        if isempty(words)
            continue  # Skip empty lines

        elseif words[1] == "vertex"
            # Parse vertex coordinates
            x = parse(Float64, words[2])
            y = parse(Float64, words[3])
            z = parse(Float64, words[4])

            push!(vertices, [x, y, z])

        elseif words[1] == "facet"
            # Parse normal coordinates
            x = parse(Float64, words[3])
            y = parse(Float64, words[4])
            z = parse(Float64, words[5])

            push!(normals, [x, y, z])

        elseif words[1] == "solid"
            # Parse name of solid if present
            if length(words) > 1
                name = String(words[2])
            end
        end
    end
    return name, vertices, normals
end

function _getIndx(p, points; tol=eps(Float64))
    idx = 0
    n = length(points)
    for i in 1:n
        if isapprox(p, points[i], atol=tol)
            idx = i
            break
        end
    end
    # Return 0-indexed index
    return idx-1
end

function _dataToMesh(name::String, vertices, normals; tol::Float64=eps(Float64))
    ncells = length(normals)
    mesh = TriMesh(name, ncells, normals)
    # Get list of unique points
    for p in vertices
        if !_isinside(p, mesh.points, tol)
            push!(mesh.points, p)
        end
    end
    # Construct cell connectivity
    idx = zeros(Int, 3)
    for j in 3:3:ncells*3
        idx[1] = _getIndx(vertices[j-2], mesh.points; tol=tol)
        idx[2] = _getIndx(vertices[j-1], mesh.points; tol=tol)
        idx[3] = _getIndx(vertices[j  ], mesh.points; tol=tol)
        push!(mesh.cells, deepcopy(idx))
    end
    return mesh
end

"""
    degenGeomSize(degenGeom::DataFrame)

Get size of the 2d mesh data structure that describes the degenerate geometry. This is different from the DataFrame size obtained using `size(degenGeom)` which is the number of variables and total number of points in the DataFrame.

**Arguments**
- `degenGeom::DataFrame`: One of the degenGeom inside the [`VSPComponent`](@ref) object

**Returns**
- `nx::Int`: Usually represents the number of cross-sections, referred to as Xsecs in OpenVSP
- `ny::Int`: Usually represents the number of points in each cross-section in OpenVSP
"""
function degenGeomSize(degenGeom::DataFrame)
    nx = metadata(degenGeom, "nx")
    ny = metadata(degenGeom, "ny")
    return nx, ny
end

"""
    readDegenGeom(filename::String; verbose::Bool=false)

Read DegenGeom CSV file written out by OpenVSP to obtain geometry and components.

**Arguments**
- `filename::String`: DegenGeom filename
- `verbose::Bool`: Set to `true` to print status messages during file read operation

**Returns**
- `comp`: Vector of [`VSPComponent`](@ref) objects
"""
function readDegenGeom(filename::String; verbose::Bool=false)
    lines = readlines(filename)
    nVSPComponent = parse(Int, lines[4])
    comp = Array{VSPComponent}(undef, nVSPComponent)

    ic = 0
    # Parse file and extract each component and degenGeom
    for (i, line) in enumerate(lines)
        if occursin("# DegenGeom Type, Name", line)
            # start of a component
            ic += 1
            if verbose; println("Found component $ic ..."); end
            words = split(lines[i+1], ",")
            comp[ic] = VSPComponent(String(words[2]))
            _addParams!(comp[ic], words)
        end

        if occursin("SURFACE_NODE", line)
            if verbose; println("Found surface_node $ic ..."); end
            strList = split(line, ",")
            nx, np = parse.(Int, strList[2:3])
            istart = i+1
            comp[ic].surface_node = _getCSV(lines, istart, nx, np)
        end

        if occursin("SURFACE_FACE", line)
            if verbose; println("Found surface_face $ic ..."); end
            strList = split(line, ",")
            nx, np = parse.(Int, strList[2:3])
            istart = i+1
            comp[ic].surface_face = _getCSV(lines, istart, nx, np)
        end

        if occursin("PLATE", line)
            if verbose; println("Found plate $ic ..."); end
            strList = split(line, ",")
            nx, np = parse.(Int, strList[2:3])
            istart = i+2+nx
            comp[ic].plate = _getCSV(lines, istart, nx, np)
        end

        if occursin("STICK_NODE", line)
            if verbose; println("Found stick_node $ic ..."); end
            strList = split(line, ",")
            nx, np = (parse.(Int, strList[2]), 1)
            istart = i+1
            comp[ic].stick_node = _getCSV(lines, istart, nx, np)
        end

        if occursin("STICK_FACE", line)
            if verbose; println("Found stick_face $ic ..."); end
            strList = split(line, ",")
            nx = parse.(Int, strList[2])
            np = 1
            istart = i+1
            comp[ic].stick_face = _getCSV(lines, istart, nx, np)
        end

        if occursin("POINT", line)
            if verbose; println("Found point $ic ..."); end
            strList = split(line, ",")
            nx, np = (1, 1)
            istart = i+1
            comp[ic].point = _getCSV(lines, istart, nx, np)
        end
    end
    return comp
end

"""
    readSTL(filename::String; verbose::Bool=false, tol::Float64=eps(Float64))

Read STL file to obtain geometry. This function can also handle the non-standard Tagged Multi Solid file type that OpenVSP writes out. Connectivity information for the mesh is not available at present.

**Arguments**
- `filename::String`: STL filename
- `verbose::Bool`: Set to `true` to print status messages during file read operation
- `tol::Float64`: Set absolute tolerance when comparing points to obtain connectivity

**Returns**
- `geom`: Vector of `GeometryBasics.Mesh` objects from the ['Geometrybasics.jl'](https://juliageometry.github.io/GeometryBasics.jl/stable/) package
"""
function readSTL(filename::String; verbose::Bool=false, tol::Float64=eps(Float64))
    geom = []
    lines = readlines(filename)
    solidEnd = Vector{Int}(undef, 0)

    # Search for instances of "endsolid" inside the file to obtain geometry
    ig = 0
    istart = 1
    for (i, line) in enumerate(lines)
        if occursin("endsolid", line)
            name, vertices, normals = _getSTLdata(lines[istart:i])
            mesh = _dataToMesh(name, vertices, normals; tol=tol)
            push!(geom, mesh)

            ig += 1
            if verbose; println("Found geometry $ig"); end

            istart = i + 1
        end
    end
    return geom
end

"""
    getVertices(mesh::TriMesh, icell::Int)

Obtain vertices of a cell from a mesh

**Arguments**
- `mesh::TriMesh`: [`TriMesh`](@ref) object
- `icell::Int`: Index of cell

**Returns**
- `vtxs`: Vector of 3 vertices of the icell cell
"""
function getVertices(mesh::TriMesh, icell::Int)
    vtxs = [Vector{Float64}(undef, 3) for _ in 1:3]
    idxs = mesh.cells[icell]
    for i in 1:3
        vtxs[i] = mesh.points[idxs[i]+1]
    end
    return vtxs
end
end
