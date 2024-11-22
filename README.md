# LaTeXTabulars.jl

![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
[![build](https://github.com/tpapp/LaTeXTabulars.jl/workflows/CI/badge.svg)](https://github.com/tpapp/LaTeXTabulars.jl/actions?query=workflow%3ACI)
[![codecov.io](http://codecov.io/github/tpapp/LaTeXTabulars.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/LaTeXTabulars.jl?branch=master)

Write tabular data from Julia in LaTeX format.

This is a *very thin wrapper*, basically for avoiding some loops and repeatedly used strings. It assumes that you know how the LaTeX `tabular` environment works, and you have formatted the cells to strings if you want anything fancy like rounding or alignment on the decimal dot.

The package is documented with a manual and docstrings.
