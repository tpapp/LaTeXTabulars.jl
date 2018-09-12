using LaTeXTabulars

# for testing
using LaTeXTabulars: latex_cell

using Test
using LaTeXStrings

"Normalize whitespace, for more convenient testing."
squash_whitespace(string) = strip(replace(string, r"[ \n\t]+" => " "))

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
              Rule(),           # a nice \hline to make it ugly
              [4.0 "5" "six";   # a matrix
               7 8 9],
              (CMidRule(1, 2), CMidRule("lr", 1, 1)), # just to test tuples
              [MultiColumn(2, :c, "centered")],       # ragged!
              Rule(:bottom)]
    tlatex = raw"\begin{tabular}{lcl}
                 \toprule
                 $\alpha$ & $\beta$ & sum \\
                 \midrule
                 1 & 2 & 3 \\
                 \hline
                 4.0 & 5 & six \\
                 7 & 8 & 9 \\ \cmidrule{1-2} \cmidrule(lr){1-1}
                 \multicolumn{2}{c}{centered} \\
                 \bottomrule
                 \end{tabular}"

    tlatex = replace(tlatex, "\r\n"=>"\n")
    @test latex_tabular(String, tb, tlines) ≅ tlatex
    tmp = tempname()
    latex_tabular(tmp, tb, tlines)
    @test isfile(tmp) && readstring(tmp) ≅ tlatex
    @test read(tmp, String) ≅ tlatex
end

@test_throws ArgumentError latex_cell(stdout, MultiColumn(2, :BAD, ""))
@test_throws ArgumentError CMidRule(3, 1)     # not ≤
@test_throws MethodError latex_cell(stdout, ("un", "supported"))
@test_throws MethodError CMidRule(1, 1, 1, 2) # invalid types
