module LaTeXTabulars

using DocStringExtensions

export Rule, print_tabular


# cells

"""
    $SIGNATURES
"""
function print_cell(io::IO, ::T) where T
    info("Define a method for writing $T objects to LaTeX.")
    throw(MethodError(print_tex, Tuple{IO, T}))
end

print_cell(io::IO, x::Real) = print(io, string(x))

print_cell(io::IO, s::AbstractString) = print(io, s)


# lines and line-like objects

struct Rule{T} end

Rule(kind::Symbol) = Rule{kind}()

print_line(io::IO, ::Rule{:top}) = println(io, "\\toprule")

print_line(io::IO, ::Rule{:mid}) = println(io, "\\midrule")

print_line(io::IO, ::Rule{:bottom}) = println(io, "\\bottomrule")

function print_line(io::IO, cells)
    for (column, cell) in enumerate(cells)
        column == 1 || print(io, " & ")
        print_cell(io, cell)
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
"""
function print_tabular(io::IO, cols::AbstractString, lines)
    println(io, "\\begin{tabular}{$cols}")
    for line in lines
        print_line(io, line)
    end
    println(io, "\\end{tabular}")
end

function print_tabular(::Type{String}, args...)
    io = IOBuffer()
    print_tabular(io, args...)
    String(take!(io))
end

end # module
