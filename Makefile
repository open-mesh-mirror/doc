#! /usr/bin/make -f
# -*- makefile -*-

SOURCE = batmand_howto.tex copyright.tex installing.tex references.tex \
         title.tex troubleshooting.tex usage.tex
OUTPUT = batmand_howto.pdf
TEXFLAGS += -interaction=batchmode

all: $(OUTPUT)

$(OUTPUT): $(SOURCE) img
	# TOC
	pdflatex $(TEXFLAGS) $(SOURCE:.pdf=.tex)
	# actual output
	pdflatex $(TEXFLAGS) $(SOURCE:.pdf=.tex)

img:
	make -C img/

clean:
	rm -f $(OUTPUT) $(SOURCE:.tex=.log)  $(SOURCE:.tex=.out)  $(SOURCE:.tex=.aux)
	make -C img clean

.PHONY:	all clean img
