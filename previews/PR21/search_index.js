var documenterSearchIndex = {"docs":
[{"location":"#LaTeXTabulars","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"","category":"section"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"using LaTeXCompilers, LaTeXTabulars\n\nstruct ShowMe\n    content\nend\n\nfunction Base.show(out_io::IO, ::MIME\"image/svg+xml\", showme::ShowMe)\n    (; content) = showme\n    LaTeXCompilers.svg(out_io) do io\n        print(io,\n              raw\"\"\"\n\\documentclass[12pt]{standalone}\n\\usepackage{booktabs}\n\\usepackage{graphicx}\n\\begin{document}\n\\scalebox{2}{\n\"\"\")\n        print(io, content)\n        print(io, raw\"}\\end{document}\")\n    end\nend","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"LaTeXTabulars.LaTeXTabulars","category":"page"},{"location":"#LaTeXTabulars.LaTeXTabulars","page":"LaTeXTabulars","title":"LaTeXTabulars.LaTeXTabulars","text":"LaTeXTabulars.jl\n\n(Image: lifecycle) (Image: build) (Image: codecov.io)\n\nWrite tabular data from Julia in LaTeX format.\n\nThis is a very thin wrapper, basically for avoiding some loops and repeatedly used strings. It assumes that you know how the LaTeX tabular environment works, and you have formatted the cells to strings if you want anything fancy like rounding or alignment on the decimal dot.\n\nThe package is documented with a manual and docstrings.\n\n\n\n\n\n","category":"module"},{"location":"#Writing-tables","page":"LaTeXTabulars","title":"Writing tables","text":"","category":"section"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"The main entry point of the package is latex_tabular, which takes a destination (a filename, or String), a table specification (eg Tabular and an iterable, which is rendered elementwise using the following rules:","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"special objects like Rule emit the corresponding LaTeX code,\nvectors and iterables emit a row of cells (not checked for length),\nmatrices are treated as rows of vectors,\nTuples are “splat” into place, which is useful for writing functions that format tables.","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"note: Note\nSome examples in this manual, eg the one below, use the booktabs LaTeX package. If you are including them in a LaTeX document, make sure you add \\usepackage{booktabs}.","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"latex_tabular(String, Tabular(\"lr\"),\n              [Rule(:top),\n              [\"critter\", \"count\"],\n              Rule(:mid),\n               [\"cats\", 5],\n               [\"dogs\", 7],\n               Rule(:bottom)]) \n(z = ans; print(z)) # hide","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"which renders as","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"ShowMe(z) # hide","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"The simplest table specification is Tabular.","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"Tabular","category":"page"},{"location":"#LaTeXTabulars.Tabular","page":"LaTeXTabulars","title":"LaTeXTabulars.Tabular","text":"Tabular(cols)\n\nFor the LaTeX environment \\begin{tabular}{cols} ... \\end{tabular}.\n\ncols should follow the column specification syntax of tabular.\n\nExample\n\njulia> using LaTeXTabulars\n\njulia> Tabular(\"l\" * \"r\"^5)\nTabular(\"lrrrrr\")\n\n\n\n\n\n","category":"type"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"Long tables are also supported.","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"LongTable","category":"page"},{"location":"#LaTeXTabulars.LongTable","page":"LaTeXTabulars","title":"LaTeXTabulars.LongTable","text":"LongTable(cols, header)\n\nThe longtable LaTeX environment. cols is a column specification, header is an iterable of cells (cf latex_cell that is repeated at the top of each page. formatter is applied to all cells.\n\n\n\n\n\n","category":"type"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"Other table types would be simple to add, see adding extensions.","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"latex_tabular","category":"page"},{"location":"#LaTeXTabulars.latex_tabular","page":"LaTeXTabulars","title":"LaTeXTabulars.latex_tabular","text":"latex_tabular(io, t, lines; formatter)\n\n\nPrint lines to io as a LaTeX using the given environment.\n\nEach line in lines can be\n\na rule-like object, eg Rule or CMidRule,\nan iterable (eg AbstractVector) of cells,\na Tuple, which is treated as multiple lines (“splat” in place), which is useful for functions that generate lines with associated rules, or multiple CMidRules,\na matrix, each row of which is treated as a line.\n\nConstructs which contain cells are printed by latex_cell, using the formatter, which leaves strings and LaTeX cells as is.\n\nIt is recommended that formatting parts of the table is done directly on the arguments, using a suitable formatter. See the manual for examples.\n\nSee latex_cell for the kinds of cell supported (particularly MultiColumn, but for full formatting control, use an String or LaTeXString for cells.\n\n\n\n\n\nlatex_tabular(, t, lines; formatter)\n\n\nLaTeX output as a string. See other method for the other arguments.\n\n\n\n\n\nlatex_tabular(filename, t, lines; formatter)\n\n\nWrite a tabular-like LaTeX environment to filename, which is overwritten if it already exists.\n\n\n\n\n\n","category":"function"},{"location":"#Cells","page":"LaTeXTabulars","title":"Cells","text":"","category":"section"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"Tables contain formatting (eg rules) and cells.","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"Cells can be","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"strings (which are escaped when written into LaTeX, so eg % is replaced by \\%),\nLaTeX wrappers like LaTeXEscapes.LaTeX and LaTeXStrings.LaTeXString, \nand arbitrary Julia objects, which are converted with string, then escaped.","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"These rules apply to all cells, including MultiColumn and other special wrappers.","category":"page"},{"location":"#Inserting-LaTeX-code","page":"LaTeXTabulars","title":"Inserting LaTeX code","text":"","category":"section"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"LaTeX code can be inserted into tables using the LaTeXEscapes.jl and LaTeXStrings.jl packages, which use the lx\"...\"[m] and L\"...\" read string macros, respectively. The difference between the two packages is that lx\"...\" does not create values which are subtypes of string, and does not wrap in math mode inless you add the m flag. Naturally, the explicit wrapper types (eg LaTeXEscapes.LaTeX) can be used, too.","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"using LaTeXEscapes, LaTeXStrings\nlatex_tabular(String, Tabular(\"ll\"),\n               [[lx\"\\alpha\"m, L\"\\beta\"],\n                [LaTeX(raw\"$\\gamma$\"), \"100%\"]]) \n(z = ans; print(z)) # hide","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"which renders as","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"ShowMe(z) # hide","category":"page"},{"location":"#Special-constructs","page":"LaTeXTabulars","title":"Special constructs","text":"","category":"section"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"Rule\nCMidRule","category":"page"},{"location":"#LaTeXTabulars.Rule","page":"LaTeXTabulars","title":"LaTeXTabulars.Rule","text":"Rule()\nRule(kind)\n\n\nHorizontal rule. The kind of the rule is specified by a symbol, which will generally be printed as \\KINDrule for rules in booktabs, eg Rule(:top) prints \\toprule. To obtain a \\hline, use Rule{:h}.\n\n\n\n\n\n","category":"type"},{"location":"#LaTeXTabulars.CMidRule","page":"LaTeXTabulars","title":"LaTeXTabulars.CMidRule","text":"CMidRule([wd], [trim], left, right)\n\nWill be printed as \\cmidrule[wd](trim)[left-right]. When wd or trim is nothing, it is omitted. Use with the booktabs LaTeX package.\n\n\n\n\n\n","category":"type"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"MultiColumn\nMultiRow","category":"page"},{"location":"#LaTeXTabulars.MultiColumn","page":"LaTeXTabulars","title":"LaTeXTabulars.MultiColumn","text":"MultiColumn(n, pos, cell)\n\nFor \\multicolumn{n}{pos}{cell}. Use the symbols :l, :c, :r for pos.\n\n\n\n\n\n","category":"type"},{"location":"#LaTeXTabulars.MultiRow","page":"LaTeXTabulars","title":"LaTeXTabulars.MultiRow","text":"MultiRow(n::Int, vpos::Symbol, cell::Any, width::String)\nMultiRow(n, vpos, cell; width=\"*\")\n\nFor \\multirow[vpos]{n}{width}{cell}. Use the symbols :t, :c, :b for vpos.\n\n\n\n\n\n","category":"type"},{"location":"#Formatting","page":"LaTeXTabulars","title":"Formatting","text":"","category":"section"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"For the purposes of this package, formatting is the conversion of Julia values to strings or LaTeX code.","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"A formatter is a callable that converts its arguments to the above, or leaves it alone. This allows the user to chain formatters.","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"The user can either format the arguments to latex_tabular directly, which allows more flexibility, or provide a formatter via the formatter keyword,  which defaults to DEFAULT_FORMATTER, which is initialized with SimpleCellFormatter.","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"latex_tabular(String, Tabular(\"ll\"),\n               [[Inf, -Inf],\n                [NaN, -0.0],\n                [missing, nothing]])\n(z = ans; print(z)) # hide","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"which renders as","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"ShowMe(z) # hide","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"DEFAULT_FORMATTER\nSimpleCellFormatter","category":"page"},{"location":"#LaTeXTabulars.DEFAULT_FORMATTER","page":"LaTeXTabulars","title":"LaTeXTabulars.DEFAULT_FORMATTER","text":"The default formatter for latex_table. Its initial value is SimpleCellFormatter.\n\n\n\n\n\n","category":"constant"},{"location":"#LaTeXTabulars.SimpleCellFormatter","page":"LaTeXTabulars","title":"LaTeXTabulars.SimpleCellFormatter","text":"SimpleCellFormatter(; inf, minus_inf, NaN, nothing, missing)\n\n\nA simple formatter that replaces some commonly used values used in displaying data.\n\nEach field below should contain a string or a LaTeX code (otherwise, it is emitted as an escaped string).\n\n\n\n\n\n","category":"type"},{"location":"#extending-the-code","page":"LaTeXTabulars","title":"Adding extensions","text":"","category":"section"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"You can extend the functionality of this package in various ways:","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"add formatters (see eg SimpleCellFormatter),\nadd rule-like objects, for which you have to define a LaTeXTabulars.latex_line method,\nadd a new table type, for which it is recommended that you define LaTeXTabulars.latex_env_begin and LaTeXTabulars.latex_env_end. See the LongTable methods for an example.","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"note: Note\nIt is very unlikely that you have to add methods for LaTeXTabulars.latex_cell or LaTeXTabulars.latex_tabular.","category":"page"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"LaTeXTabulars.latex_cell\nLaTeXTabulars.latex_line\nLaTeXTabulars.latex_env_begin\nLaTeXTabulars.latex_env_end","category":"page"},{"location":"#LaTeXTabulars.latex_cell","page":"LaTeXTabulars","title":"LaTeXTabulars.latex_cell","text":"latex_cell(io, x, formatter)\n\n\nWrite a the contents of cell to io as LaTeX.\n\nformatter is callable that is used to format cells that are not already ::AbstractString or ::LaTeX. If either of these are returned by the formatter, they are written into the LaTeX output, otherwise they are formatted as strings (and escaped asnecessary when written into LaTeX).\n\nnote: Note\nIf you want to make simple formatting changes, it is best to write your own formatter.\n\n\n\n\n\n","category":"function"},{"location":"#LaTeXTabulars.latex_line","page":"LaTeXTabulars","title":"LaTeXTabulars.latex_line","text":"latex_line(io, _, _)\n\n\nEmit an object that takes up a whole line in a table. Mostly used for rules.\n\n\n\n\n\n","category":"function"},{"location":"#LaTeXTabulars.latex_env_begin","page":"LaTeXTabulars","title":"LaTeXTabulars.latex_env_begin","text":"latex_env_begin(io, t, formatter)\n\n\nWrite the beginning of the environment t, using formatter.\n\n\n\n\n\n","category":"function"},{"location":"#LaTeXTabulars.latex_env_end","page":"LaTeXTabulars","title":"LaTeXTabulars.latex_env_end","text":"latex_env_end(io, t, formatter)\n\n\nWrite the end of the environment t, using formatter.\n\n\n\n\n\n","category":"function"},{"location":"","page":"LaTeXTabulars","title":"LaTeXTabulars","text":"note: Note\nRule types in booktabs are supported. Vertical rules of any kind are not explicitly supported and it would be difficult to convince me to add them. The documentation of booktabs should explain why. That said, if you insist, you can use a cell like \\vline text.","category":"page"}]
}
