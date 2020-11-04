using SimplePNGs
using Documenter

makedocs(;
    modules=[SimplePNGs],
    authors="Andrey Oskin",
    repo="https://github.com/Arkoniak/SimplePNGs.jl/blob/{commit}{path}#L{line}",
    sitename="SimplePNGs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Arkoniak.github.io/SimplePNGs.jl",
        siteurl="https://github.com/Arkoniak/SimplePNGs.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Arkoniak/SimplePNGs.jl",
)
