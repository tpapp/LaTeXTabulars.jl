# LaTeXTabulars.jl

![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
[![build](https://github.com/tpapp/LaTeXTabulars.jl/workflows/CI/badge.svg)](https://github.com/tpapp/LaTeXTabulars.jl/actions?query=workflow%3ACI)
[![codecov.io](http://codecov.io/github/tpapp/LaTeXTabulars.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/LaTeXTabulars.jl?branch=master)

Write tabular data from Julia in LaTeX format.

This is a *very thin wrapper*, basically for avoiding some loops and repeatedly used strings. It assumes that you know how the LaTeX `tabular` environment works, and you have formatted the cells to strings if you want anything fancy like rounding or alignment on the decimal dot.

This is how it works:

```julia
using LaTeXTabulars
using LaTeXStrings               # not a dependency, but works nicely
latex_tabular("/tmp/table.tex",
              Tabular("lcl"),
              [Rule(:top),
               [L"\alpha", L"\beta", "sum"],
               Rule(:mid),
               [1, 2, 3],
               Rule(),           # a nice \hline to make it ugly
               [4.0 "5" "six";   # a matrix
                7 8 9],
               CMidRule(1, 2),
               [MultiColumn(2, :c, "centered")], # ragged!
               Rule(:bottom)])
```
will write something like
```LaTeX
\begin{tabular}{lcl}
\toprule
$\alpha$ & $\beta$ & sum \\
\midrule
1 & 2 & 3 \\
\hline
4.0 & 5 & six \\
7 & 8 & 9 \\
\cmidrule{1-2}
\multicolumn{2}{c}{centered} \\
\bottomrule
\end{tabular}
```
to `/tmp/table.tex`.

Note that the position specifier `lcl` is not checked for valid syntax or consitency with the contents, just emitted as is, allowing the use of [dcolumn](https://ctan.org/pkg/dcolumn) or similar, and the number of cells in each line is not checked for consistency. This means that the usual LaTeX rules apply: fewer cells than position specifiers gives you a ragged table, more cells and LaTeX will complain about having to change `&` to `\\`.

See `?latex_tabular` for the documentation of the syntax, and the unit tests for examples.

Rule types in [booktabs](https://ctan.org/pkg/booktabs) are supported. Vertical rules of any kind are *not explicitly supported* and it would be difficult to convince me to add them. The documentation of [booktabs](https://ctan.org/pkg/booktabs) should explain why. That said, if you insist, you can use a cell like `\vline text`.

The other tabular type currently implemented is `LongTable`. The code is generic, so [other tabular-like types](https://en.wikibooks.org/wiki/LaTeX/Tables) can be easily added, just open an issue.
