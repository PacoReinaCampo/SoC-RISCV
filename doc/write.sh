rm -f *.tex
rm -f *.pdf

pandoc BOOK.md -s -o SoC-RISCV.tex
pandoc BOOK.md -s -o SoC-RISCV.pdf
