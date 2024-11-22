# LaTeXTabulars

```@setup all
using LaTeXCompilers, LaTeXTabulars

struct ShowMe
    content
end

function Base.show(out_io::IO, ::MIME"image/svg+xml", showme::ShowMe)
    (; content) = showme
    LaTeXCompilers.svg(out_io) do io
        print(io,
              raw"""
\documentclass[12pt]{standalone}
\usepackage{booktabs}
\usepackage{graphicx}
\begin{document}
\scalebox{2}{
""")
        print(io, content)
        print(io, raw"}\end{document}")
    end
end
```

```@docs
LaTeXTabulars.LaTeXTabulars
```

## Writing tables

The main entry point of the package is [`latex_tabular`](@ref), which takes a *destination* (a filename, or `String`), a *table specification* (eg [`Tabular`](@ref) and an *iterable*, which is rendered elementwise using the following rules:

1. special objects like `Rule` emit the corresponding ``\LaTeX`` code,
2. vectors and iterables emit a row of cells (not checked for length),
3. matrices are treated as rows of vectors,
4. `Tuple`s are “splat” into place, which is useful for writing functions that format tables.

!!! note
    Some examples in this manual, eg the one below, use the
    [`booktabs`](https://ctan.org/pkg/booktabs/) LaTeX package. If you
    are including them in a ``\LaTeX`` document, make sure you add
    `\usepackage{booktabs}`.

```@example all
latex_tabular(String, Tabular("lr"),
              [Rule(:top),
              ["critter", "count"],
              Rule(:mid),
               ["cats", 5],
               ["dogs", 7],
               Rule(:bottom)]) 
(z = ans; print(z)) # hide
```
which renders as
```@example all
ShowMe(z) # hide
```

The simplest table specification is [`Tabular`](@ref).
```@docs
Tabular
```
Long tables are also supported.
```@docs
LongTable
```
Other table types would be simple to add, see [adding extensions](@ref extending-the-code).

```@docs
latex_tabular
```

## Cells

Tables contain formatting (eg rules) and *cells*.

Cells can be

1. *strings* (which are escaped when written into LaTeX, so eg `%` is replaced by `\%`),
2. LaTeX wrappers like `LaTeXEscapes.LaTeX` and `LaTeXStrings.LaTeXString`, 
3. and arbitrary Julia objects, which are converted with `string`, then escaped.

These rules apply to all cells, including [`MultiColumn`](@ref) and other special wrappers.

### Inserting LaTeX code

LaTeX code can be inserted into tables using the [LaTeXEscapes.jl](https://github.com/tpapp/LaTeXEscapes.jl) and [LaTeXStrings.jl](https://github.com/JuliaStrings/LaTeXStrings.jl) packages, which use the `lx"..."[m]` and `L"..."` read string macros, respectively. The difference between the two packages is that `lx"..."` does not create values which are subtypes of string, and does not wrap in math mode inless you add the `m` flag. Naturally, the explicit wrapper types (eg `LaTeXEscapes.LaTeX`) can be used, too.

```@example all
using LaTeXEscapes, LaTeXStrings
latex_tabular(String, Tabular("ll"),
               [[lx"\alpha"m, L"\beta"],
                [LaTeX(raw"$\gamma$"), "100%"]]) 
(z = ans; print(z)) # hide
```
which renders as
```@example all
ShowMe(z) # hide
```

## Special constructs

```@docs
Rule
CMidRule
LineSpace
```

```@docs
MultiColumn
MultiRow
```

### Formatting

For the purposes of this package, *formatting* is the conversion of Julia values to strings or `LaTeX` code.

A *formatter* is a callable that converts its arguments to the above, or leaves it alone. This allows the user to *chain* formatters.

The user can either format the arguments to [`latex_tabular`](@ref) **directly**, which allows more flexibility, or provide a formatter via the `formatter` keyword,  which defaults to [`DEFAULT_FORMATTER`](@ref), which is initialized with [`SimpleCellFormatter`](@ref).

```@example all
latex_tabular(String, Tabular("ll"),
               [[Inf, -Inf],
                [NaN, -0.0],
                [missing, nothing]])
(z = ans; print(z)) # hide
```
which renders as
```@example all
ShowMe(z) # hide
```

```@docs
DEFAULT_FORMATTER
SimpleCellFormatter
```

## [Adding extensions](@id extending-the-code)

You can extend the functionality of this package in various ways:

1. add **formatters** (see eg [`SimpleCellFormatter`](@ref)),
2. add **rule-like objects**, for which you have to define a [`LaTeXTabulars.latex_line`](@ref) method,
3. add a **new table type**, for which it is recommended that you define [`LaTeXTabulars.latex_env_begin`](@ref) and [`LaTeXTabulars.latex_env_end`](@ref). See the [`LongTable`](@ref) methods for an example.

!!! note
     It is very unlikely that you have to add methods for [`LaTeXTabulars.latex_cell`](@ref) or [`LaTeXTabulars.latex_tabular`](@ref).

```@docs
LaTeXTabulars.latex_cell
LaTeXTabulars.latex_line
LaTeXTabulars.latex_env_begin
LaTeXTabulars.latex_env_end
```

!!! note
     Rule types in [booktabs](https://ctan.org/pkg/booktabs) are supported. Vertical rules of any kind are *not explicitly supported* and it would be difficult to convince me to add them. The documentation of [booktabs](https://ctan.org/pkg/booktabs) should explain why. That said, if you insist, you can use a cell like `\vline text`.
