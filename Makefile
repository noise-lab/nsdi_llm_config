TARGET=main

all: pdf

pdf:
	pdflatex main
	pdflatex main
	bibtex main
	pdflatex main

clean:
	latexmk -c

cleanall: clean
	latexmk -C
	rm -f paper.bbl
