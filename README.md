# LaTeXTabulars

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![Build Status](https://travis-ci.org/tpapp/LaTeXTabulars.jl.svg?branch=master)](https://travis-ci.org/tpapp/LaTeXTabulars.jl)
[![Coverage Status](https://coveralls.io/repos/tpapp/LaTeXTabulars.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/tpapp/LaTeXTabulars.jl?branch=master)
[![codecov.io](http://codecov.io/github/tpapp/LaTeXTabulars.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/LaTeXTabulars.jl?branch=master)

Write tabular data from Julia in LaTeX format.

This is a *very thin wrapper*, basically for avoiding some loops and repeatedly used strings. It assumes that you know how the LaTeX `tabular` environment works, and you have formatted the cells to strings if you want anything fancy like rounding or alignment on the decimal dot.

This is how it works:

```julia
using LaTeXTabulars
using LaTeXStrings # not dependency
latex_tabular("/tmp/table.tex",
              Tabular("lcl"),
              [Rule(:top),
               [L"\alpha", L"\beta", "sum"],
               Rule(:mid),
               [1, 2, 3],
               Rule(),           # a nice \hrule to make it ugly
               [4.0 "5" "six";   # a matrix
                7 8 9],
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
\hrule
4.0 & 5 & six \\
7 & 8 & 9 \\
\multicolumn{2}{c}{centered} \\
\bottomrule
\end{tabular}
```
to `/tmp/table.tex`.

It is important to note that

1. the position specifier `lcl` is not checked for valid syntax or consitency with the contents, just emitted as is, allowing the use of [dcolumn](https://ctan.org/pkg/dcolumn) or similar,

2. the lines are either

    a. `Rule`s, which you would put on their own line anyway for nicely formatted LaTeX,
    b. iterables of cells (not checked for number of cells),
    c. matrices, which are printed line by line.

3. [booktabs](https://ctan.org/pkg/booktabs) rules are supported.

Vertical rules of any kind are *not explicitly supported* and it would be difficult to convince me to add them. The documentation of [booktabs](https://ctan.org/pkg/booktabs) should explain why. That said, if you insist, you can use a cell like `\vline text`.

The code is generic, so [other tabular-like types](https://en.wikibooks.org/wiki/LaTeX/Tables) can be easily added, just open an issue.
