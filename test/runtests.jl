using LaTeXTabulars

# for testing
using LaTeXTabulars: latex_cell

using Base.Test
using LaTeXStrings

"Normalize whitespace, for more convenient testing."
squash_whitespace(string) = strip(replace(string, r"[ \n\t]+", " "))

@test squash_whitespace(" something  \n with line  breaks \n  and   stuff \n") ==
    "something with line breaks and stuff"

"Comparison using normalized whitespace. For testing."
≅(a, b) = squash_whitespace(a) == squash_whitespace(b)


@testset "tabular" begin
    tb = Tabular("lcl")
    tlines = [Rule(:top),
              [L"\alpha", L"\beta", "sum"],
              Rule(:mid),
              [1, 2, 3],
              Rule(), # a nice \hrule to make it ugly
              [4.0, "5", "six"],
              [MultiColumn(2, :c, "centered")], # ragged!
              Rule(:bottom)]
    tlatex = raw"\begin{tabular}{lcl}
                 \toprule
                 $\alpha$ & $\beta$ & sum \\
                 \midrule
                 1 & 2 & 3 \\
                 \hrule
                 4.0 & 5 & six \\
                 \multicolumn{2}{c}{centered} \\
                 \bottomrule
                 \end{tabular}"

    @test latex_tabular(String, tb, tlines) ≅ tlatex
    tmp = tempname()
    latex_tabular(tmp, tb, tlines)
    @test isfile(tmp) && readstring(tmp) ≅ tlatex
end

@test_throws ArgumentError latex_cell(STDOUT, MultiColumn(2, :BAD, ""))
@test_throws MethodError latex_cell(STDOUT, ("un", "supported"))
