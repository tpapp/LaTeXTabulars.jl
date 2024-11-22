"""
$(DocStringExtensions.README)
"""
module LaTeXTabulars

using ArgCheck: @argcheck
using DocStringExtensions: SIGNATURES, DocStringExtensions
using LaTeXEscapes: LaTeX, @lx_str, print_escaped, wrap_math

export DEFAULT_FORMATTER, SimpleCellFormatter, Rule, CMidRule, MultiColumn, MultiRow,
    Tabular, LongTable, latex_tabular

####
#### cell formatters
####

struct SimpleCellFormatter
    inf
    minus_inf
    NaN
    nothing
    missing
    @doc """
    $(SIGNATURES)

    A simple formatter that replaces some commonly used values used in displaying data.

    Each field below should contain a string or a `LaTeX` code (otherwise, it is emitted
    as an escaped string).
    """
    function SimpleCellFormatter(; inf = lx"\infty"m, minus_inf = lx"-\infty"m, NaN = "NaN",
                                 nothing = "---", missing = "---")
        new(inf, minus_inf, NaN, nothing, missing)
    end
end

"The default formatter for `latex_table`. Its initial value is [`SimpleCellFormatter`](@ref)."
DEFAULT_FORMATTER = SimpleCellFormatter(;)

function (formatter::SimpleCellFormatter)(x)
    if isnothing(x)
        formatter.nothing
    elseif ismissing(x)
        formatter.missing
    elseif x isa Real
        if x == Inf
            formatter.inf
        elseif x == -Inf
            formatter.minus_inf
        elseif isnan(x)
            formatter.NaN
        else
            wrap_math(string(x))
        end
    else
        x
    end
end

"""
$(SIGNATURES)

Write a the contents of `cell` to `io` as LaTeX.

`formatter` is callable that is used to format cells that are not already
`::AbstractString` or `::LaTeX`. If either of these are returned by the formatter, they
are written into the LaTeX output, otherwise they are formatted as strings (and escaped
asnecessary when written into LaTeX).

!!! note
    If you want to make simple formatting changes, it is best to write your own
    `formatter`.
"""
function latex_cell(io::IO, x, formatter)
    print_escaped(io, formatter(x))
end

latex_cell(io::IO, s::AbstractString, _) = print_escaped(io, s)

latex_cell(io::IO, l::LaTeX, _) = print_escaped(io, l)

"""
`MultiColumn(n, pos, cell)`

For `\\multicolumn{n}{pos}{cell}`. Use the symbols `:l`, `:c`, `:r` for `pos`.
"""
struct MultiColumn
    n::Int
    pos::Symbol
    cell
end

function latex_cell(io::IO, mc::MultiColumn, formatter)
    (; n, pos, cell) = mc
    @argcheck(pos ∈ (:l, :c, :r),
              "$(pos) is not a recognized position. Use :l, :c, :r.")
    print(io, "\\multicolumn{$(n)}{$(pos)}{")
    latex_cell(io, cell, formatter)
    print(io, "}")
end

"""
    MultiRow(n::Int, vpos::Symbol, cell::Any, width::String)
    MultiRow(n, vpos, cell; width="*")

For `\\multirow[vpos]{n}{width}{cell}`. Use the symbols `:t`, `:c`, `:b` for `vpos`.
"""
struct MultiRow
    n::Int
    vpos::Symbol
    cell::Any
    width::String
end

MultiRow(n, vpos, cell; width="*") = MultiRow(n, vpos, cell, width)

function latex_cell(io::IO, mr::MultiRow, formatter)
    (; vpos, n, width, cell) = mr
    @argcheck(vpos ∈ (:t, :c, :b),
              "$(vpos) is not a recognized position. Use :t, :c, :b.")
    print(io, "\\multirow[$vpos]{$(n)}{$width}{")
    latex_cell(io, cell, formatter)
    print(io, "}")
end


# non-cell-like objects

struct Rule{T} end

"""
$(SIGNATURES)

Horizontal rule. The `kind` of the rule is specified by a symbol, which will
generally be printed as `\\KINDrule` for rules in `booktabs`, eg `Rule(:top)`
prints `\\toprule`. To obtain a `\\hline`, use `Rule{:h}`.
"""
Rule(kind::Symbol = :h) = Rule{kind}()

"""
$(SIGNATURES)

Emit an object that takes up a whole line in a table. Mostly used for rules.
"""
latex_line(io::IO, ::Rule{:top}, _) = println(io, "\\toprule")

latex_line(io::IO, ::Rule{:mid}, _) = println(io, "\\midrule")

latex_line(io::IO, ::Rule{:bottom}, _) = println(io, "\\bottomrule")

latex_line(io::IO, ::Rule{:h}, _) = println(io, "\\hline")

latex_line(io::IO, r::Rule, _) = error("Don't know how to print $(typeof(r)).")

struct CMidRule
    wd
    trim
    left::Int
    right::Int
    @doc """
    `CMidRule([wd], [trim], left, right)`

    Will be printed as `\\cmidrule[wd](trim)[left-right]`. When `wd` or `trim` is
    `nothing`, it is omitted. Use with the `booktabs` LaTeX package.
    """
    function CMidRule(wd, trim, left, right)
        @argcheck 1 ≤ left ≤ right
        new(wd, trim, left, right)
    end
end

CMidRule(trim, left, right) = CMidRule(nothing, trim, left, right)

CMidRule(left, right) = CMidRule(nothing, left, right)

function latex_line(io::IO, rule::CMidRule, _)
    (; wd, trim, left, right) = rule
    print(io, raw"\cmidrule")
    wd ≡ nothing || print(io, "[$(print_escaped(String, wd))]")
    trim ≡ nothing || print(io, "($(print_escaped(String, trim)))")
    # NOTE trailing space important
    print(io, "{$(print_escaped(String, left))-$(print_escaped(String, right))} ")
end

function latex_line(io::IO, cells, formatter)
    for (column, cell) in enumerate(cells)
        column == 1 || print(io, " & ")
        latex_cell(io, cell, formatter)
    end
    println(io, " \\\\")
end

function latex_line(io::IO, matrix::AbstractMatrix, formatter)
    for row in eachrow(matrix)
        latex_line(io, row, formatter)
    end
end

function latex_line(io::IO, lines::Tuple, formatter)
    for line in lines
        latex_line(io, line, formatter)
    end
end

"""
`LineSpace([wd])`

Prints `\\addlinespace[wd]`. When `wd` is `nothing`, it is omitted.
Use with the `booktabs` LaTeX package.
"""
struct LineSpace
    wd::Union{Nothing, AbstractString}
end

LineSpace() = LineSpace(nothing)

function latex_line(io::IO, ls::LineSpace)
    @unpack wd = ls
    print(io, "\\addlinespace")
    wd ≠ nothing && print(io, "[$(wd)]")
    println(io)
end

# tabular and similar environments

abstract type TabularLike end

"""
`Tabular(cols)`

For the LaTeX environment `\\begin{tabular}{cols} ... \\end{tabular}`.

`cols` should follow the column specification syntax of `tabular`.

# Example

```jldoctest
julia> using LaTeXTabulars

julia> Tabular("l" * "r"^5)
Tabular("lrrrrr")
```
"""
struct Tabular <: TabularLike
    "A column specification, eg `\"llrr\"`."
    cols::AbstractString
    function Tabular(cols::AbstractString)
        new(cols)
    end
end

"""
$(SIGNATURES)

Write the beginning of the environment `t`, using `formatter`.
"""
latex_env_begin(io::IO, t::Tabular, formatter) = println(io, "\\begin{tabular}{$(t.cols)}")

"""
$(SIGNATURES)

Write the end of the environment `t`, using `formatter`.
"""
latex_env_end(io::IO, t::Tabular, formatter) = println(io, "\\end{tabular}")

"""
$(SIGNATURES)

Print `lines` to `io` as a LaTeX using the given environment.

Each `line` in `lines` can be

- a rule-like object, eg [`Rule`](@ref) or [`CMidRule`](@ref),

- an iterable (eg `AbstractVector`) of cells,

- a `Tuple`, which is treated as multiple lines (“splat” in place), which is
  useful for functions that generate lines with associated rules, or multiple
  `CMidRule`s,

- a matrix, each row of which is treated as a line.

Constructs which contain cells are printed by [`latex_cell`](@ref), using the
`formatter`, which leaves strings and `LaTeX` cells as is.

It is recommended that formatting parts of the table is done directly on the arguments,
using a suitable formatter. See the manual for examples.

See [`latex_cell`](@ref) for the kinds of cell supported (particularly
[`MultiColumn`](@ref), but for full formatting control, use an `String` or
`LaTeXString` for cells.
"""
function latex_tabular(io::IO, t::TabularLike, lines;
                       formatter = DEFAULT_FORMATTER)
    latex_env_begin(io, t, formatter)
    for line in lines
        latex_line(io, line, formatter)
    end
    latex_env_end(io, t, formatter)
end

function latex_tabular(io::IO, t::TabularLike, lines::AbstractMatrix;
                       formatter = DEFAULT_FORMATTER)
    latex_tabular(io, t, [lines]; formatter)
end

"""
$(SIGNATURES)

LaTeX output as a string. See other method for the other arguments.
"""
function latex_tabular(::Type{String}, t::TabularLike, lines;
                       formatter = DEFAULT_FORMATTER)
    io = IOBuffer()
    latex_tabular(io, t, lines; formatter)
    String(take!(io))
end

"""
$(SIGNATURES)

Write a `tabular`-like LaTeX environment to `filename`, which is **overwritten**
if it already exists.
"""
function latex_tabular(filename::AbstractString, t::TabularLike, lines;
                       formatter = DEFAULT_FORMATTER)
    open(filename, "w") do io
        latex_tabular(io, t, lines)
    end
end

"""
`LongTable(cols, header)`

The `longtable` ``\\LaTeX`` environment. `cols` is a column specification, `header`
is an iterable of cells (cf [`latex_cell`](@ref) that is repeated at the top of each
page. `formatter` is applied to all cells.
"""
struct LongTable <: TabularLike
    "A column specification, eg `\"llrr\"`."
    cols::AbstractString
    """
    The table header, to be repeated at the top of each page, supplied an iterable of cells,
    eg `[\"alpha\", \"beta\", \"gamma\"]`.
    """
    header
end

function latex_env_begin(io::IO, t::LongTable, formatter)
    println(io, "\\begin{longtable}[c]{$(t.cols)}")
    latex_line(io, Rule(:h), formatter)
    latex_line(io, t.header, formatter)
    latex_line(io, Rule(:h), formatter)
    println(io, "\\endfirsthead")
    println(io, "\\multicolumn{$(length(t.cols))}{l}")
    println(io, "{{\\bfseries \\tablename\\ \\thetable{} --- continued from previous page}} \\\\")
    latex_line(io, Rule(:h), formatter)
    latex_line(io, t.header, formatter)
    latex_line(io, Rule(:h), formatter)
    println(io, "\\endhead")
    latex_line(io, Rule(:h), formatter)
    println(io, "\\multicolumn{$(length(t.cols))}{r}{{\\bfseries Continued on next page}} \\\\")
    latex_line(io, Rule(:h), formatter)
    println(io, "\\endfoot")
    latex_line(io, Rule(:h), formatter)
    println(io, "\\endlastfoot")
end

latex_env_end(io::IO, t::LongTable, _) = println(io, "\\end{longtable}")

end # module
