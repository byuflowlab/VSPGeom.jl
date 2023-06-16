var documenterSearchIndex = {"docs":
[{"location":"howto/#Guided-Examples","page":"Guided Examples","title":"Guided Examples","text":"","category":"section"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"This section describes examples of how to use VSPGeom to import different types of geometry. It assumes familiarity with basic usage.","category":"page"},{"location":"howto/#DegenGeom-Files","page":"Guided Examples","title":"DegenGeom Files","text":"","category":"section"},{"location":"howto/#OpenVSP-geometry","page":"Guided Examples","title":"OpenVSP geometry","text":"","category":"section"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"We start by creating a geometry in OpenVSP. Let's use the default wing geometry and write out a CSV DegenGeom file using the tab Analysis > DegenGeom. (Image: OpenVSPwing)","category":"page"},{"location":"howto/#Import-to-Julia","page":"Guided Examples","title":"Import to Julia","text":"","category":"section"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"We shall now use VSPGeom to import the DegenGeom file into Julia. We make use of the readDegenGeom function to read the file. We would also like to know the output that we obtained from readDegenGeom.","category":"page"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"using VSPGeom\n\ncomp = readDegenGeom(\"wing.csv\")\n\nprintln(typeof(comp))\nprintln(size(comp))","category":"page"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"The various geometry components in the DegenGeom file will now be available to us in the variable comp which appears to be a Vector of VSPComponent objects. This specific vector has two elements in it. Before we start using this object, let's inspect it using the dump function provided by Julia.","category":"page"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"dump(VSPComponent)","category":"page"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"Besides several variables like type, name, GeomID etc. that describe the geometry, we notice a collection of DataFrame objects. These are the degenGeom representations of the geometry in the form of DataFrame objects. Let's inspect the PLATE type of representation for the first component using the describe function provided by the DataFrames package.","category":"page"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"VSPGeom.DataFrames.describe(comp[1].plate)","category":"page"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"The PLATE degenGeom representation for component 1 has the variables x, y, z, zCamber and so on inside it. These correspond to the right half of the OpenVSP Wing geometry. Component 2 represents the left half of the wing that lies in the negative Y-plane indicated by the negative values for y in its dataframe or table. We can also display a summary of only the y values for each of the components using the cols option.","category":"page"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"println(VSPGeom.DataFrames.describe(comp[1].plate, cols=\"y\"))\nprintln(VSPGeom.DataFrames.describe(comp[2].plate, cols=\"y\"))","category":"page"},{"location":"howto/#DegenGeom-variables:-Accessing-and-restructuring-as-mesh","page":"Guided Examples","title":"DegenGeom variables: Accessing and restructuring as mesh","text":"","category":"section"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"Variables in the DegenGeom may now be accessed like fields in a struct as shown below. Let's create  a surface plot of the camber surface for the left and right halves of the wing geometry. We shall use the function degenGeomSize to obtain the mesh size and restructure the coordinate variables into a surface mesh.","category":"page"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"x1 = comp[1].plate.x + comp[1].plate.zCamber .* comp[1].plate.nCamberx;\ny1 = comp[1].plate.y + comp[1].plate.zCamber .* comp[1].plate.nCambery;\nz1 = comp[1].plate.z + comp[1].plate.zCamber .* comp[1].plate.nCamberz;\n\nx2 = comp[2].plate.x + comp[2].plate.zCamber .* comp[2].plate.nCamberx;\ny2 = comp[2].plate.y + comp[2].plate.zCamber .* comp[2].plate.nCambery;\nz2 = comp[2].plate.z + comp[2].plate.zCamber .* comp[2].plate.nCamberz;\n\n# Reshape right wing to a mesh\nnx, ny = degenGeomSize(comp[1].plate)\nxr = reshape(x1, (nx, ny))\nyr = reshape(y1, (nx, ny))\nzr = reshape(z1, (nx, ny))\n\n# Reshape left wing to a mesh\nnx, ny = degenGeomSize(comp[2].plate)\nxl = reshape(x2, (nx, ny))\nyl = reshape(y2, (nx, ny))\nzl = reshape(z2, (nx, ny))\n\nusing Plots\nsurface(xl, yl, zl, zlims=(-4, 4),\n        color=:blue, label=\"Left wing\", colorbar=false)\nsurface!(xr, yr, zr,\n        color=:red, label=\"Right wing\", colorbar=false,\n        camera=(20, 30), aspect_ratio=1, proj_type=:persp)","category":"page"},{"location":"howto/#STL-Files","page":"Guided Examples","title":"STL Files","text":"","category":"section"},{"location":"howto/#OpenVSP-geometry-2","page":"Guided Examples","title":"OpenVSP geometry","text":"","category":"section"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"In addition to the DegenGeom file format, OpenVSP has the capability to generate unstructured triangular element meshes of geometry and write out ASCII STL mesh files. These files may contain a single solid or multiple named solids. Opting for the \"Tagged Multi Solid File (non standard)\" option during mesh export enables the ability to manipulate each component geometry individually. (Image: OpenVSPSTLExport)","category":"page"},{"location":"howto/#Import-to-Julia-2","page":"Guided Examples","title":"Import to Julia","text":"","category":"section"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"We shall use the readSTL function in VSPGeom to import the geometry from the STL file.","category":"page"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"using VSPGeom\n\ngeom = readSTL(\"aircraft.stl\")\n\nprintln(typeof(geom))\nprintln(size(geom))","category":"page"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"Similar to the readDegenGeom function, readSTL also returns an array of mesh geometry objects.","category":"page"},{"location":"howto/#Accessing-STL-mesh-variabels","page":"Guided Examples","title":"Accessing STL mesh variabels","text":"","category":"section"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"The vertices, normals and cells in this mesh object may be accessed as shown below.","category":"page"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"nVertices = size(geom[1].position)\nprintln(\"No. of vertices = $nVertices\")\n\nnNormals = size(geom[1].normals)\nprintln(\"No. of normals = $nNormals\")\n\nn = 5\nprintln(\"3 vertices of cell $n:\")\nprintln(geom[1][n].points[1])\nprintln(geom[1][n].points[2])\nprintln(geom[1][n].points[3])","category":"page"},{"location":"howto/","page":"Guided Examples","title":"Guided Examples","text":"note: STL Connectivity\nThe mesh output from readSTL does not have connectivity information at the time being.","category":"page"},{"location":"reference/#Reference","page":"API Reference","title":"Reference","text":"","category":"section"},{"location":"reference/","page":"API Reference","title":"API Reference","text":"This section describes the API in detail.","category":"page"},{"location":"reference/#Main-Struct","page":"API Reference","title":"Main Struct","text":"","category":"section"},{"location":"reference/","page":"API Reference","title":"API Reference","text":"VSPComponent","category":"page"},{"location":"reference/#VSPGeom.VSPComponent","page":"API Reference","title":"VSPGeom.VSPComponent","text":"VSPComponent()\n\nParameters defining the VSPComponent object.\n\nArguments\n\ntype::String: Type\nname::String: Name\nSurfNdx::Int: Surface index\nGeomID::String: Geometry ID\nMainSurfNdx::Int: Main surface index\nSymCopyNdx::Int: Symmetry copy index\nsurface_node::DataFrame: Surface node DegenGeom\nsurface_face::DataFrame: Surface face DegenGeom\nplate::DataFrame: Plate DegenGeom\nstick_node::DataFrame: Stick node DegenGeom\nstick_face::DataFrame: Stick face DegenGeom\npoint::DataFrame: Point DegenGeom\n\n\n\n\n\n","category":"type"},{"location":"reference/","page":"API Reference","title":"API Reference","text":"readDegenGeom","category":"page"},{"location":"reference/#VSPGeom.readDegenGeom","page":"API Reference","title":"VSPGeom.readDegenGeom","text":"readDegenGeom(filename::String; verbose::Bool=false)\n\nRead DegenGeom CSV file written out by OpenVSP to obtain geometry and components.\n\nArguments\n\nfilename::String: DegenGeom filename\nverbose::Bool: Set to true to print status messages during file read operation\n\nReturns\n\ncomp: Vector of VSPComponent objects\n\n\n\n\n\n","category":"function"},{"location":"reference/","page":"API Reference","title":"API Reference","text":"readSTL","category":"page"},{"location":"reference/#VSPGeom.readSTL","page":"API Reference","title":"VSPGeom.readSTL","text":"readSTL(filename::String; verbose::Bool=false, binaryFormat::Bool=false)\n\nRead STL file to obtain geometry. This function can also handle the non-standard Tagged Multi Solid file type that OpenVSP writes out. Connectivity information for the mesh is not available at present.\n\nArguments\n\nfilename::String: STL filename\nverbose::Bool: Set to true to print status messages during file read operation\nbinaryFormat::Bool: Set to true if the STL file is of binary format\n\nReturns\n\ngeom: Vector of GeometryBasics.Mesh objects from the 'Geometrybasics.jl' package\n\n\n\n\n\n","category":"function"},{"location":"reference/","page":"API Reference","title":"API Reference","text":"degenGeomSize","category":"page"},{"location":"reference/#VSPGeom.degenGeomSize","page":"API Reference","title":"VSPGeom.degenGeomSize","text":"degenGeomSize(degenGeom::DataFrame)\n\nGet size of the 2d mesh data structure that describes the degenerate geometry. This is different from the DataFrame size obtained using size(degenGeom) which is the number of variables and total number of points in the DataFrame.\n\nArguments\n\ndegenGeom::DataFrame: One of the degenGeom inside the VSPComponent object\n\nReturns\n\nnx::Int: Usually represents the number of cross-sections, referred to as Xsecs in OpenVSP\nny::Int: Usually represents the number of points in each cross-section in OpenVSP\n\n\n\n\n\n","category":"function"},{"location":"#VSPGeom-Documentation","page":"Intro","title":"VSPGeom Documentation","text":"","category":"section"},{"location":"","page":"Intro","title":"Intro","text":"Summary: A package to import geometry generated using OpenVSP to Julia","category":"page"},{"location":"","page":"Intro","title":"Intro","text":"Author: Cibin Joseph","category":"page"},{"location":"","page":"Intro","title":"Intro","text":"Features:","category":"page"},{"location":"","page":"Intro","title":"Intro","text":"Import Degenerate Geometry","category":"page"},{"location":"","page":"Intro","title":"Intro","text":"Installation:","category":"page"},{"location":"","page":"Intro","title":"Intro","text":"pkg> add https://github.com/byuflowlab/VSPGeom.jl.git","category":"page"},{"location":"","page":"Intro","title":"Intro","text":"Documentation:","category":"page"},{"location":"","page":"Intro","title":"Intro","text":"Start with quick start tutorial to learn basic usage.\nMore advanced or specific queries are addressed in the guided examples.\nFull details of the API are listed in reference.","category":"page"},{"location":"","page":"Intro","title":"Intro","text":"Run Unit Tests:","category":"page"},{"location":"","page":"Intro","title":"Intro","text":"pkg> activate .\npkg> test","category":"page"},{"location":"tutorial/#Quick-Start","page":"Quick Start","title":"Quick Start","text":"","category":"section"},{"location":"tutorial/","page":"Quick Start","title":"Quick Start","text":"This starter tutorial provides a quick overview of important VSPGeom functions that help importing geometry into Julia. A detailed walkthrough of features is available in Guided Examples.","category":"page"},{"location":"tutorial/#DegenGeom","page":"Quick Start","title":"DegenGeom","text":"","category":"section"},{"location":"tutorial/","page":"Quick Start","title":"Quick Start","text":"OpenVSP has provisions to create multi-fidelity representations of geometry called Degenerate geometry or DegenGeom. This is done by creating a OpenVSP geometry and clicking Analysis > DegenGeom to write out a DegenGeom file. A DegenGeom file is a collection of comma-separated tables, each representing a multi-fidelity representation of the geometry. There are primarily four types of degenerate geometry:","category":"page"},{"location":"tutorial/","page":"Quick Start","title":"Quick Start","text":"Surface\nPlate\nStick\nPoint","category":"page"},{"location":"tutorial/","page":"Quick Start","title":"Quick Start","text":"Plate representations are typically used for aerodynamic solvers like a Vortex lattice solver; while stick representations are common in beam element-based structural solvers. (Image: DegenGeom) Image from McDonald, R. A., & Gloudemans, J. R. (2022). Open Vehicle Sketch Pad: An Open Source Parametric Geometry and Analysis Tool for Conceptual Aircraft Design. In AIAA SCITECH 2022 Forum.","category":"page"},{"location":"tutorial/#Tutorial","page":"Quick Start","title":"Tutorial","text":"","category":"section"},{"location":"tutorial/","page":"Quick Start","title":"Quick Start","text":"Use the readDegenGeom function to import geometry into a VSPComponent object from the DegenGeom CSV file. Variables, like coordinates x, y, z, of each degenGeom are available as fields inside the VSPComponent.","category":"page"},{"location":"tutorial/","page":"Quick Start","title":"Quick Start","text":"using VSPGeom\n\ncomp = readDegenGeom(\"wing.csv\")\nx = comp[1].plate.x\ny = comp[1].plate.y\nz = comp[1].plate.z","category":"page"},{"location":"tutorial/","page":"Quick Start","title":"Quick Start","text":"The function degenGeomSize can be used to obtain the mesh size and restructure the coordinate variables into a surface mesh.","category":"page"},{"location":"tutorial/","page":"Quick Start","title":"Quick Start","text":"# Reshape wing to a mesh\nnx, ny = degenGeomSize(comp[1].plate)\nxg = reshape(x, (nx, ny))\nyg = reshape(y, (nx, ny))\nzg = reshape(z, (nx, ny))","category":"page"}]
}