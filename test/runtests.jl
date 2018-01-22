using LaTeXTabulars
using Base.Test
using LaTeXStrings

squash_whitespace(string) = strip(replace(string, r"[ \n\t]+", " "))

@test squash_whitespace(" something  \n with line  breaks \n  and   stuff \n") ==
    "something with line breaks and stuff"

≅(a, b) = squash_whitespace(a) == squash_whitespace(b)

@test print_tabular(String, "ll", [Rule(:top),
                                   [L"\alpha", L"\beta", "sum"],
                                   Rule(:mid),
                                   [1, 2, 3],
                                   [4.0, "5", "six"],
                                   Rule(:bottom)]) ≅
                                       raw"\begin{tabular}{ll}
                                        \toprule
                                        $\alpha$ & $\beta$ & sum \\
                                        \midrule
                                        1 & 2 & 3 \\
                                        4.0 & 5 & six \\
                                        \bottomrule
                                        \end{tabular}"
