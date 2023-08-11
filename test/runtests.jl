using LaTeXTabulars, Test, LaTeXStrings

# for testing
using LaTeXTabulars: latex_cell

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
              [MultiRow(2, :c, "a11 \\& a21"), "a12", "a13"],
              LineSpace(),
              ["", "a22", "a23"],
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
                 7 & 8 & 9 \\
                 \multirow[c]{2}{*}{a11 \& a21} & a12 & a13 \\
                 \addlinespace
                 & a22 & a23 \\ \cmidrule{1-2} \cmidrule(lr){1-1}
                 \multicolumn{2}{c}{centered} \\
                 \bottomrule
                 \end{tabular}"

    tlatex = replace(tlatex, "\r\n"=>"\n")
    @test latex_tabular(String, tb, tlines) ≅ tlatex
    tmp = tempname()
    latex_tabular(tmp, tb, tlines)
    @test isfile(tmp) && read(tmp, String) ≅ tlatex
    @test read(tmp, String) ≅ tlatex
end

@test_throws ArgumentError latex_cell(stdout, MultiColumn(2, :BAD, ""))
@test_throws ArgumentError CMidRule(3, 1)     # not ≤
@test_throws MethodError latex_cell(stdout, ("un", "supported"))
@test_throws MethodError CMidRule(1, 1, 1, 2) # invalid types

@testset "longtable" begin
    lt = LongTable("rrr", ["alpha", "beta", "gamma"])
    tlines = [[1 2 3 ;
               4.0 "5" "six"],
              Rule(:h)]
    tlatex = raw"\begin{longtable}[c]{rrr}
                 \hline
                 alpha & beta & gamma \\
                 \hline
                 \endfirsthead
                 \multicolumn{3}{l}
                 {{\bfseries \tablename\ \thetable{} --- continued from previous page}} \\
                 \hline
                 alpha & beta & gamma \\
                 \hline
                 \endhead
                 \hline
                 \multicolumn{3}{r}{{\bfseries Continued on next page}} \\
                 \hline
                 \endfoot
                 \hline
                 \endlastfoot
                 1 & 2 & 3 \\
                 4.0 & 5 & six \\
                 \hline
                 \end{longtable}"

    tlatex = replace(tlatex, "\r\n"=>"\n")
    @test latex_tabular(String, lt, tlines) ≅ tlatex
    tmp = tempname()
    latex_tabular(tmp, lt, tlines)
    @test isfile(tmp) && read(tmp, String) ≅ tlatex
    @test read(tmp, String) ≅ tlatex
end
