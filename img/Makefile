# -*- makefile -*-

DIA_IMAGES = announce_networks.dia multiple_announces.dia multiple_clients.dia
TEX_IMAGES = $(DIA_IMAGES:.dia=.tex)

all: $(TEX_IMAGES)

.SUFFIXES: .dia .tex

.dia.tex:
	/usr/bin/dia -e $@ $<

clean:
	rm -f $(PDF_IMAGES) $(TEX_IMAGES)
