#! /usr/bin/make -f
# -*- makefile -*-

IMAGES = img/announce_networks.png img/multiple_announces.png img/multiple_clients.png img/byncsa30.png
SOURCE = batmand_howto.tex
OUTPUT = $(SOURCE:.tex=.pdf)
TEXFLAGS += -interaction=batchmode

all: $(OUTPUT)

$(OUTPUT): $(SOURCE) $(IMAGES)
	# TOC
	pdflatex $(TEXFLAGS) $(SOURCE)
	# actual output
	pdflatex $(TEXFLAGS) $(SOURCE)

clean:
	rm -f $(OUTPUT) $(SOURCE:.tex=.log)  $(SOURCE:.tex=.out)  $(SOURCE:.tex=.aux)
