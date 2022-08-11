rm -f *.tex
rm -f *.pdf

pandoc ../README.md -s -o SoC-RISCV.tex
pandoc ../README.md -s -o SoC-RISCV.pdf
