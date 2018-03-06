module LaTeXTabulars

using ArgCheck
using DocStringExtensions
using Parameters

export Rule, CMidRule, MultiColumn, Tabular, latex_tabular


# cells

"""
    $SIGNATURES

Print a the contents of `cell` to `io` as LaTeX.

!!! NOTE

    Methods are defined for some specific types, but if you want full control
    (eg rounding), use an `<: AbstractString`, eg `String` or `LaTeXString`.
"""
function latex_cell(io::IO, cell::T) where T
    info("Define a `latex_cell` for writing $T objects to LaTeX.")
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
    @argcheck(pos ∈ (:l, :c, :r),
              "$pos is not a recognized position. Use :l, :c, :r.")
    print(io, "\\multicolumn{$(n)}{$(pos)}{")
    latex_cell(io, mc.cell)
    print(io, "}")
end


# non-cell-like objects

struct Rule{T} end

"""
    $SIGNATURES

Horizontal rule. The `kind` of the rule is specified by a symbol, which will
generally be printed as `\\KINDrule`, eg `Rule(:top)` prints `\\toprule`.
"""
Rule(kind::Symbol = :h) = Rule{kind}()

latex_line(io::IO, ::Rule{:top}) = println(io, "\\toprule ")

latex_line(io::IO, ::Rule{:mid}) = println(io, "\\midrule ")

latex_line(io::IO, ::Rule{:bottom}) = println(io, "\\bottomrule ")

latex_line(io::IO, ::Rule{:h}) = println(io, "\\hrule ")

latex_line(io::IO, r::Rule) = error("Don't know how to print $(typeof(r))")

"""
    CMidRule([wd], [trim], left, right)

Will be printed as `\\cmidrule[wd](trim)[left-right]`. When `wd` or `trim` is
`nothing`, it is omitted. Use with the `booktabs` LaTeX package.
"""
struct CMidRule
    wd::Union{Void, AbstractString}
    trim::Union{Void, AbstractString}
    left::Int
    right::Int
    function CMidRule(wd, trim, left, right)
        @argcheck 1 ≤ left ≤ right
        new(wd, trim, left, right)
    end
end

CMidRule(trim, left, right) = CMidRule(nothing, trim, left, right)

CMidRule(left, right) = CMidRule(nothing, left, right)

function latex_line(io::IO, rule::CMidRule)
    @unpack wd, trim, left, right = rule
    print(io, "\\cmidrule")
    wd ≠ nothing && print(io, "[$(wd)]")
    trim ≠ nothing && print(io, "($(trim))")
    print(io, "{$(left)-$(right)} ") # NOTE trailing space important
end

function latex_line(io::IO, cells)
    for (column, cell) in enumerate(cells)
        column == 1 || print(io, " & ")
        latex_cell(io, cell)
    end
    println(io, " \\\\")
end

function latex_line(io::IO, M::AbstractMatrix)
    for i in indices(M, 1)
        latex_line(io, M[i, :])
    end
end

function latex_line(io::IO, lines::Tuple)
    for line in lines
        latex_line(io, line)
    end
end


# tabular and similar environments

abstract type TabularLike end

"""
    Tabular(cols)

For the LaTeX environment `\\begin{tabular}{cols} ... \\end{tabular}`.
"""
struct Tabular <: TabularLike
    "A column specification, eg `\"llrr\"`."
    cols::AbstractString
end

latex_env_begin(io::IO, t::Tabular) = println(io, "\\begin{tabular}{$(t.cols)}")

latex_env_end(io::IO, t::Tabular) = println(io, "\\end{tabular}")

"""
    $SIGNATURES

Print `lines` to `io` as a LaTeX using the given environment.

Each `line` in `lines` can be

- a rule-like object, eg [`Rule`] or [`CMidRule`],

- an iterable (eg `AbstractVector`) of cells,

- a `Tuple`, which is treated as multiple lines (“splat” in place), which is
  useful for functions that generate lines with associated rules, or multiple
  `CMidRule`s,

- a matrix, each row of which is treated as a line.

See [`latex_cell`](@ref) for the kinds of cell supported (particularly
[`MultiColumn`](@ref), but for full formatting control, use an `String` or
`LaTeXString` for cells.
"""
function latex_tabular(io::IO, t::TabularLike, lines)
    latex_env_begin(io, t)
    for line in lines
        latex_line(io, line)
    end
    latex_env_end(io, t)
end

latex_tabular(io::IO, t::TabularLike, lines::AbstractMatrix) =
    latex_tabular(io, t, [lines])

"""
    $SIGNATURES

LaTeX output as a string.
"""
function latex_tabular(::Type{String}, t::TabularLike, lines)
    io = IOBuffer()
    latex_tabular(io, t, lines)
    String(take!(io))
end

"""
    $SIGNATURES

Write a `tabular`-like LaTeX environment to `filename`, which is **overwritten**
if it already exists.
"""
function latex_tabular(filename::AbstractString, t::TabularLike, lines)
    open(filename, "w") do io
        latex_tabular(io, t, lines)
    end
end

end # module
