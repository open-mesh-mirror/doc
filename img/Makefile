# -*- makefile -*-

DIA_IMAGES = announce_networks.dia multiple_announces.dia multiple_clients.dia
PDF_IMAGES = $(DIA_IMAGES:.dia=.pdf)

all: $(PDF_IMAGES)

.SUFFIXES: .dia .eps .pdf

.dia.eps:
	/usr/bin/dia -e $@ $<
.eps.pdf:
	/usr/bin/epstopdf --outfile=$@ $<

clean:
	rm -f $(PDF_IMAGES) $(PDF_IMAGES:.pdf=.eps)
