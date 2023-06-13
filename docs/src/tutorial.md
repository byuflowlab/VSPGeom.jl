# Quick Start

This starter tutorial walks through the mechanics of importing geometry using VSPGeom.

## DegenGeom
OpenVSP has provisions to create multi-fidelity representations of geometry called Degenerate geometry or *DegenGeom*. This is done by creating a OpenVSP geometry and clicking *Analysis* > *DegenGeom* to write out a DegenGeom file. A DegenGeom file is a collection of comma-separated tables, each representing a multi-fidelity representation of the geometry. There are primarily four types of degenerate geometry:
1. Surface
2. Plate
3. Stick
4. Point
Plate representations are typically used for aerodynamic solvers like a Vortex lattice solver; while stick representations are common in beam element-based structural solvers.

## Tutorial
### OpenVSP geometry 
We start by creating a geometry in OpenVSP. Let's use the default wing geometry and write out a CSV DegenGeom file using the tab *Analysis* > *DegenGeom*.

### Import to Julia
We shall now use VSPGeom to import the DegenGeom file into Julia. We make use of the `readDegenGeom` function to read the file. We would also like to know the output that we obtained from `readDegenGeom`.
```@example
using VSPGeom

comp = readDegenGeom("wing.csv")

println(typeof(comp))
println(size(comp))
```

The various geometry components in the DegenGeom file will now be available to us in the variable `comp` which appears to be a Vector of `VSPComponent` objects. This specific vector has two elements in it. Before we start using this object, let's inspect it using the `dump` function provided by Julia.
```@repl
using VSPGeom

dump(VSPComponent)
```
Besides several variables like `type`, `name`, `GeomID` etc. that describe the geometry, we notice a collection of `DataFrame` objects. These are the degenGeom representations of the geometry in the form of `DataFrame` objects. Let's inspect the `PLATE` type of representation for the first component using the `describe` function provided by the `DataFrames` package.
```@example
using VSPGeom, DataFrames

comp = readDegenGeom("wing.csv")

describe(comp[1].plate)
```

The `PLATE` degenGeom representation for component 1 has the variables `x`, `y`, `z`, `zCamber` and so on inside it. These correspond to the right half of the OpenVSP Wing geometry. Component 2 represents the left half of the wing that lies in the negative Y-plane indicated by the negative values for `y` in its dataframe or table. We can also display a summary of only the `y` values for each of the components using the `cols` option.
```@example
using VSPGeom, DataFrames

comp = readDegenGeom("wing.csv")

println(describe(comp[1].plate, cols="y"))
println(describe(comp[2].plate, cols="y"))
```

### Accessing DegenGeom variables
Variables in the DegenGeom may now be accessed like fields in a struct as shown below. Let's try creating a scatter plot of points on the cameber surface for the left and right halves of the wing geometry.
```@example
using VSPGeom, DataFrames

comp = readDegenGeom("wing.csv")

xR = comp[1].plate.x + comp[1].plate.zCamber .* comp[1].plate.nCamberx;
yR = comp[1].plate.y + comp[1].plate.zCamber .* comp[1].plate.nCambery;
zR = comp[1].plate.z + comp[1].plate.zCamber .* comp[1].plate.nCamberz;

xL = comp[2].plate.x + comp[2].plate.zCamber .* comp[2].plate.nCamberx;
yL = comp[2].plate.y + comp[2].plate.zCamber .* comp[2].plate.nCambery;
zL = comp[2].plate.z + comp[2].plate.zCamber .* comp[2].plate.nCamberz;

using Plots
scatter(xL, yL, zL, zlims=(-4, 4), ma=0.5, label="Left wing")
scatter!(xR, yR, zR, zlims=(-4, 4), ma=0.5, label="Right wing")
```
