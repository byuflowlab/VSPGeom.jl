# VSPGeom.jl

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://flow.byu.edu/VSPGeom.jl/stable)
![](https://github.com/byuflowlab/VSPGeom.jl/actions/workflows/test.yaml/badge.svg)

**Summary**: A Julia package to import geometry generated using OpenVSP into Julia.

**Features**

- Import geometry from OpenVSP DegenGeom file
- Import geometry from ASCII STL file
- Import geometry from OpenVSP Tagged Multi solid STL file

**Author**: Cibin Joseph

**Installation**:

```julia
pkg> add VSPGeom
```

**Documentation**:

The [documentation](https://flow.byu.edu/VSPGeom.jl/dev) contains
- A quick start tutorial to learn basic usage,
- Guided examples to address specific or more advanced tasks,
- A reference describing the API.

**Run Unit Tests**:

```julia
pkg> activate .
pkg> test
```
