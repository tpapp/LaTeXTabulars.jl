# see documentation at https://juliadocs.github.io/Documenter.jl/stable/

using Documenter, LaTeXTabulars

makedocs(
    modules = [LaTeXTabulars],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Tamás K. Papp",
    sitename = "LaTeXTabulars.jl",
    pages = Any["index.md"],
)

# Some setup is needed for documentation deployment, see “Hosting Documentation” and
# deploydocs() in the Documenter manual for more information.
deploydocs(
    repo = "github.com/tpapp/LaTeXTabulars.jl.git",
    push_preview = true
)
