#! /usr/bin/make -f
# -*- makefile -*-

SOURCE = batmand_howto.tex
OUTPUT = $(SOURCE:.tex=.pdf)
TEXFLAGS += -interaction=batchmode

all: $(OUTPUT)

$(OUTPUT): $(SOURCE) img
	# TOC
	pdflatex $(TEXFLAGS) $(SOURCE)
	# actual output
	pdflatex $(TEXFLAGS) $(SOURCE)

img:
	make -C img/

clean:
	rm -f $(OUTPUT) $(SOURCE:.tex=.log)  $(SOURCE:.tex=.out)  $(SOURCE:.tex=.aux)
	make -C img clean

.PHONY:	all clean img
