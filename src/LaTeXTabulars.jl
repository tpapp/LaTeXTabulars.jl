module LaTeXTabulars

using ArgCheck
using DocStringExtensions
using Parameters

export Rule, MultiColumn, latex_tabular


# cells

"""
    $SIGNATURES

Print a the contents of `cell` to `io` as LaTeX.

!!! NOTE

    Methods are defined for some specific types, but if you want full control
    (eg rounding), use a string or `LaTeXString`.
"""
function latex_cell(io::IO, cell::T) where T
    info("Define a method for writing $T objects to LaTeX.")
    throw(MethodError(latex_cell, Tuple{IO, T}))
end

latex_cell(io::IO, x::Real) = print(io, string(x))

latex_cell(io::IO, s::AbstractString) = print(io, s)

"""
    MultiColumn(n, pos, cell)

For `\\multicolumn{n}{pos}{cell}`. Use the symbols `:l`, `:c`, `:r` for `pos`.
"""
struct MultiColumn
    n::Int
    pos::Symbol
    cell
end

function latex_cell(io::IO, mc::MultiColumn)
    @unpack n, pos, cell = mc
    @argcheck pos ∈ (:l, :c, :r) "$pos is not a recognized position. Use :l, :c, :r."
    print(io, "\\multicolumn{$(n)}{$(pos)}{")
    latex_cell(io, mc.cell)
    print(io, "}")
end


# lines and line-like objects

struct Rule{T} end

"""
    $SIGNATURES

Horizontal rule. The `kind` of the rule is specified by a symbol, which will
generally be printed as `\\KINDrule`, eg `Rule(:top)` prints `\\toprule`.
"""
Rule(kind::Symbol = :h) = Rule{kind}()

latex_line(io::IO, ::Rule{:top}) = println(io, "\\toprule")

latex_line(io::IO, ::Rule{:mid}) = println(io, "\\midrule")

latex_line(io::IO, ::Rule{:bottom}) = println(io, "\\bottomrule")

latex_line(io::IO, ::Rule{:h}) = println(io, "\\hrule")

function latex_line(io::IO, cells)
    for (column, cell) in enumerate(cells)
        column == 1 || print(io, " & ")
        latex_cell(io, cell)
    end
    println(io, " \\\\")
end


# tabular

"""
    $SIGNATURES

Print `lines` to `io` as a LaTeX `tabular` environment.

`cols` specifies the columns, and follows the syntax of LaTeX.

Each element in `lines` is an iterable of cells (not checked for length
consistency), or a separator like [`Rule`](@ref).

See [`latex_cell`](@ref) for the kinds of cell supported (particularly
[`MultiColumn`](@ref), but for full formatting control, use an `String` or
`LaTeXString` for cells.
"""
function latex_tabular(io::IO, cols::AbstractString, lines)
    println(io, "\\begin{tabular}{$cols}")
    for line in lines
        latex_line(io, line)
    end
    println(io, "\\end{tabular}")
end

function latex_tabular(::Type{String}, args...)
    io = IOBuffer()
    latex_tabular(io, args...)
    String(take!(io))
end

"""
    $SIGNATURES

Write a `tabular` LaTeX environment to `filename`, which is **overwritten** if
it already exists. Other arguments are passed to [`latex_tabular`](@ref).
"""
function latex_tabular(filename::AbstractString, args...)
    open(filename, "w") do io
        latex_tabular(io, args...)
    end
end

end # module
