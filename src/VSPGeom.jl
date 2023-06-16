#=
OpenVSP Degenerate Geometry import tool

# AUTHORSHIP
* Created by    : Cibin Joseph
* Email         : cibinjoseph92@gmail.com
* Date          : Jun 2023
* License       : MIT License
=#
module VSPGeom
export VSPComponent, readDegenGeom, degenGeomSize, readSTL

using CSV, DataFrames
using FileIO: load, File, Stream, DataFormat

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
mutable struct VSPComponent
    type::String
    name::String
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

# Convenience constructor
VSPComponent(;type="", name="", SurfNdx=0, GeomID="", MainSurfNdx=0, SymCopyNdx=0,
             surface_node=DataFrame(), surface_face=DataFrame(), plate=DataFrame(), 
             stick_node=DataFrame(), stick_face=DataFrame(), point=DataFrame()) =
VSPComponent(type, name, SurfNdx, GeomID, MainSurfNdx, SymCopyNdx,
             surface_node, surface_face, plate, stick_node, stick_face, point)

function _addParams!(comp::VSPComponent, line::String)
    strList = split(line, ",")
    comp.type = strList[1]
    comp.name = strList[2]
    comp.SurfNdx = parse(Int, strList[3])
    comp.GeomID = strList[4]
    comp.MainSurfNdx = parse(Int, strList[5])
    comp.SymCopyNdx = parse(Int, strList[6])
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
            comp[ic] = VSPComponent()
            _addParams!(comp[ic], lines[i+1])
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
    readSTL(filename::String; verbose::Bool=false, binaryFormat::Bool=false)

Read STL file to obtain geometry. This function can also handle the non-standard Tagged Multi Solid file type that OpenVSP writes out.

**Arguments**
- `filename::String`: STL filename
- `verbose::Bool`: Set to `true` to print status messages during file read operation
- `binaryFormat::Bool`: Set to `true` if the STL file is of binary format

**Returns**
- `geom`: Vector of `GeometryBasics.Mesh` objects from the ['Geometrybasics.jl'](https://juliageometry.github.io/GeometryBasics.jl/stable/) package
"""
function readSTL(filename::String; verbose::Bool=false, binaryFormat::Bool=false)
    geom = []
    if binaryFormat
        mesh = load(File{DataFormat{:STL_BINARY}}(filename))
        if verbose; println("Found geometry 1"); end
        push!(geom, mesh)
    else
        lines = readlines(filename)
        solidEnd = Vector{Int}(undef, 0)

        # Search for instances of "endsolid" inside the file to obtain geometry
        ig = 0
        istart = 1
        for (i, line) in enumerate(lines)
            if occursin("endsolid", line)
                data = join(lines[istart:i], "\n")
                mesh = load(Stream{DataFormat{:STL_ASCII}}(IOBuffer(data)))
                push!(geom, mesh)

                ig += 1
                if verbose; println("Found geometry $ig"); end

                istart = i + 1
            end
        end
        return geom
    end
end
end
