GP_IMAGES=asym_penalty.gp
DIA_IMAGES=asymetry.dia tq.dia eq.dia rq.dia hop_penalty1.dia hop_penalty2.dia asym_link1.dia asym_link2.dia tq_prop.dia
PNG_IMAGES= $(DIA_IMAGES:.dia=.png) 
PNG_IMAGES+=$(GP_IMAGES:.gp=.png) 
PDF_IMAGES= $(DIA_IMAGES:.dia=.pdf) 
PDF_IMAGES+=$(GP_IMAGES:.gp=.pdf) 

.PHONY:		clean
.SUFFIXES:	.dia	.png	.eps	.pdf	.gp

default:	all
all:	$(PDF_IMAGES) $(PNG_IMAGES)	

.gp.png:
	gnuplot $<
.gp.eps:
	gnuplot $<

.dia.png:
	/usr/bin/dia -e $@ $<
.dia.eps:
	/usr/bin/dia -e $@ $<
.eps.pdf:
	/usr/bin/epstopdf --outfile=$@ $<

clean:
	rm -f *.png *.eps *.pdf
