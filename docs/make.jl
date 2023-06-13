using Documenter, VSPGeom

makedocs(
         modules = [VSPGeom],
         format = Documenter.HTML(sidebar_sitename=false),
         pages = [
                  "Intro" => "index.md",
                  "Quick Start" => "tutorial.md",
                  "Guided Examples" => "howto.md",
                  "API Reference" => "reference.md"
                 ],
         repo="https://github.com/byuflowlab/VSPGeom.jl",
         sitename="VSPGeom.jl",
         authors="Cibin Joseph <cibinjoseph92@gmail.com>")

deploydocs(
    repo = "github.com/byuflowlab/VSPGeom.jl.git",
)
