using LaTeXTabulars, Test, LaTeXStrings, LaTeXEscapes, JET, Aqua

# for testing
using LaTeXTabulars: latex_cell

"Comparison using normalized whitespace, printing the difference. For testing."
function ≅(a, b)
    function normalized_lines(str)
        split(replace(str,
                      r"^ *"m => "",               # beginning of line: remove whitespace
                      r"  *"m => " ",              # elsewhere, replace with one space
                      "\r" => "",                  # no \r, for Windows (is this even needed?)
                      r"\n*$" => "\n",             # normalize trailing newlines to one
                      ), '\n')
    end
    sa = normalized_lines(a)
    sb = normalized_lines(b)
    la = length(sa)
    lb = length(sb)
    for i in min(la, lb)
        if sa[i] ≠ sa[i]
            printstyled("difference in line $(i): "; color = :red)
            print("“$(sa[i])” ≠ “$(sa[i])”")
            return false
        end
    end
    if la > lb
        printstyled("first input has $(la - lb) extra lines"; color = :red)
        print(reduce(vcat, sa[(lb+1):end]))
        false
    elseif la < lb
        printstyled("first input has $(lb - la) extra lines"; color = :red)
        print(reduce(vcat, sb[(la+1):end]))
        false
    else
        true
    end
end

@testset "tabular" begin
    tb = Tabular("lcl")
    tlines = [Rule(:top),
              [lx"\alpha"m, L"\beta", "sum"],
              Rule(:mid),
              [1, 2, 3],
              Rule(),           # a nice \hline to make it ugly
              [4.0 "5" "six";   # a matrix
               7 8 9],
              [MultiRow(2, :c, lx"a11 \& a21"), "a12", "a13"],
              LineSpace(),
              ["", "a22", "a23"],
              (CMidRule(1, 2), CMidRule("lr", 1, 1)), # just to test tuples
              [MultiColumn(2, :c, "centered")],       # ragged!
              Rule(:bottom)]
    tlatex = raw"\begin{tabular}{lcl}
                 \toprule
                 $\alpha$ & $\beta$ & sum \\
                 \midrule
                 $1$ & $2$ & $3$ \\
                 \hline
                 $4.0$ & 5 & six \\
                 $7$ & $8$ & $9$ \\
                 \multirow[c]{2}{*}{a11 \& a21} & a12 & a13 \\
                 \addlinespace
                 & a22 & a23 \\
                 \cmidrule{1-2} \cmidrule(lr){1-1} \multicolumn{2}{c}{centered} \\
                 \bottomrule
                 \end{tabular}"
    @test latex_tabular(String, tb, tlines) ≅ tlatex
    tmp = tempname()
    latex_tabular(tmp, tb, tlines)
    @test isfile(tmp) && read(tmp, String) ≅ tlatex
    @test read(tmp, String) ≅ tlatex
end

@test_throws "BAD is not a recognized position" latex_cell(stdout, MultiColumn(2, :BAD, ""), identity)
@test_throws ArgumentError CMidRule(3, 1)     # not ≤
@test_throws MethodError CMidRule(1, 1, "a fish", 2) # invalid types

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
                 $1$ & $2$ & $3$ \\
                 $4.0$ & 5 & six \\
                 \hline
                 \end{longtable}"

    @test latex_tabular(String, lt, tlines) ≅ tlatex
    tmp = tempname()
    latex_tabular(tmp, lt, tlines)
    @test isfile(tmp) && read(tmp, String) ≅ tlatex
    @test read(tmp, String) ≅ tlatex
end

using JET
@testset "static analysis with JET.jl" begin
    @test isempty(JET.get_reports(report_package(LaTeXTabulars,
                                                 target_modules=(LaTeXTabulars,))))
end

@testset "QA with Aqua" begin
    import Aqua
    Aqua.test_all(LaTeXTabulars; ambiguities = false)
    # testing separately, cf https://github.com/JuliaTesting/Aqua.jl/issues/77
    Aqua.test_ambiguities(LaTeXTabulars)
end
