DIA_IMAGES=asymetry.dia
PNG_IMAGES=$(DIA_IMAGES:.dia=.png)
PDF_IMAGES=$(DIA_IMAGES:.dia=.pdf)

.PHONY:		clean
.SUFFIXES:	.dia	.png	.eps	.pdf

default:	all
all:	$(PDF_IMAGES) $(PNG_IMAGES)

.dia.png:
	/usr/bin/dia -e $@ $<
.dia.eps:
	/usr/bin/dia -e $@ $<
.eps.pdf:
	/usr/bin/epstopdf --outfile=$@ $<

clean:
	rm -f *.png *.eps *.pdf
