#=
OpenVSP Degenerate Geometry import tool

# AUTHORSHIP
* Created by    : Cibin Joseph
* Email         : cibinjoseph92@gmail.com
* Date          : Jun 2023
* License       : MIT License
=#
module VSPGeom
export VSPComponent, readDegenGeom

using CSV, DataFrames

"""
    `VSPComponent()`

Parameters defining the VSPComponent struct.

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

function _getCSV(lines)
    data = join(lines[2:end], "\n")
    header = String.(split(lines[1][3:end], ","))

    csvData = CSV.read(IOBuffer(data), DataFrame; header=header, silencewarnings=true)
    return csvData
end

"""
    `readDegenGeom(filename::String; verbose::Bool=false )`

Read DegenGeom CSV file written out by OpenVSP to obtain geometry and components.
verbose=true prints out status messages during the file read operation.
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
            comp[ic].surface_node = _getCSV(lines[istart:istart+nx*np])
        end

        if occursin("SURFACE_FACE", line)
            if verbose; println("Found surface_face $ic ..."); end
            strList = split(line, ",")
            nx, np = parse.(Int, strList[2:3])
            istart = i+1
            comp[ic].surface_face = _getCSV(lines[istart:istart+nx*np])
        end

        if occursin("PLATE", line)
            if verbose; println("Found plate $ic ..."); end
            strList = split(line, ",")
            nx, np = parse.(Int, strList[2:3])
            istart = i+2+nx
            comp[ic].plate = _getCSV(lines[istart:istart+nx*np])
        end

        if occursin("STICK_NODE", line)
            if verbose; println("Found stick_node $ic ..."); end
            strList = split(line, ",")
            nx = parse.(Int, strList[2])
            istart = i+1
            comp[ic].stick_node = _getCSV(lines[istart:istart+nx])
        end

        if occursin("STICK_FACE", line)
            if verbose; println("Found stick_face $ic ..."); end
            strList = split(line, ",")
            nx = parse.(Int, strList[2])
            istart = i+1
            comp[ic].stick_face = _getCSV(lines[istart:istart+nx])
        end

        if occursin("POINT", line)
            if verbose; println("Found point $ic ..."); end
            strList = split(line, ",")
            istart = i+1
            comp[ic].point = _getCSV(lines[istart:istart+1])
        end
    end
    return comp
end
end
